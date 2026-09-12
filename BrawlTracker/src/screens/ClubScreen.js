import React, { useState, useEffect } from 'react';
import {
  View, Text, FlatList, StyleSheet, ActivityIndicator,
} from 'react-native';
import { COLORS, SIZES } from '../constants/theme';
import { getClub } from '../services/api';

function getRoleStyle(role) {
  if (role === 'president') return { color: '#ffd700', label: 'President' };
  if (role === 'vicePresident') return { color: '#ff6b35', label: 'Vice-Pres' };
  if (role === 'senior') return { color: '#00d4ff', label: 'Senior' };
  return { color: COLORS.textSecondary, label: 'Membre' };
}

export default function ClubScreen({ route }) {
  const { clubTag } = route.params;
  const [club, setClub] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    (async () => {
      try {
        const data = await getClub(clubTag);
        setClub(data);
      } catch (e) {
        setError(e.message);
      } finally {
        setLoading(false);
      }
    })();
  }, [clubTag]);

  if (loading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" color={COLORS.primary} />
      </View>
    );
  }

  if (error || !club) {
    return (
      <View style={styles.center}>
        <Text style={styles.errorText}>{error || 'Club introuvable'}</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.clubName}>{club.name}</Text>
        <Text style={styles.clubTag}>#{club.tag}</Text>
        <View style={styles.clubStats}>
          <Text style={styles.clubTrophies}>🏆 {club.trophies?.toLocaleString()}</Text>
          <Text style={styles.clubMembers}>👥 {club.members?.length || 0}/30</Text>
        </View>
        {club.description && (
          <Text style={styles.description}>{club.description}</Text>
        )}
      </View>

      <FlatList
        data={club.members || []}
        keyExtractor={(item) => item.tag}
        renderItem={({ item, index }) => {
          const { color, label } = getRoleStyle(item.role);
          return (
            <View style={styles.memberRow}>
              <Text style={styles.memberRank}>{index + 1}</Text>
              <View style={styles.memberInfo}>
                <Text style={styles.memberName}>{item.name}</Text>
                <Text style={[styles.memberRole, { color }]}>{label}</Text>
              </View>
              <Text style={styles.memberTrophies}>🏆 {item.trophies?.toLocaleString()}</Text>
            </View>
          );
        }}
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
  center: {
    flex: 1,
    backgroundColor: COLORS.background,
    justifyContent: 'center',
    alignItems: 'center',
  },
  errorText: {
    color: COLORS.error,
    fontSize: SIZES.lg,
  },
  header: {
    alignItems: 'center',
    paddingVertical: 20,
    paddingHorizontal: SIZES.padding,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  clubName: {
    color: COLORS.text,
    fontSize: SIZES.xxl,
    fontWeight: '900',
  },
  clubTag: {
    color: COLORS.textSecondary,
    fontSize: SIZES.sm,
    marginTop: 4,
  },
  clubStats: {
    flexDirection: 'row',
    gap: 20,
    marginTop: 12,
  },
  clubTrophies: {
    color: COLORS.trophy,
    fontSize: SIZES.lg,
    fontWeight: '700',
  },
  clubMembers: {
    color: COLORS.accent,
    fontSize: SIZES.lg,
    fontWeight: '700',
  },
  description: {
    color: COLORS.textSecondary,
    fontSize: SIZES.sm,
    marginTop: 10,
    textAlign: 'center',
    fontStyle: 'italic',
  },
  list: {
    paddingBottom: 40,
  },
  memberRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    paddingHorizontal: SIZES.padding,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  memberRank: {
    color: COLORS.textMuted,
    fontSize: SIZES.md,
    fontWeight: '700',
    width: 30,
  },
  memberInfo: {
    flex: 1,
  },
  memberName: {
    color: COLORS.text,
    fontSize: SIZES.md,
    fontWeight: '600',
  },
  memberRole: {
    fontSize: SIZES.xs,
    fontWeight: '600',
    marginTop: 2,
  },
  memberTrophies: {
    color: COLORS.trophy,
    fontSize: SIZES.sm,
    fontWeight: '700',
  },
});
