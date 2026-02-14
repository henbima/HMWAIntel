import { useGroupCategories } from '../hooks/useGroupCategories';

// Map category color names to dot colors
const colorDots: Record<string, string> = {
  emerald: 'bg-emerald-500',
  blue: 'bg-blue-500',
  purple: 'bg-purple-500',
  amber: 'bg-amber-500',
  cyan: 'bg-cyan-500',
  pink: 'bg-pink-500',
  orange: 'bg-orange-500',
  slate: 'bg-slate-500',
  gray: 'bg-gray-400',
};

// Size variants
const sizeStyles = {
  sm: 'text-sm py-1 px-2',
  md: 'text-base py-2 px-3',
};

interface CategoryPickerProps {
  value: string | null;
  onChange: (categoryId: string) => void;
  size?: 'sm' | 'md';
}

export function CategoryPicker({ value, onChange, size = 'sm' }: CategoryPickerProps) {
  const { categories, loading } = useGroupCategories();

  if (loading) {
    return (
      <select
        disabled
        aria-label="Category selector"
        className={`${sizeStyles[size]} border rounded-lg bg-gray-50 text-gray-400 cursor-not-allowed focus:outline-none`}
      >
        <option>Loading...</option>
      </select>
    );
  }

  if (!categories || categories.length === 0) {
    return (
      <select
        disabled
        aria-label="Category selector"
        className={`${sizeStyles[size]} border rounded-lg bg-gray-50 text-gray-400 cursor-not-allowed focus:outline-none`}
      >
        <option>No categories</option>
      </select>
    );
  }

  return (
    <div className="relative inline-block">
      <select
        value={value || ''}
        onChange={(e) => onChange(e.target.value)}
        aria-label="Select category"
        className={`${sizeStyles[size]} border rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 appearance-none cursor-pointer pr-8`}
      >
        <option value="">Select category...</option>
        {categories.map((category) => (
          <option key={category.id} value={category.id}>
            {category.label}
          </option>
        ))}
      </select>
      
      {/* Color indicator dot - shows selected category color */}
      {value && categories.find(c => c.id === value) && (
        <div className="absolute right-8 top-1/2 -translate-y-1/2 pointer-events-none">
          <div
            className={`w-2 h-2 rounded-full ${
              colorDots[categories.find(c => c.id === value)?.color || 'gray'] || colorDots.gray
            }`}
          />
        </div>
      )}
      
      {/* Dropdown arrow */}
      <div className="absolute right-2 top-1/2 -translate-y-1/2 pointer-events-none">
        <svg className="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
        </svg>
      </div>
    </div>
  );
}
