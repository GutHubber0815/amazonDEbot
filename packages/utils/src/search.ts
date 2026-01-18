import type { Entry, GlossaryItem } from '@early-help/types';

/**
 * Search entries by query string
 * Searches in title, summary, body, and tags
 */
export function searchEntries(entries: Entry[], query: string): Entry[] {
  if (!query || query.trim() === '') {
    return entries;
  }

  const lowerQuery = query.toLowerCase().trim();

  return entries.filter((entry) => {
    const titleMatch = entry.title.toLowerCase().includes(lowerQuery);
    const summaryMatch = entry.summary.toLowerCase().includes(lowerQuery);
    const bodyMatch = entry.body.toLowerCase().includes(lowerQuery);
    const tagsMatch = entry.tags.some((tag) => tag.toLowerCase().includes(lowerQuery));

    return titleMatch || summaryMatch || bodyMatch || tagsMatch;
  });
}

/**
 * Search glossary items by query string
 * Searches in term, meaning, context, and related terms
 */
export function searchGlossaryItems(items: GlossaryItem[], query: string): GlossaryItem[] {
  if (!query || query.trim() === '') {
    return items;
  }

  const lowerQuery = query.toLowerCase().trim();

  return items.filter((item) => {
    const termMatch = item.term.toLowerCase().includes(lowerQuery);
    const meaningMatch = item.meaning.toLowerCase().includes(lowerQuery);
    const contextMatch = item.context.toLowerCase().includes(lowerQuery);
    const relatedMatch = item.related_terms.some((term) => term.toLowerCase().includes(lowerQuery));

    return termMatch || meaningMatch || contextMatch || relatedMatch;
  });
}

/**
 * Fuzzy search with scoring
 */
export function fuzzySearch<T extends { title?: string; term?: string; name?: string }>(
  items: T[],
  query: string,
  fields: (keyof T)[]
): T[] {
  if (!query || query.trim() === '') {
    return items;
  }

  const lowerQuery = query.toLowerCase().trim();
  const queryWords = lowerQuery.split(/\s+/);

  const scored = items.map((item) => {
    let score = 0;

    fields.forEach((field) => {
      const value = item[field];
      if (typeof value === 'string') {
        const lowerValue = value.toLowerCase();

        // Exact match
        if (lowerValue === lowerQuery) {
          score += 100;
        }
        // Starts with query
        else if (lowerValue.startsWith(lowerQuery)) {
          score += 50;
        }
        // Contains query
        else if (lowerValue.includes(lowerQuery)) {
          score += 25;
        }

        // Word matches
        queryWords.forEach((word) => {
          if (lowerValue.includes(word)) {
            score += 10;
          }
        });
      }
    });

    return { item, score };
  });

  return scored
    .filter(({ score }) => score > 0)
    .sort((a, b) => b.score - a.score)
    .map(({ item }) => item);
}
