import type { WASocket } from '@whiskeysockets/baileys';
import type { proto } from '@whiskeysockets/baileys';
import { supabase } from './supabase.js';
import { resolveContact } from './contact-resolver.js';
import { isGroupKnown, syncSingleGroup } from './group-sync.js';
import { config } from './config.js';
import { logger } from './logger.js';

type WAMessage = proto.IWebMessageInfo;

let activeSock: WASocket | null = null;

export function setSocket(sock: WASocket) {
  activeSock = sock;
}

export async function handleMessage(msg: WAMessage) {
  const remoteJid = msg.key?.remoteJid;
  if (!remoteJid) return;

  // Discard broadcast/status messages
  if (remoteJid.includes('@broadcast')) return;

  // Discard protocol messages (history sync, peer data operations, etc.)
  if (msg.message?.protocolMessage) return;

  // Discard message stubs (system notifications, failed decryptions)
  if (msg.messageStubType && !msg.message) return;

  const isGroup = remoteJid.endsWith('@g.us');
  const isPersonal = remoteJid.endsWith('@s.whatsapp.net');
  const isLid = remoteJid.endsWith('@lid');

  if (!isGroup && !isPersonal && !isLid) {
    logger.debug({ remoteJid }, 'Skipping unknown JID type');
    return;
  }

  if (isGroup) {
    await handleGroupMessage(msg, remoteJid);
  } else {
    // Both @s.whatsapp.net and @lid are personal DMs
    await handlePersonalMessage(msg, remoteJid);
  }
}

async function handleGroupMessage(msg: WAMessage, remoteJid: string) {
  if (!isGroupKnown(remoteJid) && activeSock) {
    syncSingleGroup(activeSock, remoteJid).catch((err) => {
      logger.warn({ err, group: remoteJid }, 'Background group sync failed');
    });
  }

  const senderJid = msg.key?.participant || msg.key?.remoteJid;
  if (!senderJid) return;

  const text = extractText(msg);
  const messageType = detectMessageType(msg);
  const timestamp = normalizeTimestamp(msg.messageTimestamp);

  const contactId = await resolveContact(senderJid, msg.pushName);
  const isFromHendra = senderJid === config.hendraJid;

  const { data: groupData } = await supabase
    .from('groups')
    .select('id')
    .eq('wa_group_id', remoteJid)
    .maybeSingle();

  const { error } = await supabase.from('messages').insert({
    wa_message_id: msg.key?.id || null,
    group_id: groupData?.id || null,
    wa_group_id: remoteJid,
    sender_jid: senderJid,
    sender_name: msg.pushName || null,
    contact_id: contactId,
    message_text: text || null,
    message_type: messageType,
    is_from_hendra: isFromHendra,
    quoted_message_id: extractQuotedId(msg) || null,
    conversation_type: 'group',
    wa_contact_jid: null,
    timestamp: timestamp.toISOString(),
    raw_data: stripBuffers(msg) as Record<string, unknown>,
    listener_id: config.listenerId,
    last_seen_by_listener: new Date().toISOString(),
  });

  if (error) {
    if (error.code === '23505') return;
    logger.error({ error, msgId: msg.key?.id }, 'Failed to insert group message');
    return;
  }

  logger.info(
    {
      group: remoteJid,
      sender: msg.pushName || senderJid,
      type: messageType,
      hendra: isFromHendra,
      len: text?.length || 0,
    },
    'Group message saved'
  );
}

async function handlePersonalMessage(msg: WAMessage, remoteJid: string) {
  const isFromMe = msg.key?.fromMe === true;
  const isLid = remoteJid.endsWith('@lid');

  // For LID messages, we need to figure out the actual contact JID
  // The remoteJid is the LID, but we store wa_contact_jid as the phone-based JID when possible
  const senderJid = isFromMe ? config.hendraJid : remoteJid;
  const isFromHendra = isFromMe || senderJid === config.hendraJid;

  // For wa_contact_jid, use the remoteJid (whether @s.whatsapp.net or @lid)
  // This ensures DMs are grouped by contact
  const waContactJid = remoteJid;

  const text = extractText(msg);
  const messageType = detectMessageType(msg);
  const timestamp = normalizeTimestamp(msg.messageTimestamp);

  const contactId = await resolveContact(senderJid, msg.pushName);

  const { error } = await supabase.from('messages').insert({
    wa_message_id: msg.key?.id || null,
    group_id: null,
    wa_group_id: null,
    sender_jid: senderJid,
    sender_name: msg.pushName || null,
    contact_id: contactId,
    message_text: text || null,
    message_type: messageType,
    is_from_hendra: isFromHendra,
    quoted_message_id: extractQuotedId(msg) || null,
    conversation_type: 'personal',
    wa_contact_jid: waContactJid,
    timestamp: timestamp.toISOString(),
    raw_data: stripBuffers(msg) as Record<string, unknown>,
    listener_id: config.listenerId,
    last_seen_by_listener: new Date().toISOString(),
  });

  if (error) {
    if (error.code === '23505') return;
    logger.error({ error, msgId: msg.key?.id, contact: remoteJid }, 'Failed to insert personal message');
    return;
  }

  logger.info(
    {
      contact: remoteJid,
      sender: msg.pushName || senderJid,
      type: messageType,
      hendra: isFromHendra,
      lid: isLid,
      len: text?.length || 0,
    },
    'Personal message saved'
  );
}

function extractText(msg: WAMessage): string | null {
  const m = msg.message;
  if (!m) return null;

  return (
    m.conversation ||
    m.extendedTextMessage?.text ||
    m.imageMessage?.caption ||
    m.videoMessage?.caption ||
    m.documentMessage?.caption ||
    m.listResponseMessage?.singleSelectReply?.selectedRowId ||
    m.buttonsResponseMessage?.selectedDisplayText ||
    null
  );
}

function detectMessageType(msg: WAMessage): string {
  const m = msg.message;
  if (!m) return 'unknown';

  if (m.conversation || m.extendedTextMessage) return 'text';
  if (m.imageMessage) return 'image';
  if (m.videoMessage) return 'video';
  if (m.audioMessage) return 'audio';
  if (m.documentMessage) return 'document';
  if (m.stickerMessage) return 'sticker';
  if (m.contactMessage || m.contactsArrayMessage) return 'contact';
  if (m.locationMessage || m.liveLocationMessage) return 'location';
  if (m.reactionMessage) return 'reaction';
  if (m.pollCreationMessage || m.pollCreationMessageV3) return 'poll';

  return 'other';
}

function extractQuotedId(msg: WAMessage): string | null {
  const ctx = msg.message?.extendedTextMessage?.contextInfo;
  return ctx?.stanzaId || null;
}

function normalizeTimestamp(ts: proto.IWebMessageInfo['messageTimestamp']): Date {
  if (!ts) return new Date();

  const num = typeof ts === 'number' ? ts : typeof ts === 'object' && 'low' in ts ? ts.low : Number(ts);

  if (num > 1e12) return new Date(num);
  return new Date(num * 1000);
}

function stripBuffers(obj: unknown): unknown {
  if (obj === null || obj === undefined) return obj;
  if (obj instanceof Uint8Array || Buffer.isBuffer(obj)) return '<binary>';
  if (Array.isArray(obj)) return obj.map(stripBuffers);
  if (typeof obj === 'object') {
    const result: Record<string, unknown> = {};
    for (const [key, value] of Object.entries(obj as Record<string, unknown>)) {
      result[key] = stripBuffers(value);
    }
    return result;
  }
  return obj;
}
