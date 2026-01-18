import type { Entry, SupportContact } from '@early-help/types';

/**
 * Filter entries by category
 */
export function filterByCategory(entries: Entry[], categoryId?: string): Entry[] {
  if (!categoryId) {
    return entries;
  }
  return entries.filter((entry) => entry.category_id === categoryId);
}

/**
 * Filter entries by tags (any tag matches)
 */
export function filterByTags(entries: Entry[], tags?: string[]): Entry[] {
  if (!tags || tags.length === 0) {
    return entries;
  }

  const lowerTags = tags.map((tag) => tag.toLowerCase());

  return entries.filter((entry) =>
    entry.tags.some((tag) => lowerTags.includes(tag.toLowerCase()))
  );
}

/**
 * Filter entries by published status
 */
export function filterPublished(entries: Entry[]): Entry[] {
  return entries.filter((entry) => entry.published);
}

/**
 * Filter support contacts by role
 */
export function filterByRole(
  contacts: SupportContact[],
  role?: 'parent' | 'teacher' | 'social_worker'
): SupportContact[] {
  if (!role) {
    return contacts;
  }

  return contacts.filter((contact) => contact.role === role || contact.role === 'all');
}

/**
 * Filter support contacts by ZIP code
 */
export function filterByZipCode(contacts: SupportContact[], zipCode?: string): SupportContact[] {
  if (!zipCode) {
    return contacts;
  }

  return contacts.filter((contact) => {
    // Match exact ZIP or ZIP prefix
    return contact.zip_codes.some(
      (zip) => zip === zipCode || zipCode.startsWith(zip) || zip.startsWith(zipCode)
    );
  });
}

/**
 * Get unique tags from entries
 */
export function getUniqueTags(entries: Entry[]): string[] {
  const tagsSet = new Set<string>();
  entries.forEach((entry) => {
    entry.tags.forEach((tag) => tagsSet.add(tag));
  });
  return Array.from(tagsSet).sort();
}

/**
 * Sort entries by order then by title
 */
export function sortEntries(entries: Entry[]): Entry[] {
  return [...entries].sort((a, b) => {
    if (a.order !== b.order) {
      return a.order - b.order;
    }
    return a.title.localeCompare(b.title);
  });
}
