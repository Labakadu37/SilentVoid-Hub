import React, { useEffect, useState } from 'react';
import { View, Text, FlatList, StyleSheet, TouchableOpacity, Animated } from 'react-native';
import { useMessageStore } from '../store/messageStore';

export interface MessagesListProps {
  channelId?: string;
  userId?: string;
}

export const MessagesList: React.FC<MessagesListProps> = ({ channelId, userId }) => {
  const messages = useMessageStore((state) => state.messages);
  const [filteredMessages, setFilteredMessages] = useState(messages);
  const [expandedMessages, setExpandedMessages] = useState<Set<string>>(new Set());

  useEffect(() => {
    if (channelId) {
      setFilteredMessages(useMessageStore.getState().getMessagesByChannel(channelId));
    } else if (userId) {
      setFilteredMessages(useMessageStore.getState().getMessagesByUser(userId));
    } else {
      setFilteredMessages(messages);
    }
  }, [messages, channelId, userId]);

  const toggleMessageHistory = (messageId: string) => {
    const newExpanded = new Set(expandedMessages);
    if (newExpanded.has(messageId)) {
      newExpanded.delete(messageId);
    } else {
      newExpanded.add(messageId);
    }
    setExpandedMessages(newExpanded);
  };

  const renderMessage = ({ item }: { item: any }) => {
    const isDeleted = !!item.deletedAt;
    const hasEdits = item.editHistory.length > 0;
    const isExpanded = expandedMessages.has(item.id);

    return (
      <TouchableOpacity
        style={styles.messageContainer}
        onPress={() => hasEdits && toggleMessageHistory(item.id)}
        activeOpacity={hasEdits ? 0.7 : 1}
      >
        <View style={styles.messageHeader}>
          <Text style={styles.username}>{item.username}</Text>
          <Text style={styles.timestamp}>
            {new Date(item.timestamp).toLocaleString()}
          </Text>
        </View>

        {isDeleted ? (
          <View style={styles.deletedContainer}>
            <Text style={styles.deletedContent}>
              [Message deleted{item.deletedBy ? ` by ${item.deletedBy}` : ''}]
            </Text>
            {item.editHistory.length > 0 && (
              <Text style={styles.hiddenContentLabel}>
                (Had {item.editHistory.length + 1} edits before deletion)
              </Text>
            )}
          </View>
        ) : (
          <>
            <Text style={styles.content}>{item.content}</Text>
            {hasEdits && (
              <Text style={styles.editedLabel}>
                (edited {item.editHistory.length}x) {isExpanded ? '▼' : '▶'}
              </Text>
            )}
          </>
        )}

        {isExpanded && hasEdits && (
          <View style={styles.editHistory}>
            <Text style={styles.editHistoryTitle}>Edit History:</Text>
            {item.editHistory.map((edit: any, idx: number) => (
              <View key={idx} style={styles.editItem}>
                <Text style={styles.editContent}>{edit.content}</Text>
                <Text style={styles.editTime}>
                  {new Date(edit.timestamp).toLocaleTimeString()}
                </Text>
              </View>
            ))}
            <View style={styles.editItem}>
              <Text style={styles.editContent}>{item.content}</Text>
              <Text style={styles.editTime}>Current</Text>
            </View>
          </View>
        )}
      </TouchableOpacity>
    );
  };

  return (
    <FlatList
      data={filteredMessages}
      renderItem={renderMessage}
      keyExtractor={(item) => item.id}
      style={styles.container}
      inverted
    />
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#36393f'
  },
  messageContainer: {
    padding: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#2c2f33'
  },
  messageHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 4
  },
  username: {
    color: '#fff',
    fontWeight: 'bold',
    fontSize: 14
  },
  timestamp: {
    color: '#72767d',
    fontSize: 12
  },
  content: {
    color: '#dcddde',
    fontSize: 14,
    marginTop: 4
  },
  deletedContainer: {
    marginTop: 4,
    paddingHorizontal: 8,
    paddingVertical: 6,
    backgroundColor: '#2c2f33',
    borderRadius: 4,
    borderLeftWidth: 3,
    borderLeftColor: '#ed4245'
  },
  deletedContent: {
    color: '#72767d',
    fontStyle: 'italic',
    fontSize: 13
  },
  hiddenContentLabel: {
    color: '#72767d',
    fontSize: 11,
    marginTop: 4
  },
  editedLabel: {
    color: '#72767d',
    fontSize: 11,
    marginTop: 4
  },
  editHistory: {
    marginTop: 8,
    paddingLeft: 12,
    borderLeftWidth: 2,
    borderLeftColor: '#7289da'
  },
  editHistoryTitle: {
    color: '#7289da',
    fontSize: 11,
    fontWeight: 'bold',
    marginBottom: 4
  },
  editItem: {
    marginBottom: 6,
    paddingHorizontal: 8,
    paddingVertical: 4,
    backgroundColor: '#2c2f33',
    borderRadius: 3
  },
  editContent: {
    color: '#dcddde',
    fontSize: 13
  },
  editTime: {
    color: '#72767d',
    fontSize: 10,
    marginTop: 2
  }
});
