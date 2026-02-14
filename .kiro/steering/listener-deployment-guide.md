---
inclusion: manual
version: 1.0.0
last-updated: 2026-02-14
---

# Listener Deployment Guide — HMSO

**Purpose:** Complete reference for deploying the WhatsApp listener to the production server.

**When to use:** Whenever you need to deploy listener code changes, restart the listener, check logs, or troubleshoot server connectivity.

---

## Quick Reference

| Task | Command |
|------|---------|
| Check listener status | `ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "pm2 status"` |
| View recent logs | `ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "pm2 logs hmso-listener --lines 50 --nostream"` |
| Restart listener | `ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "cd ~/hmso-listener && pm2 restart ecosystem.config.cjs"` |
| Stop listener | `ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "pm2 stop hmso-listener"` |
| Start listener | `ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "pm2 start ecosystem.config.cjs"` |

---

## Server Connection Details

**CRITICAL: These credentials are sensitive. Never commit them to git or share publicly.**

- **Server IP:** 103.150.92.166
- **SSH User:** henbima
- **PEM Key Location:** `D:\biznet\Hr43GeZ3.pem`
- **Listener Directory:** `~/hmso-listener/`
- **Process Manager:** PM2
- **Process Name:** `hmso-listener`

### SSH Command Template
```bash
ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "<command>"
```

### SCP Command Template (for file transfers)
```bash
scp -O -i "D:\biznet\Hr43GeZ3.pem" <local-path> henbima@103.150.92.166:~/hmso-listener/<remote-path>
```

**Note:** The `-O` flag is REQUIRED (legacy protocol mode for this server).

---

## Full Deployment Workflow

### Step 1: Identify Changed Files

Before deploying, determine which listener files have changed:
- Check `listener/src/` for TypeScript changes
- Check `listener/.env` for environment variable changes
- Check `listener/ecosystem.config.cjs` for PM2 configuration changes

### Step 2: Transfer Files to Server

Use SCP to copy changed files. **Do NOT overwrite `.env` or `auth_info/` on the server.**

**Example: Deploy a single file**
```bash
scp -O -i "D:\biznet\Hr43GeZ3.pem" listener/src/message-handler.ts henbima@103.150.92.166:~/hmso-listener/src/message-handler.ts
```

**Example: Deploy multiple files**
```bash
scp -O -i "D:\biznet\Hr43GeZ3.pem" listener/src/index.ts henbima@103.150.92.166:~/hmso-listener/src/index.ts
scp -O -i "D:\biznet\Hr43GeZ3.pem" listener/src/config.ts henbima@103.150.92.166:~/hmso-listener/src/config.ts
scp -O -i "D:\biznet\Hr43GeZ3.pem" listener/package.json henbima@103.150.92.166:~/hmso-listener/package.json
```

**FORBIDDEN: Do NOT SCP these files**
- `.env` — contains Supabase credentials (already on server)
- `auth_info/` — contains WhatsApp session state (already on server)
- `node_modules/` — will be reinstalled during build

### Step 3: Build on Server

SSH to the server and rebuild the TypeScript:

```bash
ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "cd ~/hmso-listener && chmod +x node_modules/.bin/tsc && npm run build"
```

**What this does:**
- Makes TypeScript compiler executable
- Runs `npm run build` (compiles `src/` → `dist/`)
- If there are TypeScript errors, the build will fail and you'll see the error messages

### Step 4: Restart the Listener

After a successful build, restart PM2:

```bash
ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "cd ~/hmso-listener && pm2 restart ecosystem.config.cjs"
```

**What this does:**
- Stops the old listener process
- Starts a new process using the updated `dist/` files
- PM2 automatically manages the restart

### Step 5: Verify Deployment

Check that the listener restarted successfully:

```bash
ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "pm2 status"
```

Expected output:
```
┌─────────────────────────┬────┬─────────┬──────┬──────────┐
│ App name                │ id │ version │ mode │ status   │
├─────────────────────────┼────┼─────────┼──────┼──────────┤
│ hmso-listener       │ 0  │ 1.0.0   │ fork │ online   │
└─────────────────────────┴────┴─────────┴──────┴──────────┘
```

If status is `online`, deployment succeeded. If `stopped` or `errored`, check logs (see Step 6).

### Step 6: Check Logs

View the most recent logs to confirm the listener is running:

```bash
ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "pm2 logs hmso-listener --lines 50 --nostream"
```

**Expected log output (first startup):**
```
[LISTENER] Connecting to Supabase...
[LISTENER] Connected to hmso schema
[LISTENER] Syncing group metadata...
[LISTENER] Synced 12 groups
[LISTENER] Listening for messages...
```

**If you see errors:**
- Check the error message carefully
- Common issues: missing `.env` variables, Supabase connection failure, TypeScript compilation errors
- See "Troubleshooting" section below

---

## Common Tasks

### Task: Deploy a Single File Change

**Scenario:** You fixed a bug in `listener/src/message-handler.ts`

```bash
# 1. Transfer the file
scp -O -i "D:\biznet\Hr43GeZ3.pem" listener/src/message-handler.ts henbima@103.150.92.166:~/hmso-listener/src/message-handler.ts

# 2. Build on server
ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "cd ~/hmso-listener && npm run build"

# 3. Restart
ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "cd ~/hmso-listener && pm2 restart ecosystem.config.cjs"

# 4. Verify
ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "pm2 logs hmso-listener --lines 20 --nostream"
```

### Task: Deploy Multiple File Changes

**Scenario:** You updated `package.json` (new dependency) and `src/index.ts`

```bash
# 1. Transfer files
scp -O -i "D:\biznet\Hr43GeZ3.pem" listener/package.json henbima@103.150.92.166:~/hmso-listener/package.json
scp -O -i "D:\biznet\Hr43GeZ3.pem" listener/src/index.ts henbima@103.150.92.166:~/hmso-listener/src/index.ts

# 2. Install dependencies + build on server
ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "cd ~/hmso-listener && npm install && npm run build"

# 3. Restart
ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "cd ~/hmso-listener && pm2 restart ecosystem.config.cjs"

# 4. Verify
ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "pm2 logs hmso-listener --lines 20 --nostream"
```

### Task: Check Listener Status Without Restarting

```bash
ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "pm2 status"
```

### Task: View Last 100 Lines of Logs

```bash
ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "pm2 logs hmso-listener --lines 100 --nostream"
```

### Task: Stop the Listener (Emergency)

```bash
ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "pm2 stop hmso-listener"
```

### Task: Start the Listener (After Stopping)

```bash
ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "pm2 start ecosystem.config.cjs"
```

---

## Troubleshooting

### Problem: Build Fails with TypeScript Errors

**Symptom:** `npm run build` returns compilation errors

**Solution:**
1. Check the error message — it will show the file and line number
2. Fix the TypeScript error in your local `listener/src/` file
3. Re-transfer the corrected file to the server
4. Re-run build

**Example error:**
```
src/message-handler.ts:42:10 - error TS2339: Property 'xyz' does not exist on type 'Message'
```

### Problem: Listener Crashes After Restart

**Symptom:** `pm2 status` shows `errored` or `stopped`

**Solution:**
1. Check logs: `pm2 logs hmso-listener --lines 50 --nostream`
2. Look for error messages (connection failures, missing env vars, etc.)
3. Common causes:
   - **Missing `.env` variable:** Check that `SUPABASE_SERVICE_ROLE_KEY` and `HENDRA_JID` are set on the server
   - **Supabase connection failure:** Verify the Supabase project is accessible
   - **WhatsApp session expired:** Delete `auth_info/` and re-scan QR code (requires manual intervention)

### Problem: SSH Connection Refused

**Symptom:** `ssh: connect to host 103.150.92.166 port 22: Connection refused`

**Solution:**
1. Verify the server IP is correct: `103.150.92.166`
2. Verify the PEM key exists: `D:\biznet\Hr43GeZ3.pem`
3. Check your internet connection
4. The server may be temporarily down — wait a few minutes and retry

### Problem: Permission Denied (publickey)

**Symptom:** `Permission denied (publickey)`

**Solution:**
1. Verify the PEM key path is correct: `D:\biznet\Hr43GeZ3.pem`
2. Verify the username is correct: `henbima`
3. Verify the PEM key has correct permissions (Windows: right-click → Properties → Security → only your user should have access)

### Problem: SCP File Transfer Fails

**Symptom:** `scp: command not found` or connection errors

**Solution:**
1. Verify you're using the `-O` flag: `scp -O -i ...`
2. Verify the local file path exists
3. Verify the remote path is correct: `~/hmso-listener/src/`
4. Check that the remote directory exists on the server

---

## Important Notes

### Never Overwrite These Files on Server

- **`.env`** — Contains Supabase credentials. If you need to update env vars, SSH to the server and edit directly:
  ```bash
  ssh -i "D:\biznet\Hr43GeZ3.pem" henbima@103.150.92.166 "nano ~/hmso-listener/.env"
  ```

- **`auth_info/`** — Contains WhatsApp session state. Deleting this requires re-scanning the QR code. Only delete if the listener is logged out.

- **`node_modules/`** — Will be reinstalled during `npm install`. Never SCP this directory.

### Server Folder Structure

The server folder is NOT a git repository. Files must be transferred individually via SCP. The structure mirrors the local `listener/` folder:

```
~/hmso-listener/
├── src/                    # TypeScript source files
├── dist/                   # Compiled JavaScript (generated by npm run build)
├── auth_info/              # WhatsApp session credentials (DO NOT TOUCH)
├── ecosystem.config.cjs    # PM2 configuration
├── package.json
├── tsconfig.json
├── .env                    # Supabase credentials (DO NOT OVERWRITE)
└── node_modules/           # Dependencies (reinstalled via npm install)
```

### PM2 Auto-Restart

PM2 is configured to:
- Auto-restart the listener if it crashes
- Auto-start on system boot
- Persist logs across restarts

You can view the PM2 configuration in `listener/ecosystem.config.cjs`.

---

## Deployment Checklist

Before deploying, verify:

- [ ] All TypeScript changes are complete and tested locally
- [ ] No syntax errors in modified files
- [ ] You have identified which files changed
- [ ] You have the correct PEM key path: `D:\biznet\Hr43GeZ3.pem`
- [ ] You have the correct server IP: `103.150.92.166`
- [ ] You have the correct username: `henbima`
- [ ] You are NOT overwriting `.env` or `auth_info/`

After deployment, verify:

- [ ] Build completed without errors
- [ ] `pm2 status` shows `online`
- [ ] Logs show no error messages
- [ ] Listener is receiving messages (check `hmso.messages` table for recent entries)

---

## Reference: Local Development

For local development and testing before deployment, see `listener/README.md`:

```bash
cd listener
npm install
npm run dev
```

This runs the listener locally without PM2. Useful for testing changes before deploying to production.

---

## Questions?

If you encounter issues not covered here:
1. Check the logs: `pm2 logs hmso-listener --lines 100 --nostream`
2. Check the error message carefully — it usually indicates the root cause
3. Ask Hendra for clarification on server access or credentials
4. Reference `listener/README.md` for listener-specific documentation
