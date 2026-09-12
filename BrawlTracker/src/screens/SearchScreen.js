import React, { useState } from 'react';
import {
  View, Text, TextInput, TouchableOpacity, StyleSheet,
  ActivityIndicator, KeyboardAvoidingView, Platform, Alert,
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { COLORS, SIZES } from '../constants/theme';
import { getPlayer } from '../services/api';

export default function SearchScreen({ navigation }) {
  const [tag, setTag] = useState('');
  const [loading, setLoading] = useState(false);
  const [recentTags, setRecentTags] = useState([]);

  const search = async () => {
    const clean = tag.trim();
    if (!clean) return;
    setLoading(true);
    try {
      const player = await getPlayer(clean);
      if (!recentTags.includes(clean.toUpperCase())) {
        setRecentTags((prev) => [clean.toUpperCase(), ...prev].slice(0, 5));
      }
      navigation.navigate('Profile', { player, tag: clean });
    } catch (e) {
      Alert.alert('Erreur', e.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <StatusBar style="light" />

      <View style={styles.header}>
        <Text style={styles.logo}>⚡</Text>
        <Text style={styles.title}>BRAWL TRACKER</Text>
        <Text style={styles.subtitle}>Recherche un joueur Brawl Stars</Text>
      </View>

      <View style={styles.searchContainer}>
        <View style={styles.inputContainer}>
          <Text style={styles.hash}>#</Text>
          <TextInput
            style={styles.input}
            placeholder="Tag du joueur (ex: 2YGQ2GQVL)"
            placeholderTextColor={COLORS.textMuted}
            value={tag}
            onChangeText={setTag}
            autoCapitalize="characters"
            autoCorrect={false}
            onSubmitEditing={search}
            returnKeyType="search"
          />
        </View>

        <TouchableOpacity
          style={[styles.button, loading && styles.buttonDisabled]}
          onPress={search}
          disabled={loading}
          activeOpacity={0.8}
        >
          {loading ? (
            <ActivityIndicator color={COLORS.text} />
          ) : (
            <Text style={styles.buttonText}>RECHERCHER</Text>
          )}
        </TouchableOpacity>
      </View>

      {recentTags.length > 0 && (
        <View style={styles.recentContainer}>
          <Text style={styles.recentTitle}>Recherches recentes</Text>
          <View style={styles.recentTags}>
            {recentTags.map((t) => (
              <TouchableOpacity
                key={t}
                style={styles.recentTag}
                onPress={() => { setTag(t); }}
              >
                <Text style={styles.recentTagText}>#{t}</Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>
      )}

      <View style={styles.footer}>
        <Text style={styles.footerText}>
          Utilise l'API officielle Brawl Stars
        </Text>
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
    paddingHorizontal: SIZES.padding,
  },
  header: {
    alignItems: 'center',
    marginTop: 80,
    marginBottom: 40,
  },
  logo: {
    fontSize: 60,
    marginBottom: 12,
  },
  title: {
    color: COLORS.primary,
    fontSize: SIZES.xxxl,
    fontWeight: '900',
    letterSpacing: 2,
  },
  subtitle: {
    color: COLORS.textSecondary,
    fontSize: SIZES.md,
    marginTop: 8,
  },
  searchContainer: {
    marginBottom: 30,
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: COLORS.surface,
    borderRadius: SIZES.radius,
    borderWidth: 2,
    borderColor: COLORS.border,
    marginBottom: 14,
    paddingHorizontal: 16,
  },
  hash: {
    color: COLORS.primary,
    fontSize: SIZES.xxl,
    fontWeight: '900',
    marginRight: 4,
  },
  input: {
    flex: 1,
    color: COLORS.text,
    fontSize: SIZES.lg,
    paddingVertical: 16,
    fontWeight: '600',
    letterSpacing: 1,
  },
  button: {
    backgroundColor: COLORS.primary,
    borderRadius: SIZES.radius,
    paddingVertical: 16,
    alignItems: 'center',
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  buttonText: {
    color: COLORS.text,
    fontSize: SIZES.lg,
    fontWeight: '800',
    letterSpacing: 1,
  },
  recentContainer: {
    marginBottom: 20,
  },
  recentTitle: {
    color: COLORS.textSecondary,
    fontSize: SIZES.sm,
    marginBottom: 10,
  },
  recentTags: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  recentTag: {
    backgroundColor: COLORS.surface,
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  recentTagText: {
    color: COLORS.accent,
    fontSize: SIZES.sm,
    fontWeight: '600',
  },
  footer: {
    position: 'absolute',
    bottom: 40,
    left: 0,
    right: 0,
    alignItems: 'center',
  },
  footerText: {
    color: COLORS.textMuted,
    fontSize: SIZES.xs,
  },
});
