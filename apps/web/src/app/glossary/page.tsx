'use client';

import { useEffect, useState } from 'react';
import { getGlossaryItems } from '@early-help/api-client';
import { searchGlossaryItems } from '@early-help/utils';
import type { GlossaryItem } from '@early-help/types';
import '../../lib/supabase';

export default function GlossaryPage() {
  const [items, setItems] = useState<GlossaryItem[]>([]);
  const [filteredItems, setFilteredItems] = useState<GlossaryItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [expandedId, setExpandedId] = useState<string | null>(null);

  useEffect(() => {
    loadItems();
  }, []);

  useEffect(() => {
    applyFilters();
  }, [items, searchQuery]);

  async function loadItems() {
    try {
      const data = await getGlossaryItems();
      setItems(data);
    } catch (error) {
      console.error('Error loading glossary:', error);
    } finally {
      setLoading(false);
    }
  }

  function applyFilters() {
    let result = items;

    if (searchQuery) {
      result = searchGlossaryItems(result, searchQuery);
    }

    setFilteredItems(result);
  }

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-16">
        <div className="text-center">Loading...</div>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold mb-4">Codes & Memes Lexicon</h1>
        <p className="text-lg text-gray-600 dark:text-gray-400 mb-8">
          Understanding symbols, language, and online extremist culture
        </p>

        {/* Search */}
        <div className="card mb-8">
          <label className="block text-sm font-medium mb-2">Search Terms</label>
          <input
            type="text"
            className="input"
            placeholder="Search for codes, memes, or symbols..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>

        {/* Warning */}
        <div className="card bg-amber-50 dark:bg-amber-900/20 border-amber-200 dark:border-amber-800 mb-8">
          <p className="text-sm">
            <strong>Important:</strong> Many terms have innocent uses. Context is crucial.
            Not every use of these symbols or phrases indicates extremism.
          </p>
        </div>

        {/* Results */}
        <div className="mb-4 text-sm text-gray-600 dark:text-gray-400">
          Showing {filteredItems.length} of {items.length} terms
        </div>

        <div className="space-y-4">
          {filteredItems.map((item) => {
            const isExpanded = expandedId === item.id;

            return (
              <div key={item.id} className="card">
                <button
                  onClick={() => setExpandedId(isExpanded ? null : item.id)}
                  className="w-full text-left"
                >
                  <div className="flex justify-between items-start">
                    <h3 className="text-xl font-semibold text-primary-600 dark:text-primary-400">
                      {item.term}
                    </h3>
                    <span className="text-2xl">
                      {isExpanded ? '−' : '+'}
                    </span>
                  </div>
                  <p className="text-gray-700 dark:text-gray-300 mt-2">
                    {item.meaning}
                  </p>
                </button>

                {isExpanded && (
                  <div className="mt-4 pt-4 border-t border-gray-200 dark:border-slate-700 space-y-4">
                    <div>
                      <h4 className="font-semibold mb-2">Context</h4>
                      <p className="text-gray-700 dark:text-gray-300">
                        {item.context}
                      </p>
                    </div>

                    <div>
                      <h4 className="font-semibold mb-2">Examples</h4>
                      <p className="text-gray-700 dark:text-gray-300">
                        {item.examples}
                      </p>
                    </div>

                    {item.related_terms.length > 0 && (
                      <div>
                        <h4 className="font-semibold mb-2">Related Terms</h4>
                        <div className="flex flex-wrap gap-2">
                          {item.related_terms.map((term) => (
                            <span
                              key={term}
                              className="px-2 py-1 bg-gray-100 dark:bg-slate-700 text-sm rounded"
                            >
                              {term}
                            </span>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                )}
              </div>
            );
          })}

          {filteredItems.length === 0 && (
            <div className="text-center py-12 text-gray-500 dark:text-gray-400">
              No terms found matching your search.
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
