import React, { useEffect } from 'react';
import { View, Text, StyleSheet, TextInput, TouchableOpacity, Alert } from 'react-native';
import { useAuthStore } from './store/authStore';
import { pluginManager } from './api/PluginManager';
import { MessagesList } from './components/MessagesList';
import { StatusBar } from 'expo-status-bar';

export default function App() {
  const { isAuthenticated, setToken } = useAuthStore();
  const [token, setTokenInput] = React.useState('');
  const [initialized, setInitialized] = React.useState(false);
  const [channelId, setChannelId] = React.useState('');

  useEffect(() => {
    const initializeApp = async () => {
      try {
        await pluginManager.loadBuiltinPlugins();
        await pluginManager.loadPlugin('MessageLogger');
        console.log('Vencord Mobile initialized with MessageLogger');
        setInitialized(true);
      } catch (error) {
        console.error('Failed to initialize Vencord Mobile:', error);
        Alert.alert('Error', 'Failed to initialize app');
      }
    };

    initializeApp();
  }, []);

  const handleLogin = () => {
    if (!token.trim()) {
      Alert.alert('Error', 'Please enter a Discord token');
      return;
    }

    setToken(token);
    setTokenInput('');
    Alert.alert('Success', 'Logged in! Token saved.');
  };

  if (!initialized) {
    return (
      <View style={styles.container}>
        <Text style={styles.loadingText}>Initializing Vencord Mobile...</Text>
        <StatusBar barStyle="light-content" />
      </View>
    );
  }

  if (!isAuthenticated) {
    return (
      <View style={styles.container}>
        <View style={styles.loginContainer}>
          <Text style={styles.title}>Vencord Mobile</Text>
          <Text style={styles.subtitle}>MessageLogger Edition</Text>

          <TextInput
            style={styles.input}
            placeholder="Enter Discord Token"
            placeholderTextColor="#72767d"
            value={token}
            onChangeText={setTokenInput}
            secureTextEntry
          />

          <TouchableOpacity style={styles.loginButton} onPress={handleLogin}>
            <Text style={styles.loginButtonText}>Login</Text>
          </TouchableOpacity>

          <Text style={styles.warningText}>
            ⚠️ Never share your Discord token with anyone!
          </Text>
        </View>
        <StatusBar barStyle="light-content" />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Vencord Mobile</Text>
        <View style={styles.channelInputContainer}>
          <TextInput
            style={styles.channelInput}
            placeholder="Channel ID (optional)"
            placeholderTextColor="#72767d"
            value={channelId}
            onChangeText={setChannelId}
          />
        </View>
      </View>

      <MessagesList channelId={channelId || undefined} />

      <StatusBar barStyle="light-content" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#2c2f33'
  },
  loadingText: {
    color: '#fff',
    fontSize: 16,
    textAlign: 'center',
    marginTop: '50%'
  },
  loginContainer: {
    flex: 1,
    justifyContent: 'center',
    padding: 20,
    backgroundColor: '#36393f'
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#fff',
    textAlign: 'center',
    marginBottom: 8
  },
  subtitle: {
    fontSize: 16,
    color: '#72767d',
    textAlign: 'center',
    marginBottom: 40
  },
  input: {
    borderWidth: 1,
    borderColor: '#202225',
    backgroundColor: '#2c2f33',
    color: '#fff',
    padding: 12,
    borderRadius: 4,
    marginBottom: 20,
    fontSize: 14
  },
  loginButton: {
    backgroundColor: '#7289da',
    padding: 12,
    borderRadius: 4,
    alignItems: 'center',
    marginBottom: 20
  },
  loginButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold'
  },
  warningText: {
    color: '#ed4245',
    textAlign: 'center',
    fontSize: 12
  },
  header: {
    backgroundColor: '#2c2f33',
    padding: 12,
    paddingTop: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#202225'
  },
  headerTitle: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 8
  },
  channelInputContainer: {
    flexDirection: 'row'
  },
  channelInput: {
    flex: 1,
    borderWidth: 1,
    borderColor: '#202225',
    backgroundColor: '#36393f',
    color: '#fff',
    padding: 8,
    borderRadius: 4,
    fontSize: 12
  }
});
