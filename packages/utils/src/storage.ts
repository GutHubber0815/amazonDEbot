import type { LocalFavorites, LocalChecklistProgress, ChecklistProgress } from '@early-help/types';

const FAVORITES_KEY = 'early-help:favorites';
const CHECKLIST_KEY = 'early-help:checklist';

/**
 * Storage interface for web and mobile
 */
export interface StorageAdapter {
  getItem: (key: string) => Promise<string | null>;
  setItem: (key: string, value: string) => Promise<void>;
  removeItem: (key: string) => Promise<void>;
}

/**
 * Get local favorites
 */
export async function getLocalFavorites(storage: StorageAdapter): Promise<string[]> {
  try {
    const data = await storage.getItem(FAVORITES_KEY);
    if (!data) return [];

    const parsed: LocalFavorites = JSON.parse(data);
    return parsed.entryIds || [];
  } catch (error) {
    console.error('Error getting local favorites:', error);
    return [];
  }
}

/**
 * Save local favorites
 */
export async function saveLocalFavorites(
  storage: StorageAdapter,
  entryIds: string[]
): Promise<void> {
  try {
    const data: LocalFavorites = {
      entryIds,
      updatedAt: new Date().toISOString(),
    };
    await storage.setItem(FAVORITES_KEY, JSON.stringify(data));
  } catch (error) {
    console.error('Error saving local favorites:', error);
  }
}

/**
 * Add to local favorites
 */
export async function addLocalFavorite(storage: StorageAdapter, entryId: string): Promise<void> {
  const favorites = await getLocalFavorites(storage);
  if (!favorites.includes(entryId)) {
    await saveLocalFavorites(storage, [...favorites, entryId]);
  }
}

/**
 * Remove from local favorites
 */
export async function removeLocalFavorite(storage: StorageAdapter, entryId: string): Promise<void> {
  const favorites = await getLocalFavorites(storage);
  await saveLocalFavorites(storage, favorites.filter((id) => id !== entryId));
}

/**
 * Get checklist progress
 */
export async function getChecklistProgress(storage: StorageAdapter): Promise<ChecklistProgress> {
  try {
    const data = await storage.getItem(CHECKLIST_KEY);
    if (!data) return {};

    const parsed: LocalChecklistProgress = JSON.parse(data);
    return parsed.progress || {};
  } catch (error) {
    console.error('Error getting checklist progress:', error);
    return {};
  }
}

/**
 * Save checklist progress
 */
export async function saveChecklistProgress(
  storage: StorageAdapter,
  progress: ChecklistProgress
): Promise<void> {
  try {
    const data: LocalChecklistProgress = {
      progress,
      updatedAt: new Date().toISOString(),
    };
    await storage.setItem(CHECKLIST_KEY, JSON.stringify(data));
  } catch (error) {
    console.error('Error saving checklist progress:', error);
  }
}

/**
 * Clear all local data
 */
export async function clearLocalData(storage: StorageAdapter): Promise<void> {
  try {
    await storage.removeItem(FAVORITES_KEY);
    await storage.removeItem(CHECKLIST_KEY);
  } catch (error) {
    console.error('Error clearing local data:', error);
  }
}
