import type { GroupCategory } from '../services/group-category-service';

// Map category color names to Tailwind classes
const colorStyles: Record<string, { bg: string; text: string }> = {
  emerald: { bg: 'bg-emerald-50', text: 'text-emerald-700' },
  blue: { bg: 'bg-blue-50', text: 'text-blue-700' },
  purple: { bg: 'bg-purple-50', text: 'text-purple-700' },
  amber: { bg: 'bg-amber-50', text: 'text-amber-700' },
  cyan: { bg: 'bg-cyan-50', text: 'text-cyan-700' },
  pink: { bg: 'bg-pink-50', text: 'text-pink-700' },
  orange: { bg: 'bg-orange-50', text: 'text-orange-700' },
  slate: { bg: 'bg-slate-50', text: 'text-slate-700' },
  gray: { bg: 'bg-gray-50', text: 'text-gray-500' },
};

// Size variants
const sizeStyles = {
  sm: 'px-2 py-0.5 text-xs',
  md: 'px-3 py-1 text-sm',
};

interface CategoryBadgeProps {
  category: GroupCategory | null;
  size?: 'sm' | 'md';
}

export function CategoryBadge({ category, size = 'sm' }: CategoryBadgeProps) {
  // Handle null category (uncategorized)
  if (!category) {
    const style = colorStyles.gray;
    return (
      <span className={`inline-flex items-center rounded-full font-medium ${sizeStyles[size]} ${style.bg} ${style.text}`}>
        Uncategorized
      </span>
    );
  }

  // Get color style, fallback to gray if color not found
  const style = colorStyles[category.color] || colorStyles.gray;

  return (
    <span className={`inline-flex items-center rounded-full font-medium ${sizeStyles[size]} ${style.bg} ${style.text}`}>
      {category.label}
    </span>
  );
}
