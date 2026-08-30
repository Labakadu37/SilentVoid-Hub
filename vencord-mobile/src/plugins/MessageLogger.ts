import { useMessageStore } from '../store/messageStore';
import AsyncStorage from '@react-native-async-storage/async-storage';

export interface PluginConfig {
  enabled: boolean;
  logEdits: boolean;
  logDeletes: boolean;
  storageKey: string;
}

const DEFAULT_CONFIG: PluginConfig = {
  enabled: true,
  logEdits: true,
  logDeletes: true,
  storageKey: 'vencord_message_logger'
};

export class MessageLoggerPlugin {
  private config: PluginConfig;
  private readonly messageStore = useMessageStore;

  constructor(config: Partial<PluginConfig> = {}) {
    this.config = { ...DEFAULT_CONFIG, ...config };
  }

  async initialize() {
    try {
      const savedData = await AsyncStorage.getItem(this.config.storageKey);
      if (savedData) {
        const messages = JSON.parse(savedData);
        messages.forEach(msg => this.messageStore.getState().addMessage(msg));
      }
    } catch (error) {
      console.error('[MessageLogger] Failed to load stored messages:', error);
    }
  }

  logMessage(data: {
    id: string;
    channelId: string;
    userId: string;
    username: string;
    content: string;
    timestamp?: number;
  }) {
    if (!this.config.enabled) return;

    const message = {
      ...data,
      timestamp: data.timestamp || Date.now(),
      deleted: false
    };

    this.messageStore.getState().addMessage(message);
    this.persistMessages();
  }

  logMessageEdit(messageId: string, newContent: string) {
    if (!this.config.enabled || !this.config.logEdits) return;

    this.messageStore.getState().editMessage(messageId, newContent);
    this.persistMessages();
  }

  logMessageDelete(messageId: string) {
    if (!this.config.enabled || !this.config.logDeletes) return;

    this.messageStore.getState().deleteMessage(messageId);
    this.persistMessages();
  }

  private async persistMessages() {
    try {
      const messages = this.messageStore.getState().messages;
      await AsyncStorage.setItem(
        this.config.storageKey,
        JSON.stringify(messages)
      );
    } catch (error) {
      console.error('[MessageLogger] Failed to persist messages:', error);
    }
  }

  getConfig() {
    return this.config;
  }

  setConfig(config: Partial<PluginConfig>) {
    this.config = { ...this.config, ...config };
  }

  exportLogs(format: 'json' | 'csv' = 'json') {
    const messages = this.messageStore.getState().messages;

    if (format === 'csv') {
      const header = 'ID,ChannelID,UserID,Username,Content,Timestamp,Edited,Deleted\n';
      const rows = messages.map(m =>
        `"${m.id}","${m.channelId}","${m.userId}","${m.username}","${m.content.replace(/"/g, '""')}",${m.timestamp},${m.edited || ''},${m.deleted || false}`
      ).join('\n');
      return header + rows;
    }

    return JSON.stringify(messages, null, 2);
  }

  getStats() {
    const messages = this.messageStore.getState().messages;
    return {
      totalMessages: messages.length,
      totalUsers: new Set(messages.map(m => m.userId)).size,
      totalChannels: new Set(messages.map(m => m.channelId)).size,
      deletedMessages: messages.filter(m => m.deleted).length,
      editedMessages: messages.filter(m => m.edited).length
    };
  }
}

export default MessageLoggerPlugin;
