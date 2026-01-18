import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, ScrollView, Pressable } from 'react-native';
import { DEFAULT_CHECKLIST_ITEMS, calculateChecklistResult } from '@early-help/utils';
import { getChecklistProgress, saveChecklistProgress } from '@early-help/utils';
import { mobileStorage } from '../src/lib/storage';
import type { ChecklistProgress, ChecklistResult } from '@early-help/types';

export default function ChecklistScreen() {
  const [progress, setProgress] = useState<ChecklistProgress>({});
  const [result, setResult] = useState<ChecklistResult | null>(null);
  const [showResults, setShowResults] = useState(false);

  useEffect(() => {
    loadProgress();
  }, []);

  useEffect(() => {
    if (Object.keys(progress).length > 0) {
      saveChecklistProgress(mobileStorage, progress);
    }
  }, [progress]);

  async function loadProgress() {
    const saved = await getChecklistProgress(mobileStorage);
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

  const checkedCount = Object.values(progress).filter(Boolean).length;

  return (
    <ScrollView style={styles.container}>
      <View style={styles.privacy}>
        <Text style={styles.privacyTitle}>🔒 Your Privacy</Text>
        <Text style={styles.privacyText}>
          Saved locally on your device only. No data sent to servers.
        </Text>
      </View>

      <View style={styles.header}>
        <Text style={styles.headerText}>
          Items Checked: {checkedCount} / {DEFAULT_CHECKLIST_ITEMS.length}
        </Text>
      </View>

      <View style={styles.items}>
        {DEFAULT_CHECKLIST_ITEMS.map((item) => (
          <Pressable
            key={item.id}
            style={styles.itemCard}
            onPress={() => toggleItem(item.id)}
          >
            <View style={styles.itemHeader}>
              <View style={styles.checkbox}>
                {progress[item.id] && <Text style={styles.checkmark}>✓</Text>}
              </View>
              <Text style={styles.itemText}>{item.text}</Text>
            </View>
            <Text style={styles.itemExplanation}>{item.explanation}</Text>
          </Pressable>
        ))}
      </View>

      <Pressable style={styles.submitButton} onPress={handleSubmit}>
        <Text style={styles.submitButtonText}>See Results & Next Steps</Text>
      </Pressable>

      {showResults && result && (
        <View style={styles.results}>
          <Text style={styles.resultsTitle}>Your Results</Text>
          <Text style={styles.resultsCount}>
            {result.checkedCount} of {result.totalCount} warning signs noted
          </Text>
          <Text style={styles.resultsInterpretation}>{result.interpretation}</Text>

          <Text style={styles.nextStepsTitle}>Recommended Next Steps:</Text>
          {result.nextSteps.map((step, index) => (
            <Text key={index} style={styles.nextStepItem}>
              {index + 1}. {step}
            </Text>
          ))}
        </View>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f9fafb',
  },
  privacy: {
    backgroundColor: '#dbeafe',
    margin: 16,
    padding: 16,
    borderRadius: 12,
  },
  privacyTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 4,
  },
  privacyText: {
    fontSize: 13,
    color: '#1e40af',
  },
  header: {
    backgroundColor: '#fff',
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#e5e7eb',
  },
  headerText: {
    fontSize: 18,
    fontWeight: '600',
  },
  items: {
    padding: 16,
    gap: 12,
  },
  itemCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    borderWidth: 1,
    borderColor: '#e5e7eb',
  },
  itemHeader: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: 8,
  },
  checkbox: {
    width: 24,
    height: 24,
    borderRadius: 6,
    borderWidth: 2,
    borderColor: '#0ea5e9',
    marginRight: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  checkmark: {
    fontSize: 16,
    color: '#0ea5e9',
    fontWeight: 'bold',
  },
  itemText: {
    flex: 1,
    fontSize: 16,
    fontWeight: '500',
  },
  itemExplanation: {
    fontSize: 14,
    color: '#64748b',
    marginLeft: 36,
  },
  submitButton: {
    backgroundColor: '#0ea5e9',
    margin: 16,
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
  },
  submitButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  results: {
    backgroundColor: '#fef3c7',
    margin: 16,
    padding: 16,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: '#fcd34d',
  },
  resultsTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 12,
  },
  resultsCount: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 8,
  },
  resultsInterpretation: {
    fontSize: 14,
    marginBottom: 16,
  },
  nextStepsTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 8,
  },
  nextStepItem: {
    fontSize: 14,
    marginBottom: 6,
  },
});
