// Database Tables
export interface Category {
  id: string;
  name: string;
  description: string;
  slug: string;
  order: number;
  created_at: string;
  updated_at: string;
}

export interface Entry {
  id: string;
  category_id: string;
  title: string;
  summary: string;
  body: string;
  tags: string[];
  published: boolean;
  order: number;
  created_at: string;
  updated_at: string;
  last_updated: string;
}

export interface EntryWithCategory extends Entry {
  category: Category;
}

export interface GlossaryItem {
  id: string;
  term: string;
  meaning: string;
  context: string;
  examples: string;
  related_terms: string[];
  created_at: string;
  updated_at: string;
}

export interface SupportContact {
  id: string;
  name: string;
  role: 'parent' | 'teacher' | 'social_worker' | 'all';
  region: string;
  zip_codes: string[];
  phone?: string;
  email?: string;
  website?: string;
  description: string;
  category: string;
  created_at: string;
  updated_at: string;
}

export interface EntryHistory {
  id: string;
  entry_id: string;
  title: string;
  body: string;
  changed_by: string;
  changed_at: string;
}

export interface Favorite {
  id: string;
  user_id: string;
  entry_id: string;
  created_at: string;
}

// Checklist Types
export interface ChecklistItem {
  id: string;
  text: string;
  explanation: string;
  category: string;
}

export interface ChecklistProgress {
  [itemId: string]: boolean;
}

export interface ChecklistResult {
  checkedCount: number;
  totalCount: number;
  categories: {
    [category: string]: number;
  };
  interpretation: string;
  nextSteps: string[];
}

// User Types
export interface User {
  id: string;
  email: string;
  role: 'user' | 'admin';
  created_at: string;
}

// Search & Filter Types
export interface SearchParams {
  query?: string;
  tags?: string[];
  categoryId?: string;
  role?: string;
  region?: string;
}

export interface PaginationParams {
  page: number;
  limit: number;
}

export interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

// API Response Types
export interface ApiResponse<T> {
  data?: T;
  error?: string;
  message?: string;
}

// Local Storage Types
export interface LocalFavorites {
  entryIds: string[];
  updatedAt: string;
}

export interface LocalChecklistProgress {
  progress: ChecklistProgress;
  updatedAt: string;
}
