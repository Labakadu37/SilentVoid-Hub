import React, { useState } from 'react';
import {
  View, Text, FlatList, StyleSheet, TouchableOpacity,
} from 'react-native';
import { COLORS, SIZES } from '../constants/theme';
import BrawlerCard from '../components/BrawlerCard';

const SORT_OPTIONS = [
  { key: 'trophies', label: '🏆 Trophees' },
  { key: 'rank', label: '📈 Rang' },
  { key: 'power', label: '⚡ Niveau' },
  { key: 'name', label: '🔤 Nom' },
];

export default function BrawlersScreen({ route }) {
  const { brawlers, playerName } = route.params;
  const [sortBy, setSortBy] = useState('trophies');

  const sorted = [...brawlers].sort((a, b) => {
    if (sortBy === 'name') return a.name.localeCompare(b.name);
    return b[sortBy] - a[sortBy];
  });

  const totalTrophies = brawlers.reduce((sum, b) => sum + b.trophies, 0);

  return (
    <View style={styles.container}>
      <View style={styles.summary}>
        <Text style={styles.summaryText}>
          {brawlers.length} brawlers • {totalTrophies.toLocaleString()} 🏆 total
        </Text>
      </View>

      <View style={styles.sortRow}>
        {SORT_OPTIONS.map((opt) => (
          <TouchableOpacity
            key={opt.key}
            style={[styles.sortBtn, sortBy === opt.key && styles.sortBtnActive]}
            onPress={() => setSortBy(opt.key)}
          >
            <Text style={[styles.sortText, sortBy === opt.key && styles.sortTextActive]}>
              {opt.label}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      <FlatList
        data={sorted}
        keyExtractor={(item) => String(item.id)}
        renderItem={({ item }) => <BrawlerCard brawler={item} />}
        contentContainerStyle={styles.list}
        showsVerticalScrollIndicator={false}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  summary: {
    paddingHorizontal: SIZES.padding,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  summaryText: {
    color: COLORS.textSecondary,
    fontSize: SIZES.sm,
    textAlign: 'center',
    fontWeight: '600',
  },
  sortRow: {
    flexDirection: 'row',
    paddingHorizontal: SIZES.padding,
    paddingVertical: 10,
    gap: 6,
  },
  sortBtn: {
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 20,
    backgroundColor: COLORS.surface,
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  sortBtnActive: {
    backgroundColor: COLORS.primary,
    borderColor: COLORS.primary,
  },
  sortText: {
    color: COLORS.textSecondary,
    fontSize: SIZES.xs,
    fontWeight: '600',
  },
  sortTextActive: {
    color: COLORS.text,
  },
  list: {
    padding: SIZES.padding,
    paddingBottom: 40,
  },
});
