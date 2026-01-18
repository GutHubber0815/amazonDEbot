import { filterByCategory, filterByTags, filterByRole, filterByZipCode, getUniqueTags } from '../filters';
import type { Entry, SupportContact } from '@early-help/types';

describe('filterByCategory', () => {
  const mockEntries: Entry[] = [
    {
      id: '1',
      category_id: 'cat1',
      title: 'Entry 1',
      summary: '',
      body: '',
      tags: [],
      published: true,
      order: 1,
      created_at: '2024-01-01',
      updated_at: '2024-01-01',
      last_updated: '2024-01-01',
    },
    {
      id: '2',
      category_id: 'cat2',
      title: 'Entry 2',
      summary: '',
      body: '',
      tags: [],
      published: true,
      order: 2,
      created_at: '2024-01-01',
      updated_at: '2024-01-01',
      last_updated: '2024-01-01',
    },
  ];

  it('should filter by category', () => {
    const result = filterByCategory(mockEntries, 'cat1');
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe('1');
  });

  it('should return all when no category specified', () => {
    const result = filterByCategory(mockEntries, undefined);
    expect(result).toEqual(mockEntries);
  });
});

describe('filterByTags', () => {
  const mockEntries: Entry[] = [
    {
      id: '1',
      category_id: 'cat1',
      title: 'Entry 1',
      summary: '',
      body: '',
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
      title: 'Entry 2',
      summary: '',
      body: '',
      tags: ['digital', 'safety'],
      published: true,
      order: 2,
      created_at: '2024-01-01',
      updated_at: '2024-01-01',
      last_updated: '2024-01-01',
    },
  ];

  it('should filter by tags', () => {
    const result = filterByTags(mockEntries, ['prevention']);
    expect(result).toHaveLength(1);
    expect(result[0].id).toBe('1');
  });

  it('should match any tag', () => {
    const result = filterByTags(mockEntries, ['prevention', 'digital']);
    expect(result).toHaveLength(2);
  });
});

describe('filterByRole', () => {
  const mockContacts: SupportContact[] = [
    {
      id: '1',
      name: 'Parent Support',
      role: 'parent',
      region: 'Berlin',
      zip_codes: ['10115'],
      description: '',
      category: '',
      created_at: '2024-01-01',
      updated_at: '2024-01-01',
    },
    {
      id: '2',
      name: 'All Support',
      role: 'all',
      region: 'Berlin',
      zip_codes: ['10115'],
      description: '',
      category: '',
      created_at: '2024-01-01',
      updated_at: '2024-01-01',
    },
  ];

  it('should filter by role', () => {
    const result = filterByRole(mockContacts, 'parent');
    expect(result).toHaveLength(2); // parent + all
  });
});

describe('filterByZipCode', () => {
  const mockContacts: SupportContact[] = [
    {
      id: '1',
      name: 'Berlin Support',
      role: 'all',
      region: 'Berlin',
      zip_codes: ['10115', '10117'],
      description: '',
      category: '',
      created_at: '2024-01-01',
      updated_at: '2024-01-01',
    },
  ];

  it('should filter by exact ZIP code', () => {
    const result = filterByZipCode(mockContacts, '10115');
    expect(result).toHaveLength(1);
  });

  it('should filter by ZIP prefix', () => {
    const result = filterByZipCode(mockContacts, '101');
    expect(result).toHaveLength(1);
  });
});

describe('getUniqueTags', () => {
  const mockEntries: Entry[] = [
    {
      id: '1',
      category_id: 'cat1',
      title: 'Entry 1',
      summary: '',
      body: '',
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
      title: 'Entry 2',
      summary: '',
      body: '',
      tags: ['prevention', 'digital'],
      published: true,
      order: 2,
      created_at: '2024-01-01',
      updated_at: '2024-01-01',
      last_updated: '2024-01-01',
    },
  ];

  it('should return unique tags sorted', () => {
    const result = getUniqueTags(mockEntries);
    expect(result).toEqual(['awareness', 'digital', 'prevention']);
  });
});
