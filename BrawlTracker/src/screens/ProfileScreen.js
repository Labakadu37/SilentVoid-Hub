import React from 'react';
import {
  View, Text, ScrollView, StyleSheet, TouchableOpacity,
} from 'react-native';
import { COLORS, SIZES } from '../constants/theme';
import StatCard from '../components/StatCard';

export default function ProfileScreen({ route, navigation }) {
  const { player, tag } = route.params;

  const winRate3v3 = player['3vs3Victories'] || 0;
  const soloWins = player.soloVictories || 0;
  const duoWins = player.duoVictories || 0;
  const totalBrawlers = player.brawlers?.length || 0;

  return (
    <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
      <View style={styles.profileHeader}>
        <View style={styles.nameRow}>
          <Text style={styles.playerName}>{player.name}</Text>
          {player.nameColor && (
            <View style={[styles.colorDot, { backgroundColor: `#${player.nameColor.slice(4)}` }]} />
          )}
        </View>
        <Text style={styles.playerTag}>#{player.tag}</Text>

        <View style={styles.trophyRow}>
          <Text style={styles.trophyEmoji}>🏆</Text>
          <Text style={styles.trophyCount}>{player.trophies?.toLocaleString()}</Text>
          <Text style={styles.trophyMax}>
            / {player.highestTrophies?.toLocaleString()} max
          </Text>
        </View>

        {player.expLevel && (
          <View style={styles.levelBadge}>
            <Text style={styles.levelText}>Niv. {player.expLevel}</Text>
          </View>
        )}
      </View>

      {player.club?.tag && (
        <TouchableOpacity
          style={styles.clubCard}
          onPress={() => navigation.navigate('Club', { clubTag: player.club.tag })}
          activeOpacity={0.7}
        >
          <Text style={styles.clubIcon}>🛡️</Text>
          <View>
            <Text style={styles.clubName}>{player.club.name}</Text>
            <Text style={styles.clubTag}>#{player.club.tag}</Text>
          </View>
          <Text style={styles.clubArrow}>›</Text>
        </TouchableOpacity>
      )}

      <View style={styles.statsRow}>
        <StatCard icon="⚔️" label="Victoires 3v3" value={winRate3v3.toLocaleString()} color={COLORS.success} />
        <StatCard icon="🎯" label="Solo" value={soloWins.toLocaleString()} color={COLORS.accent} />
        <StatCard icon="👥" label="Duo" value={duoWins.toLocaleString()} color={COLORS.secondary} />
      </View>

      <View style={styles.statsRow}>
        <StatCard icon="🤖" label="Brawlers" value={totalBrawlers} color={COLORS.epic} />
        <StatCard icon="🏆" label="Record" value={player.highestTrophies?.toLocaleString()} color={COLORS.trophy} />
        <StatCard icon="⭐" label="Niveau" value={player.expLevel || '?'} color={COLORS.primary} />
      </View>

      <TouchableOpacity
        style={styles.actionButton}
        onPress={() => navigation.navigate('Brawlers', { brawlers: player.brawlers, playerName: player.name })}
        activeOpacity={0.8}
      >
        <Text style={styles.actionEmoji}>🤖</Text>
        <View style={{ flex: 1 }}>
          <Text style={styles.actionTitle}>Brawlers ({totalBrawlers})</Text>
          <Text style={styles.actionSub}>Voir tous les brawlers et stats</Text>
        </View>
        <Text style={styles.actionArrow}>›</Text>
      </TouchableOpacity>

      <TouchableOpacity
        style={styles.actionButton}
        onPress={() => navigation.navigate('BattleLog', { tag })}
        activeOpacity={0.8}
      >
        <Text style={styles.actionEmoji}>⚔️</Text>
        <View style={{ flex: 1 }}>
          <Text style={styles.actionTitle}>Historique des combats</Text>
          <Text style={styles.actionSub}>Derniers matchs joues</Text>
        </View>
        <Text style={styles.actionArrow}>›</Text>
      </TouchableOpacity>

      <View style={{ height: 40 }} />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
    paddingHorizontal: SIZES.padding,
  },
  profileHeader: {
    alignItems: 'center',
    paddingVertical: 24,
  },
  nameRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  playerName: {
    color: COLORS.text,
    fontSize: SIZES.xxl,
    fontWeight: '900',
  },
  colorDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
  },
  playerTag: {
    color: COLORS.textSecondary,
    fontSize: SIZES.md,
    marginTop: 4,
  },
  trophyRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
    marginTop: 16,
  },
  trophyEmoji: {
    fontSize: 28,
    marginRight: 8,
  },
  trophyCount: {
    color: COLORS.trophy,
    fontSize: 36,
    fontWeight: '900',
  },
  trophyMax: {
    color: COLORS.textMuted,
    fontSize: SIZES.sm,
    marginLeft: 8,
  },
  levelBadge: {
    backgroundColor: COLORS.primary,
    paddingHorizontal: 16,
    paddingVertical: 6,
    borderRadius: 20,
    marginTop: 12,
  },
  levelText: {
    color: COLORS.text,
    fontSize: SIZES.sm,
    fontWeight: '700',
  },
  clubCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: COLORS.surface,
    borderRadius: SIZES.radius,
    padding: SIZES.padding,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  clubIcon: {
    fontSize: 28,
    marginRight: 12,
  },
  clubName: {
    color: COLORS.text,
    fontSize: SIZES.lg,
    fontWeight: '700',
  },
  clubTag: {
    color: COLORS.textSecondary,
    fontSize: SIZES.xs,
    marginTop: 2,
  },
  clubArrow: {
    color: COLORS.textMuted,
    fontSize: 28,
    marginLeft: 'auto',
  },
  statsRow: {
    flexDirection: 'row',
    marginBottom: 10,
  },
  actionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: COLORS.surface,
    borderRadius: SIZES.radius,
    padding: SIZES.padding,
    marginBottom: 10,
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  actionEmoji: {
    fontSize: 28,
    marginRight: 14,
  },
  actionTitle: {
    color: COLORS.text,
    fontSize: SIZES.lg,
    fontWeight: '700',
  },
  actionSub: {
    color: COLORS.textSecondary,
    fontSize: SIZES.xs,
    marginTop: 2,
  },
  actionArrow: {
    color: COLORS.textMuted,
    fontSize: 28,
  },
});
