'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { getCurrentUser, getAllEntries, deleteEntry, getCategories } from '@early-help/api-client';
import type { Entry, Category } from '@early-help/types';
import '../../../lib/supabase';

export default function AdminEntriesPage() {
  const router = useRouter();
  const [entries, setEntries] = useState<Entry[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkAuthAndLoad();
  }, []);

  async function checkAuthAndLoad() {
    try {
      const user = await getCurrentUser();
      if (!user || user.role !== 'admin') {
        router.push('/admin');
        return;
      }
      await loadData();
    } catch (error) {
      router.push('/admin');
    } finally {
      setLoading(false);
    }
  }

  async function loadData() {
    const [entriesData, categoriesData] = await Promise.all([
      getAllEntries(),
      getCategories(),
    ]);
    setEntries(entriesData);
    setCategories(categoriesData);
  }

  async function handleDelete(id: string, title: string) {
    if (!confirm(`Delete "${title}"?`)) return;

    try {
      await deleteEntry(id);
      setEntries(entries.filter(e => e.id !== id));
    } catch (error) {
      alert('Error deleting entry');
    }
  }

  function getCategoryName(categoryId: string) {
    return categories.find(c => c.id === categoryId)?.name || 'Unknown';
  }

  if (loading) {
    return <div className="container mx-auto px-4 py-16">Loading...</div>;
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="max-w-6xl mx-auto">
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-4xl font-bold">Manage Entries</h1>
          <div className="space-x-4">
            <Link href="/admin/entries/new" className="btn-primary">
              + New Entry
            </Link>
            <Link href="/admin/dashboard" className="btn-secondary">
              Back to Dashboard
            </Link>
          </div>
        </div>

        <div className="space-y-4">
          {entries.map((entry) => (
            <div key={entry.id} className="card">
              <div className="flex justify-between items-start">
                <div className="flex-1">
                  <div className="flex items-center gap-3 mb-2">
                    <h3 className="text-xl font-semibold">{entry.title}</h3>
                    {!entry.published && (
                      <span className="px-2 py-1 bg-yellow-100 dark:bg-yellow-900 text-yellow-800 dark:text-yellow-200 text-xs rounded">
                        Draft
                      </span>
                    )}
                  </div>
                  <p className="text-gray-600 dark:text-gray-400 mb-2">
                    {entry.summary}
                  </p>
                  <div className="flex gap-4 text-sm text-gray-500 dark:text-gray-400">
                    <span>Category: {getCategoryName(entry.category_id)}</span>
                    <span>Updated: {new Date(entry.updated_at).toLocaleDateString()}</span>
                  </div>
                </div>
                <div className="flex gap-2">
                  <Link
                    href={`/admin/entries/${entry.id}`}
                    className="px-3 py-1 bg-blue-600 text-white rounded hover:bg-blue-700 text-sm"
                  >
                    Edit
                  </Link>
                  <button
                    onClick={() => handleDelete(entry.id, entry.title)}
                    className="px-3 py-1 bg-red-600 text-white rounded hover:bg-red-700 text-sm"
                  >
                    Delete
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
