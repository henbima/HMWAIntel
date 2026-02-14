import { useGroupCategories } from '../hooks/useGroupCategories';

// Map category color names to Tailwind classes for active state
const activeColorStyles: Record<string, { bg: string; text: string; border: string }> = {
  emerald: { bg: 'bg-emerald-100', text: 'text-emerald-700', border: 'border-emerald-300' },
  blue: { bg: 'bg-blue-100', text: 'text-blue-700', border: 'border-blue-300' },
  purple: { bg: 'bg-purple-100', text: 'text-purple-700', border: 'border-purple-300' },
  amber: { bg: 'bg-amber-100', text: 'text-amber-700', border: 'border-amber-300' },
  cyan: { bg: 'bg-cyan-100', text: 'text-cyan-700', border: 'border-cyan-300' },
  pink: { bg: 'bg-pink-100', text: 'text-pink-700', border: 'border-pink-300' },
  orange: { bg: 'bg-orange-100', text: 'text-orange-700', border: 'border-orange-300' },
  slate: { bg: 'bg-slate-100', text: 'text-slate-700', border: 'border-slate-300' },
  gray: { bg: 'bg-gray-100', text: 'text-gray-700', border: 'border-gray-300' },
};

// Inactive state (gray)
const inactiveStyle = 'bg-gray-100 text-gray-600 border-gray-300';

interface CategoryFilterProps {
  selectedCategory: string | null; // slug, not id
  onChange: (slug: string | null) => void;
  groupCounts: Record<string, number>; // slug → count
}

export function CategoryFilter({ selectedCategory, onChange, groupCounts }: CategoryFilterProps) {
  const { categories } = useGroupCategories();

  if (!categories || categories.length === 0) {
    return null;
  }

  // Calculate total count for "All" pill
  const totalCount = Object.values(groupCounts).reduce((sum, count) => sum + count, 0);

  return (
    <div className="flex overflow-x-auto gap-2 pb-2">
      {/* "All" pill */}
      <button
        onClick={() => onChange(null)}
        className={`flex-shrink-0 px-3 py-1.5 text-sm font-medium rounded-full border transition-colors ${
          selectedCategory === null
            ? 'bg-gray-800 text-white border-gray-800'
            : inactiveStyle + ' hover:bg-gray-200'
        }`}
      >
        All ({totalCount})
      </button>

      {/* Category pills */}
      {categories.map((category) => {
        const count = groupCounts[category.slug] || 0;
        const isActive = selectedCategory === category.slug;
        const colorStyle = activeColorStyles[category.color] || activeColorStyles.gray;

        return (
          <button
            key={category.id}
            onClick={() => onChange(category.slug)}
            className={`flex-shrink-0 px-3 py-1.5 text-sm font-medium rounded-full border transition-colors ${
              isActive
                ? `${colorStyle.bg} ${colorStyle.text} ${colorStyle.border}`
                : inactiveStyle + ' hover:bg-gray-200'
            }`}
          >
            {category.label} ({count})
          </button>
        );
      })}
    </div>
  );
}
