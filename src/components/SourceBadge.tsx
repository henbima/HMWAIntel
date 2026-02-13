import { MessageSquare, Video, HelpCircle } from 'lucide-react';

interface SourceBadgeProps {
  sourceType?: string | null;
}

const sourceConfig: Record<string, { icon: typeof MessageSquare; label: string; bg: string; text: string }> = {
  whatsapp: { icon: MessageSquare, label: 'WhatsApp', bg: 'bg-green-50', text: 'text-green-700' },
  meeting: { icon: Video, label: 'Meeting', bg: 'bg-purple-50', text: 'text-purple-700' },
};

export function SourceBadge({ sourceType }: SourceBadgeProps) {
  const type = sourceType || 'whatsapp';
  const config = sourceConfig[type];

  if (config) {
    const Icon = config.icon;
    return (
      <span className={`inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium ${config.bg} ${config.text}`}>
        <Icon className="w-3 h-3" />
        {config.label}
      </span>
    );
  }

  // Unknown source type fallback
  return (
    <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-600">
      <HelpCircle className="w-3 h-3" />
      {type}
    </span>
  );
}
