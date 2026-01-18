'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { getEntryById } from '@early-help/api-client';
import type { Entry } from '@early-help/types';
import '../../../lib/supabase';

export default function EntryPage() {
  const params = useParams();
  const router = useRouter();
  const [entry, setEntry] = useState<Entry | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (params.id) {
      loadEntry(params.id as string);
    }
  }, [params.id]);

  async function loadEntry(id: string) {
    try {
      const data = await getEntryById(id);
      if (!data) {
        router.push('/library');
        return;
      }
      setEntry(data);
    } catch (error) {
      console.error('Error loading entry:', error);
      router.push('/library');
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-16">
        <div className="text-center">Loading...</div>
      </div>
    );
  }

  if (!entry) {
    return null;
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="max-w-4xl mx-auto">
        <Link
          href="/library"
          className="inline-flex items-center text-primary-600 dark:text-primary-400 hover:underline mb-6"
        >
          ← Back to Library
        </Link>

        <article className="card">
          <div className="mb-6">
            <h1 className="text-4xl font-bold mb-4">{entry.title}</h1>
            <p className="text-xl text-gray-600 dark:text-gray-400 mb-4">
              {entry.summary}
            </p>
            <div className="flex flex-wrap gap-2 mb-4">
              {entry.tags.map((tag) => (
                <span
                  key={tag}
                  className="px-3 py-1 bg-primary-100 dark:bg-primary-900 text-primary-700 dark:text-primary-300 text-sm rounded-full"
                >
                  {tag}
                </span>
              ))}
            </div>
            <div className="text-sm text-gray-500 dark:text-gray-400">
              Last updated: {new Date(entry.last_updated).toLocaleDateString()}
            </div>
          </div>

          <div className="prose-custom">
            <ReactMarkdown remarkPlugins={[remarkGfm]}>
              {entry.body}
            </ReactMarkdown>
          </div>
        </article>

        <div className="mt-8 card bg-yellow-50 dark:bg-yellow-900/20 border-yellow-200 dark:border-yellow-800">
          <h3 className="text-lg font-semibold mb-2">Need Help?</h3>
          <p className="mb-4">
            If you're concerned about someone, don't navigate this alone.
          </p>
          <Link href="/help-navigator" className="btn-primary">
            Find Local Support
          </Link>
        </div>
      </div>
    </div>
  );
}
