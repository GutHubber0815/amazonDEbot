import { getSupabase } from './client';
import type { Favorite } from '@early-help/types';

/**
 * Get user favorites
 */
export async function getFavorites(userId: string): Promise<Favorite[]> {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('favorites')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false });

  if (error) throw error;
  return data || [];
}

/**
 * Add favorite
 */
export async function addFavorite(userId: string, entryId: string): Promise<Favorite> {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('favorites')
    .insert({ user_id: userId, entry_id: entryId })
    .select()
    .single();

  if (error) throw error;
  return data;
}

/**
 * Remove favorite
 */
export async function removeFavorite(userId: string, entryId: string): Promise<void> {
  const supabase = getSupabase();
  const { error } = await supabase
    .from('favorites')
    .delete()
    .eq('user_id', userId)
    .eq('entry_id', entryId);

  if (error) throw error;
}

/**
 * Check if entry is favorited
 */
export async function isFavorited(userId: string, entryId: string): Promise<boolean> {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('favorites')
    .select('id')
    .eq('user_id', userId)
    .eq('entry_id', entryId)
    .maybeSingle();

  if (error) throw error;
  return !!data;
}

/**
 * Sync local favorites to server
 */
export async function syncFavorites(userId: string, localEntryIds: string[]): Promise<void> {
  const supabase = getSupabase();

  // Get existing server favorites
  const serverFavorites = await getFavorites(userId);
  const serverEntryIds = serverFavorites.map(f => f.entry_id);

  // Add missing favorites
  const toAdd = localEntryIds.filter(id => !serverEntryIds.includes(id));
  for (const entryId of toAdd) {
    await addFavorite(userId, entryId);
  }
}
