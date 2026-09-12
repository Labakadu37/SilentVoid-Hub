import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { COLORS, SIZES } from '../constants/theme';

function getResultStyle(result) {
  if (result === 'victory') return { color: COLORS.success, label: 'VICTOIRE' };
  if (result === 'defeat') return { color: COLORS.error, label: 'DEFAITE' };
  return { color: COLORS.secondary, label: 'MATCH NUL' };
}

function formatDate(isoString) {
  const d = new Date(
    isoString.replace(
      /(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})\.\d+Z/,
      '$1-$2-$3T$4:$5:$6Z'
    )
  );
  const now = new Date();
  const diff = Math.floor((now - d) / 60000);
  if (diff < 60) return `Il y a ${diff}min`;
  if (diff < 1440) return `Il y a ${Math.floor(diff / 60)}h`;
  return `Il y a ${Math.floor(diff / 1440)}j`;
}

export default function BattleCard({ battle }) {
  const event = battle.event || {};
  const result = battle.battle?.result;
  const { color, label } = getResultStyle(result);
  const mode = event.mode || battle.battle?.mode || '?';
  const map = event.map || '?';
  const trophyChange = battle.battle?.trophyChange;
  const brawler = battle.battle?.players?.[0]?.brawler
    || battle.battle?.teams?.[0]?.[0]?.brawler;

  return (
    <View style={styles.card}>
      <View style={styles.header}>
        <View>
          <Text style={styles.mode}>{mode.replace(/([A-Z])/g, ' $1').trim()}</Text>
          <Text style={styles.map}>{map}</Text>
        </View>
        <View style={styles.resultContainer}>
          {trophyChange != null && (
            <Text style={[styles.trophyChange, { color: trophyChange >= 0 ? COLORS.success : COLORS.error }]}>
              {trophyChange >= 0 ? '+' : ''}{trophyChange} 🏆
            </Text>
          )}
          {result && <Text style={[styles.result, { color }]}>{label}</Text>}
        </View>
      </View>

      <View style={styles.footer}>
        {brawler && (
          <Text style={styles.brawlerName}>
            {brawler.name} (Niv.{brawler.power})
          </Text>
        )}
        <Text style={styles.time}>{formatDate(battle.battleTime)}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: COLORS.surfaceLight,
    borderRadius: SIZES.radius,
    padding: SIZES.padding,
    marginBottom: 10,
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },
  mode: {
    color: COLORS.accent,
    fontSize: SIZES.md,
    fontWeight: '700',
    textTransform: 'capitalize',
  },
  map: {
    color: COLORS.textSecondary,
    fontSize: SIZES.sm,
    marginTop: 2,
  },
  resultContainer: {
    alignItems: 'flex-end',
  },
  result: {
    fontSize: SIZES.sm,
    fontWeight: '800',
  },
  trophyChange: {
    fontSize: SIZES.sm,
    fontWeight: '700',
    marginBottom: 2,
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 10,
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: COLORS.border,
  },
  brawlerName: {
    color: COLORS.text,
    fontSize: SIZES.sm,
    fontWeight: '600',
  },
  time: {
    color: COLORS.textMuted,
    fontSize: SIZES.xs,
  },
});
