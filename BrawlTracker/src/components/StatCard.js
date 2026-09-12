import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { COLORS, SIZES } from '../constants/theme';

export default function StatCard({ icon, label, value, color }) {
  return (
    <View style={styles.card}>
      <Text style={styles.icon}>{icon}</Text>
      <Text style={[styles.value, color && { color }]}>{value}</Text>
      <Text style={styles.label}>{label}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: COLORS.surfaceLight,
    borderRadius: SIZES.radius,
    padding: SIZES.padding,
    alignItems: 'center',
    flex: 1,
    marginHorizontal: 4,
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  icon: {
    fontSize: 24,
    marginBottom: 6,
  },
  value: {
    color: COLORS.text,
    fontSize: SIZES.xl,
    fontWeight: '800',
  },
  label: {
    color: COLORS.textSecondary,
    fontSize: SIZES.xs,
    marginTop: 4,
    textAlign: 'center',
  },
});
