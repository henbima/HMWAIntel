import { useState, useEffect } from 'react';
import { fetchCategories, type GroupCategory } from '../services/group-category-service';

interface UseGroupCategoriesReturn {
  categories: GroupCategory[] | null;
  loading: boolean;
  refetch: () => Promise<void>;
  categoryMap: Record<string, GroupCategory>;
  categoryBySlug: Record<string, GroupCategory>;
}

export function useGroupCategories(): UseGroupCategoriesReturn {
  const [categories, setCategories] = useState<GroupCategory[] | null>(null);
  const [loading, setLoading] = useState(true);
  const [categoryMap, setCategoryMap] = useState<Record<string, GroupCategory>>({});
  const [categoryBySlug, setCategoryBySlug] = useState<Record<string, GroupCategory>>({});

  const loadCategories = async () => {
    setLoading(true);
    try {
      const { data, error } = await fetchCategories();

      if (error) {
        console.error('Error fetching categories:', error);
        setCategories(null);
        setCategoryMap({});
        setCategoryBySlug({});
      } else if (data) {
        setCategories(data);
        
        // Build categoryMap (id → category)
        const mapById: Record<string, GroupCategory> = {};
        const mapBySlug: Record<string, GroupCategory> = {};
        
        data.forEach(category => {
          mapById[category.id] = category;
          mapBySlug[category.slug] = category;
        });
        
        setCategoryMap(mapById);
        setCategoryBySlug(mapBySlug);
      }
    } catch (error) {
      console.error('Error loading categories:', error);
      setCategories(null);
      setCategoryMap({});
      setCategoryBySlug({});
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadCategories();
  }, []);

  return {
    categories,
    loading,
    refetch: loadCategories,
    categoryMap,
    categoryBySlug,
  };
}
