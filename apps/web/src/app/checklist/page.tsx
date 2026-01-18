'use client';

import { useEffect, useState } from 'react';
import { DEFAULT_CHECKLIST_ITEMS, calculateChecklistResult } from '@early-help/utils';
import { getChecklistProgress, saveChecklistProgress } from '@early-help/utils';
import { browserStorage } from '@/lib/storage';
import type { ChecklistProgress, ChecklistResult } from '@early-help/types';

export default function ChecklistPage() {
  const [progress, setProgress] = useState<ChecklistProgress>({});
  const [result, setResult] = useState<ChecklistResult | null>(null);
  const [showResults, setShowResults] = useState(false);

  useEffect(() => {
    loadProgress();
  }, []);

  useEffect(() => {
    if (Object.keys(progress).length > 0) {
      saveChecklistProgress(browserStorage, progress);
    }
  }, [progress]);

  async function loadProgress() {
    const saved = await getChecklistProgress(browserStorage);
    setProgress(saved);
  }

  function toggleItem(id: string) {
    setProgress((prev) => ({
      ...prev,
      [id]: !prev[id],
    }));
    setShowResults(false);
  }

  function handleSubmit() {
    const calculatedResult = calculateChecklistResult(progress);
    setResult(calculatedResult);
    setShowResults(true);
  }

  function resetChecklist() {
    setProgress({});
    setResult(null);
    setShowResults(false);
    saveChecklistProgress(browserStorage, {});
  }

  const checkedCount = Object.values(progress).filter(Boolean).length;

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold mb-4">Warning Signs Checklist</h1>
        <p className="text-lg text-gray-600 dark:text-gray-400 mb-8">
          A self-guided assessment to help identify potential concerns. This is educational,
          not diagnostic.
        </p>

        {/* Privacy Notice */}
        <div className="card bg-blue-50 dark:bg-blue-900/20 border-blue-200 dark:border-blue-800 mb-8">
          <div className="flex items-start gap-3">
            <span className="text-2xl">🔒</span>
            <div>
              <h3 className="font-semibold mb-2">Your Privacy</h3>
              <p className="text-sm">
                Your checklist progress is saved <strong>locally on your device only</strong>.
                No data is sent to servers. You can clear it anytime by resetting the checklist.
              </p>
            </div>
          </div>
        </div>

        {/* Checklist Items */}
        <div className="card mb-8">
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-2xl font-semibold">
              Items Checked: {checkedCount} / {DEFAULT_CHECKLIST_ITEMS.length}
            </h2>
            <button onClick={resetChecklist} className="btn-secondary text-sm">
              Reset
            </button>
          </div>

          <div className="space-y-4">
            {DEFAULT_CHECKLIST_ITEMS.map((item) => (
              <div
                key={item.id}
                className="border border-gray-200 dark:border-slate-700 rounded-lg p-4 hover:bg-gray-50 dark:hover:bg-slate-800/50 transition-colors"
              >
                <label className="flex items-start gap-3 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={progress[item.id] || false}
                    onChange={() => toggleItem(item.id)}
                    className="mt-1 w-5 h-5 rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                  />
                  <div className="flex-1">
                    <div className="font-medium text-gray-900 dark:text-white mb-2">
                      {item.text}
                    </div>
                    <div className="text-sm text-gray-600 dark:text-gray-400">
                      {item.explanation}
                    </div>
                  </div>
                </label>
              </div>
            ))}
          </div>

          <div className="mt-6">
            <button onClick={handleSubmit} className="btn-primary w-full">
              See Results & Next Steps
            </button>
          </div>
        </div>

        {/* Results */}
        {showResults && result && (
          <div className="card bg-yellow-50 dark:bg-yellow-900/20 border-yellow-200 dark:border-yellow-800">
            <h2 className="text-2xl font-semibold mb-4">Your Results</h2>

            <div className="mb-6">
              <div className="text-lg font-medium mb-2">
                {result.checkedCount} of {result.totalCount} warning signs noted
              </div>
              <p className="text-gray-700 dark:text-gray-300">{result.interpretation}</p>
            </div>

            <div className="mb-6">
              <h3 className="text-xl font-semibold mb-3">Recommended Next Steps</h3>
              <ol className="list-decimal list-inside space-y-2">
                {result.nextSteps.map((step, index) => (
                  <li key={index} className="text-gray-700 dark:text-gray-300">
                    {step}
                  </li>
                ))}
              </ol>
            </div>

            <div className="pt-4 border-t border-yellow-300 dark:border-yellow-700">
              <p className="text-sm mb-4">
                <strong>Remember:</strong> This is an educational tool, not a diagnostic instrument.
                When in doubt, consult professionals.
              </p>
              <a href="/help-navigator" className="btn-primary inline-block">
                Find Professional Support
              </a>
            </div>
          </div>
        )}

        {/* Educational Note */}
        <div className="card mt-8">
          <h3 className="text-lg font-semibold mb-3">About This Checklist</h3>
          <div className="text-sm text-gray-700 dark:text-gray-300 space-y-2">
            <p>
              This checklist is based on research into radicalization warning signs. However:
            </p>
            <ul className="list-disc list-inside space-y-1 ml-4">
              <li>Many signs can be normal adolescent behavior</li>
              <li>Context and combination matter more than individual items</li>
              <li>No checklist can replace professional assessment</li>
              <li>Early intervention is most effective</li>
            </ul>
            <p className="mt-4">
              If you checked multiple items, this doesn't mean someone is being radicalized.
              It means it's worth having conversations and staying engaged.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
