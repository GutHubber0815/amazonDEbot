'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { getCurrentUser, signOut } from '@early-help/api-client';
import { getEntries, getCategories, getGlossaryItems, getSupportContacts } from '@early-help/api-client';
import type { User } from '@early-help/types';
import '../../../lib/supabase';

export default function AdminDashboardPage() {
  const router = useRouter();
  const [user, setUser] = useState<User | null>(null);
  const [stats, setStats] = useState({
    entries: 0,
    categories: 0,
    glossaryItems: 0,
    supportContacts: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkAuth();
  }, []);

  async function checkAuth() {
    try {
      const currentUser = await getCurrentUser();
      if (!currentUser || currentUser.role !== 'admin') {
        router.push('/admin');
        return;
      }
      setUser(currentUser);
      await loadStats();
    } catch (error) {
      router.push('/admin');
    } finally {
      setLoading(false);
    }
  }

  async function loadStats() {
    try {
      const [entries, categories, glossary, contacts] = await Promise.all([
        getEntries(),
        getCategories(),
        getGlossaryItems(),
        getSupportContacts(),
      ]);

      setStats({
        entries: entries.length,
        categories: categories.length,
        glossaryItems: glossary.length,
        supportContacts: contacts.length,
      });
    } catch (error) {
      console.error('Error loading stats:', error);
    }
  }

  async function handleSignOut() {
    await signOut();
    router.push('/admin');
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
      <div className="max-w-6xl mx-auto">
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-4xl font-bold mb-2">Admin Dashboard</h1>
            <p className="text-gray-600 dark:text-gray-400">
              Logged in as: {user?.email}
            </p>
          </div>
          <button onClick={handleSignOut} className="btn-secondary">
            Sign Out
          </button>
        </div>

        {/* Stats */}
        <div className="grid md:grid-cols-4 gap-6 mb-8">
          <div className="card">
            <div className="text-3xl font-bold text-primary-600 dark:text-primary-400">
              {stats.entries}
            </div>
            <div className="text-gray-600 dark:text-gray-400">Entries</div>
          </div>
          <div className="card">
            <div className="text-3xl font-bold text-primary-600 dark:text-primary-400">
              {stats.categories}
            </div>
            <div className="text-gray-600 dark:text-gray-400">Categories</div>
          </div>
          <div className="card">
            <div className="text-3xl font-bold text-primary-600 dark:text-primary-400">
              {stats.glossaryItems}
            </div>
            <div className="text-gray-600 dark:text-gray-400">Glossary Items</div>
          </div>
          <div className="card">
            <div className="text-3xl font-bold text-primary-600 dark:text-primary-400">
              {stats.supportContacts}
            </div>
            <div className="text-gray-600 dark:text-gray-400">Support Contacts</div>
          </div>
        </div>

        {/* Management Links */}
        <div className="grid md:grid-cols-2 gap-6">
          <Link href="/admin/entries" className="card hover:shadow-lg transition-shadow">
            <h2 className="text-2xl font-semibold mb-2">📝 Manage Entries</h2>
            <p className="text-gray-600 dark:text-gray-400">
              Create, edit, and manage content library entries
            </p>
          </Link>

          <Link href="/admin/categories" className="card hover:shadow-lg transition-shadow">
            <h2 className="text-2xl font-semibold mb-2">📁 Manage Categories</h2>
            <p className="text-gray-600 dark:text-gray-400">
              Organize entries into categories
            </p>
          </Link>

          <Link href="/admin/glossary" className="card hover:shadow-lg transition-shadow">
            <h2 className="text-2xl font-semibold mb-2">📖 Manage Glossary</h2>
            <p className="text-gray-600 dark:text-gray-400">
              Edit codes and memes lexicon
            </p>
          </Link>

          <Link href="/admin/contacts" className="card hover:shadow-lg transition-shadow">
            <h2 className="text-2xl font-semibold mb-2">📞 Manage Support Contacts</h2>
            <p className="text-gray-600 dark:text-gray-400">
              Update help navigator resources
            </p>
          </Link>
        </div>

        {/* Quick Info */}
        <div className="card mt-8 bg-blue-50 dark:bg-blue-900/20 border-blue-200 dark:border-blue-800">
          <h3 className="font-semibold mb-2">Admin Features</h3>
          <ul className="text-sm space-y-1">
            <li>✓ Full CRUD operations on all content</li>
            <li>✓ Markdown editor with preview</li>
            <li>✓ Entry versioning and history</li>
            <li>✓ Row-level security enforced</li>
          </ul>
        </div>
      </div>
    </div>
  );
}
