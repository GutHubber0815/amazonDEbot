import { useEffect, useState } from 'react';
import { View, Text, StyleSheet, FlatList, TextInput, Pressable, Linking } from 'react-native';
import { getSupportContacts } from '@early-help/api-client';
import { filterByRole, filterByZipCode } from '@early-help/utils';
import type { SupportContact } from '@early-help/types';
import { Picker } from '@react-native-picker/picker';
import '../src/lib/supabase';

export default function HelpNavigatorScreen() {
  const [contacts, setContacts] = useState<SupportContact[]>([]);
  const [filteredContacts, setFilteredContacts] = useState<SupportContact[]>([]);
  const [selectedRole, setSelectedRole] = useState<'parent' | 'teacher' | 'social_worker' | ''>('');
  const [zipCode, setZipCode] = useState('');
  const [loading, setLoading] = useState(true);

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
      console.error('Error loading contacts:', error);
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

  const renderContact = ({ item }: { item: SupportContact }) => (
    <View style={styles.contactCard}>
      <View style={styles.contactHeader}>
        <Text style={styles.contactName}>{item.name}</Text>
        <View style={styles.categoryBadge}>
          <Text style={styles.categoryText}>{item.category}</Text>
        </View>
      </View>

      <Text style={styles.contactDescription}>{item.description}</Text>

      <View style={styles.contactDetails}>
        <Text style={styles.detailLabel}>Region:</Text>
        <Text style={styles.detailValue}>
          {item.region} ({item.zip_codes.join(', ')})
        </Text>
      </View>

      {item.phone && (
        <Pressable
          style={styles.contactButton}
          onPress={() => Linking.openURL(`tel:${item.phone}`)}
        >
          <Text style={styles.contactButtonText}>📞 {item.phone}</Text>
        </Pressable>
      )}

      {item.email && (
        <Pressable
          style={styles.contactButton}
          onPress={() => Linking.openURL(`mailto:${item.email}`)}
        >
          <Text style={styles.contactButtonText}>✉️ {item.email}</Text>
        </Pressable>
      )}

      {item.website && (
        <Pressable
          style={styles.contactButton}
          onPress={() => Linking.openURL(item.website!)}
        >
          <Text style={styles.contactButtonText}>🌐 Visit Website</Text>
        </Pressable>
      )}
    </View>
  );

  if (loading) {
    return (
      <View style={styles.centered}>
        <Text>Loading...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.emergency}>
        <Text style={styles.emergencyTitle}>🚨 Emergency</Text>
        <Text style={styles.emergencyText}>Police: 110 | Youth Crisis: 116 111</Text>
      </View>

      <View style={styles.filters}>
        <View style={styles.filterGroup}>
          <Text style={styles.filterLabel}>Your Role</Text>
          <View style={styles.pickerContainer}>
            <Picker
              selectedValue={selectedRole}
              onValueChange={(value) => setSelectedRole(value)}
              style={styles.picker}
            >
              <Picker.Item label="Select role..." value="" />
              <Picker.Item label="Parent / Guardian" value="parent" />
              <Picker.Item label="Teacher / Educator" value="teacher" />
              <Picker.Item label="Social Worker" value="social_worker" />
            </Picker>
          </View>
        </View>

        <View style={styles.filterGroup}>
          <Text style={styles.filterLabel}>ZIP Code</Text>
          <TextInput
            style={styles.input}
            placeholder="e.g., 10115"
            value={zipCode}
            onChangeText={setZipCode}
            keyboardType="numeric"
            maxLength={5}
          />
        </View>
      </View>

      <FlatList
        data={filteredContacts}
        renderItem={renderContact}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.list}
        ListEmptyComponent={
          <View style={styles.centered}>
            <Text style={styles.emptyText}>
              {selectedRole && zipCode
                ? 'No contacts found for your area'
                : 'Select your role and enter ZIP code'}
            </Text>
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
  emergency: {
    backgroundColor: '#fee2e2',
    padding: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#fca5a5',
  },
  emergencyTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#991b1b',
    marginBottom: 4,
  },
  emergencyText: {
    fontSize: 13,
    color: '#991b1b',
  },
  filters: {
    backgroundColor: '#fff',
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#e5e7eb',
  },
  filterGroup: {
    marginBottom: 12,
  },
  filterLabel: {
    fontSize: 14,
    fontWeight: '500',
    marginBottom: 6,
  },
  pickerContainer: {
    borderWidth: 1,
    borderColor: '#d1d5db',
    borderRadius: 8,
    backgroundColor: '#f9fafb',
  },
  picker: {
    height: 50,
  },
  input: {
    borderWidth: 1,
    borderColor: '#d1d5db',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    backgroundColor: '#f9fafb',
  },
  list: {
    padding: 16,
    gap: 12,
  },
  contactCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  contactHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 8,
  },
  contactName: {
    fontSize: 18,
    fontWeight: '600',
    flex: 1,
  },
  categoryBadge: {
    backgroundColor: '#dbeafe',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  categoryText: {
    fontSize: 12,
    color: '#1e40af',
    fontWeight: '500',
  },
  contactDescription: {
    fontSize: 14,
    color: '#64748b',
    marginBottom: 12,
  },
  contactDetails: {
    flexDirection: 'row',
    marginBottom: 8,
  },
  detailLabel: {
    fontSize: 13,
    fontWeight: '500',
    marginRight: 6,
  },
  detailValue: {
    fontSize: 13,
    color: '#64748b',
    flex: 1,
  },
  contactButton: {
    backgroundColor: '#f1f5f9',
    padding: 10,
    borderRadius: 8,
    marginTop: 6,
  },
  contactButtonText: {
    fontSize: 14,
    color: '#0ea5e9',
  },
  emptyText: {
    fontSize: 16,
    color: '#94a3b8',
    textAlign: 'center',
  },
});
