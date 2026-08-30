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
        messages.forEach(msg => this.messageStore.getState().addMessage({
          id: msg.id,
          channelId: msg.channelId,
          userId: msg.userId,
          username: msg.username,
          content: msg.content,
          timestamp: msg.timestamp
        }));
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

    this.messageStore.getState().addMessage({
      ...data,
      timestamp: data.timestamp || Date.now()
    });
    this.persistMessages();
  }

  logMessageEdit(messageId: string, newContent: string) {
    if (!this.config.enabled || !this.config.logEdits) return;

    this.messageStore.getState().editMessage(messageId, newContent);
    this.persistMessages();
  }

  logMessageDelete(messageId: string, deletedBy?: string) {
    if (!this.config.enabled || !this.config.logDeletes) return;

    this.messageStore.getState().deleteMessage(messageId, deletedBy);
    this.persistMessages();
  }

  getMessageHistory(messageId: string) {
    const message = this.messageStore.getState().getMessage(messageId);
    if (!message) return null;

    return {
      original: {
        content: message.content,
        timestamp: message.timestamp
      },
      edits: message.editHistory,
      deleted: message.deletedAt ? {
        timestamp: message.deletedAt,
        deletedBy: message.deletedBy
      } : null
    };
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
      const header = 'ID,ChannelID,UserID,Username,Current Content,Edit History,Deleted,Timestamp\n';
      const rows = messages.map(m => {
        const editHistory = m.editHistory.map(e => `${e.content}|${e.timestamp}`).join(';');
        const deletedInfo = m.deletedAt ? `Deleted by ${m.deletedBy || 'unknown'} at ${m.deletedAt}` : '';
        return `"${m.id}","${m.channelId}","${m.userId}","${m.username}","${m.content.replace(/"/g, '""')}","${editHistory}","${deletedInfo}",${m.timestamp}`;
      }).join('\n');
      return header + rows;
    }

    return JSON.stringify(messages, null, 2);
  }

  getStats() {
    const messages = this.messageStore.getState().messages;
    const deletedCount = messages.filter(m => m.deletedAt).length;
    const editedCount = messages.filter(m => m.editHistory.length > 0).length;

    return {
      totalMessages: messages.length,
      totalUsers: new Set(messages.map(m => m.userId)).size,
      totalChannels: new Set(messages.map(m => m.channelId)).size,
      deletedMessages: deletedCount,
      editedMessages: editedCount,
      averageEditsPerMessage: editedCount > 0
        ? messages.reduce((sum, m) => sum + m.editHistory.length, 0) / editedCount
        : 0
    };
  }
}

export default MessageLoggerPlugin;
