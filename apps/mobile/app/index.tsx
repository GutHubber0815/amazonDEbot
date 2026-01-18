import { View, Text, StyleSheet, ScrollView, Pressable } from 'react-native';
import { Link } from 'expo-router';

export default function HomeScreen() {
  return (
    <ScrollView style={styles.container}>
      <View style={styles.hero}>
        <Text style={styles.title}>Early Help</Text>
        <Text style={styles.subtitle}>
          Prevention & Civic Education for Parents and Teachers
        </Text>
        <Text style={styles.description}>
          Educational resources on media literacy, radicalization prevention, and support navigation.
        </Text>
      </View>

      <View style={styles.features}>
        <Link href="/library" asChild>
          <Pressable style={styles.featureCard}>
            <Text style={styles.featureIcon}>📚</Text>
            <Text style={styles.featureTitle}>Content Library</Text>
            <Text style={styles.featureDescription}>
              Educational articles on warning signs and communication strategies
            </Text>
          </Pressable>
        </Link>

        <Link href="/glossary" asChild>
          <Pressable style={styles.featureCard}>
            <Text style={styles.featureIcon}>🔍</Text>
            <Text style={styles.featureTitle}>Codes & Memes</Text>
            <Text style={styles.featureDescription}>
              Searchable lexicon of symbols and extremist language
            </Text>
          </Pressable>
        </Link>

        <Link href="/checklist" asChild>
          <Pressable style={styles.featureCard}>
            <Text style={styles.featureIcon}>✓</Text>
            <Text style={styles.featureTitle}>Signs Checklist</Text>
            <Text style={styles.featureDescription}>
              Self-guided assessment with next steps
            </Text>
          </Pressable>
        </Link>

        <Link href="/help-navigator" asChild>
          <Pressable style={styles.featureCard}>
            <Text style={styles.featureIcon}>🧭</Text>
            <Text style={styles.featureTitle}>Help Navigator</Text>
            <Text style={styles.featureDescription}>
              Find local support contacts
            </Text>
          </Pressable>
        </Link>
      </View>

      <View style={styles.privacy}>
        <Text style={styles.privacyTitle}>🔒 Privacy by Design</Text>
        <Text style={styles.privacyText}>✓ No personal data about minors stored</Text>
        <Text style={styles.privacyText}>✓ Checklist saved locally on your device</Text>
        <Text style={styles.privacyText}>✓ Optional login for favorites sync only</Text>
        <Text style={styles.privacyText}>✓ GDPR-compliant</Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f9fafb',
  },
  hero: {
    backgroundColor: '#e0f2fe',
    padding: 24,
    alignItems: 'center',
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#0369a1',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#0284c7',
    marginBottom: 12,
    textAlign: 'center',
  },
  description: {
    fontSize: 14,
    color: '#475569',
    textAlign: 'center',
    maxWidth: 320,
  },
  features: {
    padding: 16,
    gap: 12,
  },
  featureCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  featureIcon: {
    fontSize: 32,
    marginBottom: 8,
  },
  featureTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 4,
  },
  featureDescription: {
    fontSize: 14,
    color: '#64748b',
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
    marginBottom: 8,
  },
  privacyText: {
    fontSize: 13,
    color: '#1e40af',
    marginBottom: 4,
  },
});
