import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { COLORS, SIZES } from '../constants/theme';

import SearchScreen from '../screens/SearchScreen';
import ProfileScreen from '../screens/ProfileScreen';
import BrawlersScreen from '../screens/BrawlersScreen';
import BattleLogScreen from '../screens/BattleLogScreen';
import ClubScreen from '../screens/ClubScreen';

const Stack = createNativeStackNavigator();

const screenOptions = {
  headerStyle: {
    backgroundColor: COLORS.surface,
  },
  headerTintColor: COLORS.text,
  headerTitleStyle: {
    fontWeight: '700',
    fontSize: SIZES.lg,
  },
  headerShadowVisible: false,
  contentStyle: {
    backgroundColor: COLORS.background,
  },
};

export default function AppNavigator() {
  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={screenOptions}>
        <Stack.Screen
          name="Search"
          component={SearchScreen}
          options={{ headerShown: false }}
        />
        <Stack.Screen
          name="Profile"
          component={ProfileScreen}
          options={({ route }) => ({
            title: route.params?.player?.name || 'Profil',
          })}
        />
        <Stack.Screen
          name="Brawlers"
          component={BrawlersScreen}
          options={({ route }) => ({
            title: `Brawlers de ${route.params?.playerName || ''}`,
          })}
        />
        <Stack.Screen
          name="BattleLog"
          component={BattleLogScreen}
          options={{ title: 'Historique des combats' }}
        />
        <Stack.Screen
          name="Club"
          component={ClubScreen}
          options={{ title: 'Club' }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
