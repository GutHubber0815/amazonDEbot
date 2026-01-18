import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList, TextInput, Pressable } from 'react-native';
import { getGlossaryItems } from '@early-help/api-client';
import { searchGlossaryItems } from '@early-help/utils';
import type { GlossaryItem } from '@early-help/types';
import '../src/lib/supabase';

export default function GlossaryScreen() {
  const [items, setItems] = useState<GlossaryItem[]>([]);
  const [filteredItems, setFilteredItems] = useState<GlossaryItem[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

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

  const renderItem = ({ item }: { item: GlossaryItem }) => {
    const isExpanded = expandedId === item.id;

    return (
      <Pressable
        style={styles.itemCard}
        onPress={() => setExpandedId(isExpanded ? null : item.id)}
      >
        <View style={styles.itemHeader}>
          <Text style={styles.itemTerm}>{item.term}</Text>
          <Text style={styles.expandIcon}>{isExpanded ? '−' : '+'}</Text>
        </View>
        <Text style={styles.itemMeaning}>{item.meaning}</Text>

        {isExpanded && (
          <View style={styles.expandedContent}>
            <Text style={styles.sectionTitle}>Context</Text>
            <Text style={styles.sectionText}>{item.context}</Text>

            <Text style={styles.sectionTitle}>Examples</Text>
            <Text style={styles.sectionText}>{item.examples}</Text>

            {item.related_terms.length > 0 && (
              <>
                <Text style={styles.sectionTitle}>Related Terms</Text>
                <View style={styles.relatedTerms}>
                  {item.related_terms.map((term) => (
                    <View key={term} style={styles.relatedTag}>
                      <Text style={styles.relatedTagText}>{term}</Text>
                    </View>
                  ))}
                </View>
              </>
            )}
          </View>
        )}
      </Pressable>
    );
  };

  if (loading) {
    return (
      <View style={styles.centered}>
        <Text>Loading...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.warning}>
        <Text style={styles.warningText}>
          <Text style={styles.warningBold}>Important:</Text> Context is crucial.
          Not every use indicates extremism.
        </Text>
      </View>

      <View style={styles.searchContainer}>
        <TextInput
          style={styles.searchInput}
          placeholder="Search terms..."
          value={searchQuery}
          onChangeText={setSearchQuery}
        />
      </View>

      <FlatList
        data={filteredItems}
        renderItem={renderItem}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        ListEmptyComponent={
          <View style={styles.centered}>
            <Text style={styles.emptyText}>No terms found</Text>
          </View>
        }
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f9fafb',
  },
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  warning: {
    backgroundColor: '#fef3c7',
    padding: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#fcd34d',
  },
  warningText: {
    fontSize: 13,
    color: '#78350f',
  },
  warningBold: {
    fontWeight: 'bold',
  },
  searchContainer: {
    padding: 16,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e5e7eb',
  },
  searchInput: {
    backgroundColor: '#f3f4f6',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
  },
  list: {
    padding: 16,
    gap: 12,
  },
  itemCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  itemHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  itemTerm: {
    fontSize: 18,
    fontWeight: '600',
    color: '#0ea5e9',
    flex: 1,
  },
  expandIcon: {
    fontSize: 24,
    color: '#64748b',
  },
  itemMeaning: {
    fontSize: 14,
    color: '#1f2937',
  },
  expandedContent: {
    marginTop: 16,
    paddingTop: 16,
    borderTopWidth: 1,
    borderTopColor: '#e5e7eb',
  },
  sectionTitle: {
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 6,
    marginTop: 12,
  },
  sectionText: {
    fontSize: 14,
    color: '#64748b',
  },
  relatedTerms: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 6,
    marginTop: 6,
  },
  relatedTag: {
    backgroundColor: '#f1f5f9',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
  },
  relatedTagText: {
    fontSize: 12,
    color: '#475569',
  },
  emptyText: {
    fontSize: 16,
    color: '#94a3b8',
  },
});
