import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { COLORS, SIZES } from '../constants/theme';
import { getRarityColor } from '../services/api';

export default function BrawlerCard({ brawler }) {
  const rarityColor = getRarityColor(brawler.rarity?.name || '');
  const stars = brawler.starPowers?.length || 0;
  const gadgets = brawler.gadgets?.length || 0;

  return (
    <View style={[styles.card, { borderLeftColor: rarityColor }]}>
      <View style={styles.header}>
        <View>
          <Text style={styles.name}>{brawler.name}</Text>
          <Text style={[styles.rarity, { color: rarityColor }]}>
            {brawler.rarity?.name || 'Unknown'}
          </Text>
        </View>
        <View style={styles.trophyContainer}>
          <Text style={styles.trophyIcon}>🏆</Text>
          <Text style={styles.trophies}>{brawler.trophies}</Text>
        </View>
      </View>

      <View style={styles.details}>
        <View style={styles.detail}>
          <Text style={styles.detailLabel}>Rang</Text>
          <Text style={styles.detailValue}>{brawler.rank}</Text>
        </View>
        <View style={styles.detail}>
          <Text style={styles.detailLabel}>Niveau</Text>
          <Text style={styles.detailValue}>{brawler.power}</Text>
        </View>
        <View style={styles.detail}>
          <Text style={styles.detailLabel}>Star Powers</Text>
          <Text style={styles.detailValue}>{stars}</Text>
        </View>
        <View style={styles.detail}>
          <Text style={styles.detailLabel}>Gadgets</Text>
          <Text style={styles.detailValue}>{gadgets}</Text>
        </View>
      </View>

      {brawler.highestTrophies > brawler.trophies && (
        <Text style={styles.highest}>
          Record: {brawler.highestTrophies} 🏆
        </Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: COLORS.surfaceLight,
    borderRadius: SIZES.radius,
    padding: SIZES.padding,
    marginBottom: 10,
    borderLeftWidth: 4,
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  name: {
    color: COLORS.text,
    fontSize: SIZES.lg,
    fontWeight: '700',
  },
  rarity: {
    fontSize: SIZES.xs,
    fontWeight: '600',
    marginTop: 2,
  },
  trophyContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: COLORS.surface,
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 20,
  },
  trophyIcon: {
    fontSize: 14,
    marginRight: 4,
  },
  trophies: {
    color: COLORS.trophy,
    fontSize: SIZES.md,
    fontWeight: '800',
  },
  details: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  detail: {
    alignItems: 'center',
  },
  detailLabel: {
    color: COLORS.textMuted,
    fontSize: SIZES.xs,
  },
  detailValue: {
    color: COLORS.text,
    fontSize: SIZES.md,
    fontWeight: '700',
    marginTop: 2,
  },
  highest: {
    color: COLORS.textSecondary,
    fontSize: SIZES.xs,
    marginTop: 8,
    textAlign: 'right',
  },
});
