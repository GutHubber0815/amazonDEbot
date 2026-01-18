import { getSupabase } from './client';
import type { Entry, EntryWithCategory, EntryHistory } from '@early-help/types';

/**
 * Get all published entries
 */
export async function getEntries(): Promise<Entry[]> {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('entries')
    .select('*')
    .eq('published', true)
    .order('order', { ascending: true });

  if (error) throw error;
  return data || [];
}

/**
 * Get all entries (including unpublished) - admin only
 */
export async function getAllEntries(): Promise<Entry[]> {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('entries')
    .select('*')
    .order('order', { ascending: true });

  if (error) throw error;
  return data || [];
}

/**
 * Get entries with category info
 */
export async function getEntriesWithCategory(): Promise<EntryWithCategory[]> {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('entries')
    .select('*, category:categories(*)')
    .eq('published', true)
    .order('order', { ascending: true });

  if (error) throw error;
  return data || [];
}

/**
 * Get entry by ID
 */
export async function getEntryById(id: string): Promise<Entry | null> {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('entries')
    .select('*')
    .eq('id', id)
    .single();

  if (error) {
    if (error.code === 'PGRST116') return null; // Not found
    throw error;
  }
  return data;
}

/**
 * Get entries by category
 */
export async function getEntriesByCategory(categoryId: string): Promise<Entry[]> {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('entries')
    .select('*')
    .eq('category_id', categoryId)
    .eq('published', true)
    .order('order', { ascending: true });

  if (error) throw error;
  return data || [];
}

/**
 * Create entry - admin only
 */
export async function createEntry(entry: Omit<Entry, 'id' | 'created_at' | 'updated_at'>): Promise<Entry> {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('entries')
    .insert(entry)
    .select()
    .single();

  if (error) throw error;
  return data;
}

/**
 * Update entry - admin only
 */
export async function updateEntry(id: string, updates: Partial<Entry>): Promise<Entry> {
  const supabase = getSupabase();

  // First, get current entry to save to history
  const current = await getEntryById(id);
  if (current) {
    await saveEntryHistory(id, current.title, current.body);
  }

  const { data, error } = await supabase
    .from('entries')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select()
    .single();

  if (error) throw error;
  return data;
}

/**
 * Delete entry - admin only
 */
export async function deleteEntry(id: string): Promise<void> {
  const supabase = getSupabase();
  const { error } = await supabase
    .from('entries')
    .delete()
    .eq('id', id);

  if (error) throw error;
}

/**
 * Save entry to history
 */
async function saveEntryHistory(entryId: string, title: string, body: string): Promise<void> {
  const supabase = getSupabase();
  const { data: userData } = await supabase.auth.getUser();

  await supabase.from('entry_history').insert({
    entry_id: entryId,
    title,
    body,
    changed_by: userData?.user?.id || 'system',
  });
}

/**
 * Get entry history
 */
export async function getEntryHistory(entryId: string): Promise<EntryHistory[]> {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('entry_history')
    .select('*')
    .eq('entry_id', entryId)
    .order('changed_at', { ascending: false });

  if (error) throw error;
  return data || [];
}
