import { searchEntries, searchGlossaryItems, fuzzySearch } from '../search';
import type { Entry, GlossaryItem } from '@early-help/types';

describe('searchEntries', () => {
  const mockEntries: Entry[] = [
    {
      id: '1',
      category_id: 'cat1',
      title: 'Understanding Warning Signs',
      summary: 'Learn to recognize early indicators',
      body: 'Content about radicalization warning signs',
      tags: ['prevention', 'awareness'],
      published: true,
      order: 1,
      created_at: '2024-01-01',
      updated_at: '2024-01-01',
      last_updated: '2024-01-01',
    },
    {
      id: '2',
      category_id: 'cat1',
      title: 'Online Safety Tips',
      summary: 'Protecting your family online',
      body: 'Social media safety guidelines',
      tags: ['digital', 'safety'],
      published: true,
      order: 2,
      created_at: '2024-01-01',
      updated_at: '2024-01-01',
      last_updated: '2024-01-01',
    },
  ];

  it('should return all entries when query is empty', () => {
    expect(searchEntries(mockEntries, '')).toEqual(mockEntries);
    expect(searchEntries(mockEntries, '   ')).toEqual(mockEntries);
  });

  it('should search by title', () => {
    const result = searchEntries(mockEntries, 'warning');
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe('1');
  });

  it('should search by summary', () => {
    const result = searchEntries(mockEntries, 'protecting');
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe('2');
  });

  it('should search by body', () => {
    const result = searchEntries(mockEntries, 'radicalization');
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe('1');
  });

  it('should search by tags', () => {
    const result = searchEntries(mockEntries, 'digital');
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe('2');
  });

  it('should be case insensitive', () => {
    const result = searchEntries(mockEntries, 'WARNING');
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe('1');
  });
});

describe('searchGlossaryItems', () => {
  const mockItems: GlossaryItem[] = [
    {
      id: '1',
      term: 'Echo Chamber',
      meaning: 'An environment where beliefs are amplified',
      context: 'Social media algorithms create echo chambers',
      examples: 'Example text',
      related_terms: ['filter bubble', 'confirmation bias'],
      created_at: '2024-01-01',
      updated_at: '2024-01-01',
    },
  ];

  it('should search by term', () => {
    const result = searchGlossaryItems(mockItems, 'echo');
    expect(result).toHaveLength(1);
  });

  it('should search by related terms', () => {
    const result = searchGlossaryItems(mockItems, 'filter bubble');
    expect(result).toHaveLength(1);
  });
});

describe('fuzzySearch', () => {
  interface TestItem {
    title: string;
    description: string;
  }

  const mockItems: TestItem[] = [
    { title: 'Exact Match', description: 'test' },
    { title: 'Starts with test', description: 'other' },
    { title: 'Contains test here', description: 'other' },
    { title: 'No match', description: 'nothing' },
  ];

  it('should prioritize exact matches', () => {
    const result = fuzzySearch(mockItems, 'exact match', ['title']);
    expect(result[0].title).toBe('Exact Match');
  });

  it('should handle empty query', () => {
    const result = fuzzySearch(mockItems, '', ['title']);
    expect(result).toEqual(mockItems);
  });

  it('should filter non-matching items', () => {
    const result = fuzzySearch(mockItems, 'test', ['title']);
    expect(result).toHaveLength(3);
    expect(result.find((item) => item.title === 'No match')).toBeUndefined();
  });
});
