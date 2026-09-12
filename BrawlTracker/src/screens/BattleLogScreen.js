import React, { useState, useEffect } from 'react';
import {
  View, Text, FlatList, StyleSheet, ActivityIndicator,
} from 'react-native';
import { COLORS, SIZES } from '../constants/theme';
import { getPlayerBattleLog } from '../services/api';
import BattleCard from '../components/BattleCard';

export default function BattleLogScreen({ route }) {
  const { tag } = route.params;
  const [battles, setBattles] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    (async () => {
      try {
        const data = await getPlayerBattleLog(tag);
        setBattles(data.items || []);
      } catch (e) {
        setError(e.message);
      } finally {
        setLoading(false);
      }
    })();
  }, [tag]);

  if (loading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" color={COLORS.primary} />
        <Text style={styles.loadingText}>Chargement...</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.center}>
        <Text style={styles.errorIcon}>😵</Text>
        <Text style={styles.errorText}>{error}</Text>
      </View>
    );
  }

  const wins = battles.filter((b) => b.battle?.result === 'victory').length;
  const losses = battles.filter((b) => b.battle?.result === 'defeat').length;

  return (
    <View style={styles.container}>
      <View style={styles.summary}>
        <View style={styles.summaryItem}>
          <Text style={[styles.summaryValue, { color: COLORS.success }]}>{wins}</Text>
          <Text style={styles.summaryLabel}>Victoires</Text>
        </View>
        <View style={styles.summaryItem}>
          <Text style={[styles.summaryValue, { color: COLORS.error }]}>{losses}</Text>
          <Text style={styles.summaryLabel}>Defaites</Text>
        </View>
        <View style={styles.summaryItem}>
          <Text style={[styles.summaryValue, { color: COLORS.accent }]}>
            {battles.length > 0 ? Math.round((wins / battles.length) * 100) : 0}%
          </Text>
          <Text style={styles.summaryLabel}>Winrate</Text>
        </View>
      </View>

      <FlatList
        data={battles}
        keyExtractor={(_, i) => String(i)}
        renderItem={({ item }) => <BattleCard battle={item} />}
        contentContainerStyle={styles.list}
        showsVerticalScrollIndicator={false}
        ListEmptyComponent={
          <Text style={styles.emptyText}>Aucun combat recent</Text>
        }
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  center: {
    flex: 1,
    backgroundColor: COLORS.background,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    color: COLORS.textSecondary,
    marginTop: 12,
    fontSize: SIZES.md,
  },
  errorIcon: {
    fontSize: 48,
    marginBottom: 12,
  },
  errorText: {
    color: COLORS.error,
    fontSize: SIZES.lg,
    fontWeight: '600',
  },
  summary: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  summaryItem: {
    alignItems: 'center',
  },
  summaryValue: {
    fontSize: SIZES.xxl,
    fontWeight: '900',
  },
  summaryLabel: {
    color: COLORS.textSecondary,
    fontSize: SIZES.xs,
    marginTop: 4,
  },
  list: {
    padding: SIZES.padding,
    paddingBottom: 40,
  },
  emptyText: {
    color: COLORS.textMuted,
    textAlign: 'center',
    marginTop: 40,
    fontSize: SIZES.md,
  },
});
