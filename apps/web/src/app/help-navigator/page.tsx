'use client';

import { useEffect, useState } from 'react';
import { getSupportContacts } from '@early-help/api-client';
import { filterByRole, filterByZipCode } from '@early-help/utils';
import type { SupportContact } from '@early-help/types';
import '../../lib/supabase';

export default function HelpNavigatorPage() {
  const [contacts, setContacts] = useState<SupportContact[]>([]);
  const [filteredContacts, setFilteredContacts] = useState<SupportContact[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedRole, setSelectedRole] = useState<'parent' | 'teacher' | 'social_worker' | ''>('');
  const [zipCode, setZipCode] = useState('');

  useEffect(() => {
    loadContacts();
  }, []);

  useEffect(() => {
    applyFilters();
  }, [contacts, selectedRole, zipCode]);

  async function loadContacts() {
    try {
      const data = await getSupportContacts();
      setContacts(data);
    } catch (error) {
      console.error('Error loading support contacts:', error);
    } finally {
      setLoading(false);
    }
  }

  function applyFilters() {
    let result = contacts;

    if (selectedRole) {
      result = filterByRole(result, selectedRole);
    }

    if (zipCode) {
      result = filterByZipCode(result, zipCode);
    }

    setFilteredContacts(result);
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
        <h1 className="text-4xl font-bold mb-4">Help Navigator</h1>
        <p className="text-lg text-gray-600 dark:text-gray-400 mb-8">
          Find local support contacts based on your role and region
        </p>

        {/* Emergency Notice */}
        <div className="card bg-red-50 dark:bg-red-900/20 border-red-200 dark:border-red-800 mb-8">
          <h3 className="text-lg font-semibold text-red-900 dark:text-red-200 mb-2">
            🚨 Emergency Situations
          </h3>
          <p className="text-red-800 dark:text-red-300 mb-3">
            If there is an immediate threat of violence or danger:
          </p>
          <ul className="space-y-1 text-red-800 dark:text-red-300">
            <li><strong>Police Emergency:</strong> 110</li>
            <li><strong>Youth Crisis Helpline:</strong> 116 111 (Nummer gegen Kummer)</li>
          </ul>
        </div>

        {/* Filters */}
        <div className="card mb-8">
          <h2 className="text-2xl font-semibold mb-4">Find Support Near You</h2>
          <div className="grid md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium mb-2">Your Role</label>
              <select
                className="input"
                value={selectedRole}
                onChange={(e) => setSelectedRole(e.target.value as any)}
              >
                <option value="">Select your role...</option>
                <option value="parent">Parent / Guardian</option>
                <option value="teacher">Teacher / Educator</option>
                <option value="social_worker">Social Worker / Counselor</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium mb-2">
                Your ZIP Code (German)
              </label>
              <input
                type="text"
                className="input"
                placeholder="e.g., 10115"
                value={zipCode}
                onChange={(e) => setZipCode(e.target.value)}
                maxLength={5}
              />
              <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
                We'll show contacts in your region
              </p>
            </div>
          </div>
        </div>

        {/* Results */}
        <div className="mb-4 text-sm text-gray-600 dark:text-gray-400">
          {filteredContacts.length === 0 ? (
            <p>Select your role and enter your ZIP code to find support contacts.</p>
          ) : (
            <p>Found {filteredContacts.length} support contact{filteredContacts.length !== 1 ? 's' : ''}</p>
          )}
        </div>

        <div className="grid gap-6">
          {filteredContacts.map((contact) => (
            <div key={contact.id} className="card hover:shadow-lg transition-shadow">
              <div className="flex justify-between items-start mb-3">
                <h3 className="text-xl font-semibold">{contact.name}</h3>
                <span className="px-3 py-1 bg-primary-100 dark:bg-primary-900 text-primary-700 dark:text-primary-300 text-sm rounded-full">
                  {contact.category}
                </span>
              </div>

              <p className="text-gray-700 dark:text-gray-300 mb-4">
                {contact.description}
              </p>

              <div className="space-y-2 text-sm">
                <div className="flex items-center gap-2">
                  <span className="font-medium">Region:</span>
                  <span className="text-gray-600 dark:text-gray-400">
                    {contact.region} ({contact.zip_codes.join(', ')})
                  </span>
                </div>

                {contact.phone && (
                  <div className="flex items-center gap-2">
                    <span className="font-medium">Phone:</span>
                    <a
                      href={`tel:${contact.phone}`}
                      className="text-primary-600 dark:text-primary-400 hover:underline"
                    >
                      {contact.phone}
                    </a>
                  </div>
                )}

                {contact.email && (
                  <div className="flex items-center gap-2">
                    <span className="font-medium">Email:</span>
                    <a
                      href={`mailto:${contact.email}`}
                      className="text-primary-600 dark:text-primary-400 hover:underline"
                    >
                      {contact.email}
                    </a>
                  </div>
                )}

                {contact.website && (
                  <div className="flex items-center gap-2">
                    <span className="font-medium">Website:</span>
                    <a
                      href={contact.website}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-primary-600 dark:text-primary-400 hover:underline"
                    >
                      Visit website →
                    </a>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>

        {/* Privacy Note */}
        <div className="card mt-8 bg-blue-50 dark:bg-blue-900/20 border-blue-200 dark:border-blue-800">
          <h3 className="font-semibold mb-2">🔒 Privacy Note</h3>
          <p className="text-sm">
            The contacts shown are public resources. No record is kept of your search.
            When you contact these organizations, their own privacy policies apply.
          </p>
        </div>
      </div>
    </div>
  );
}
