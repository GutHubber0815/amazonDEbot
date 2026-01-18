'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { getEntries, getCategories } from '@early-help/api-client';
import { searchEntries, filterByCategory, filterByTags, sortEntries } from '@early-help/utils';
import type { Entry, Category } from '@early-help/types';
import '../../../lib/supabase'; // Initialize Supabase

export default function LibraryPage() {
  const [entries, setEntries] = useState<Entry[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [filteredEntries, setFilteredEntries] = useState<Entry[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('');
  const [selectedTags, setSelectedTags] = useState<string[]>([]);

  useEffect(() => {
    loadData();
  }, []);

  useEffect(() => {
    applyFilters();
  }, [entries, searchQuery, selectedCategory, selectedTags]);

  async function loadData() {
    try {
      const [entriesData, categoriesData] = await Promise.all([
        getEntries(),
        getCategories(),
      ]);
      setEntries(entriesData);
      setCategories(categoriesData);
    } catch (error) {
      console.error('Error loading data:', error);
    } finally {
      setLoading(false);
    }
  }

  function applyFilters() {
    let result = entries;

    // Apply search
    if (searchQuery) {
      result = searchEntries(result, searchQuery);
    }

    // Apply category filter
    if (selectedCategory) {
      result = filterByCategory(result, selectedCategory);
    }

    // Apply tag filters
    if (selectedTags.length > 0) {
      result = filterByTags(result, selectedTags);
    }

    // Sort
    result = sortEntries(result);

    setFilteredEntries(result);
  }

  const allTags = Array.from(
    new Set(entries.flatMap((entry) => entry.tags))
  ).sort();

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-16">
        <div className="text-center">Loading...</div>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="max-w-6xl mx-auto">
        <h1 className="text-4xl font-bold mb-4">Content Library</h1>
        <p className="text-lg text-gray-600 dark:text-gray-400 mb-8">
          Educational resources on prevention, communication, and support
        </p>

        {/* Search and Filters */}
        <div className="card mb-8">
          <div className="space-y-4">
            {/* Search */}
            <div>
              <label className="block text-sm font-medium mb-2">Search</label>
              <input
                type="text"
                className="input"
                placeholder="Search articles..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
              />
            </div>

            {/* Category Filter */}
            <div>
              <label className="block text-sm font-medium mb-2">Category</label>
              <select
                className="input"
                value={selectedCategory}
                onChange={(e) => setSelectedCategory(e.target.value)}
              >
                <option value="">All Categories</option>
                {categories.map((cat) => (
                  <option key={cat.id} value={cat.id}>
                    {cat.name}
                  </option>
                ))}
              </select>
            </div>

            {/* Tag Filter */}
            {allTags.length > 0 && (
              <div>
                <label className="block text-sm font-medium mb-2">Tags</label>
                <div className="flex flex-wrap gap-2">
                  {allTags.map((tag) => (
                    <button
                      key={tag}
                      onClick={() => {
                        setSelectedTags((prev) =>
                          prev.includes(tag)
                            ? prev.filter((t) => t !== tag)
                            : [...prev, tag]
                        );
                      }}
                      className={`px-3 py-1 rounded-full text-sm transition-colors ${
                        selectedTags.includes(tag)
                          ? 'bg-primary-600 text-white'
                          : 'bg-gray-200 dark:bg-slate-700 text-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-slate-600'
                      }`}
                    >
                      {tag}
                    </button>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Results */}
        <div className="mb-4 text-sm text-gray-600 dark:text-gray-400">
          Showing {filteredEntries.length} of {entries.length} articles
        </div>

        <div className="grid gap-6">
          {filteredEntries.map((entry) => (
            <article key={entry.id} className="card hover:shadow-lg transition-shadow">
              <div className="flex justify-between items-start mb-2">
                <h2 className="text-2xl font-semibold">
                  <Link
                    href={`/library/${entry.id}`}
                    className="hover:text-primary-600 dark:hover:text-primary-400"
                  >
                    {entry.title}
                  </Link>
                </h2>
                <span className="text-xs text-gray-500 dark:text-gray-400">
                  {new Date(entry.last_updated).toLocaleDateString()}
                </span>
              </div>
              <p className="text-gray-600 dark:text-gray-400 mb-4">{entry.summary}</p>
              <div className="flex flex-wrap gap-2">
                {entry.tags.map((tag) => (
                  <span
                    key={tag}
                    className="px-2 py-1 bg-gray-100 dark:bg-slate-700 text-gray-700 dark:text-gray-300 text-xs rounded"
                  >
                    {tag}
                  </span>
                ))}
              </div>
            </article>
          ))}

          {filteredEntries.length === 0 && (
            <div className="text-center py-12 text-gray-500 dark:text-gray-400">
              No articles found matching your criteria.
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
