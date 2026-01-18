import { getSupabase } from './client';
import type { GlossaryItem } from '@early-help/types';

/**
 * Get all glossary items
 */
export async function getGlossaryItems(): Promise<GlossaryItem[]> {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('glossary_items')
    .select('*')
    .order('term', { ascending: true });

  if (error) throw error;
  return data || [];
}

/**
 * Get glossary item by ID
 */
export async function getGlossaryItemById(id: string): Promise<GlossaryItem | null> {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('glossary_items')
    .select('*')
    .eq('id', id)
    .single();

  if (error) {
    if (error.code === 'PGRST116') return null;
    throw error;
  }
  return data;
}

/**
 * Create glossary item - admin only
 */
export async function createGlossaryItem(item: Omit<GlossaryItem, 'id' | 'created_at' | 'updated_at'>): Promise<GlossaryItem> {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('glossary_items')
    .insert(item)
    .select()
    .single();

  if (error) throw error;
  return data;
}

/**
 * Update glossary item - admin only
 */
export async function updateGlossaryItem(id: string, updates: Partial<GlossaryItem>): Promise<GlossaryItem> {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('glossary_items')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select()
    .single();

  if (error) throw error;
  return data;
}

/**
 * Delete glossary item - admin only
 */
export async function deleteGlossaryItem(id: string): Promise<void> {
  const supabase = getSupabase();
  const { error } = await supabase
    .from('glossary_items')
    .delete()
    .eq('id', id);

  if (error) throw error;
}
