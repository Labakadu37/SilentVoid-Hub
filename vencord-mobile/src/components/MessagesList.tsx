import React, { useEffect, useState } from 'react';
import { View, Text, FlatList, StyleSheet, ScrollView } from 'react-native';
import { useMessageStore } from '../store/messageStore';

export interface MessagesListProps {
  channelId?: string;
  userId?: string;
}

export const MessagesList: React.FC<MessagesListProps> = ({ channelId, userId }) => {
  const messages = useMessageStore((state) => state.messages);
  const [filteredMessages, setFilteredMessages] = useState(messages);

  useEffect(() => {
    if (channelId) {
      setFilteredMessages(useMessageStore.getState().getMessagesByChannel(channelId));
    } else if (userId) {
      setFilteredMessages(useMessageStore.getState().getMessagesByUser(userId));
    } else {
      setFilteredMessages(messages);
    }
  }, [messages, channelId, userId]);

  const renderMessage = ({ item }: { item: any }) => (
    <View style={styles.messageContainer}>
      <View style={styles.messageHeader}>
        <Text style={styles.username}>{item.username}</Text>
        <Text style={styles.timestamp}>
          {new Date(item.timestamp).toLocaleString()}
        </Text>
      </View>
      <Text style={[styles.content, item.deleted && styles.deletedContent]}>
        {item.deleted ? '[Message deleted]' : item.content}
      </Text>
      {item.edited && (
        <Text style={styles.editedLabel}>(edited)</Text>
      )}
    </View>
  );

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
  deletedContent: {
    color: '#72767d',
    fontStyle: 'italic'
  },
  editedLabel: {
    color: '#72767d',
    fontSize: 11,
    marginTop: 4
  }
});
