import type { StorageAdapter } from '@early-help/utils';

/**
 * Browser storage adapter for web
 */
export const browserStorage: StorageAdapter = {
  getItem: async (key: string) => {
    if (typeof window === 'undefined') return null;
    return localStorage.getItem(key);
  },
  setItem: async (key: string, value: string) => {
    if (typeof window === 'undefined') return;
    localStorage.setItem(key, value);
  },
  removeItem: async (key: string) => {
    if (typeof window === 'undefined') return;
    localStorage.removeItem(key);
  },
};
