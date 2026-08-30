import { create } from 'zustand';

interface Message {
  id: string;
  channelId: string;
  userId: string;
  username: string;
  content: string;
  timestamp: number;
  edited?: number;
  deleted?: boolean;
}

interface MessageStore {
  messages: Message[];
  addMessage: (message: Message) => void;
  editMessage: (messageId: string, content: string) => void;
  deleteMessage: (messageId: string) => void;
  clearMessages: () => void;
  getMessagesByChannel: (channelId: string) => Message[];
  getMessagesByUser: (userId: string) => Message[];
}

export const useMessageStore = create<MessageStore>((set, get) => ({
  messages: [],

  addMessage: (message) => set((state) => ({
    messages: [...state.messages, message]
  })),

  editMessage: (messageId, content) => set((state) => ({
    messages: state.messages.map(msg =>
      msg.id === messageId
        ? { ...msg, content, edited: Date.now() }
        : msg
    )
  })),

  deleteMessage: (messageId) => set((state) => ({
    messages: state.messages.map(msg =>
      msg.id === messageId
        ? { ...msg, deleted: true }
        : msg
    )
  })),

  clearMessages: () => set({ messages: [] }),

  getMessagesByChannel: (channelId) => {
    const { messages } = get();
    return messages.filter(m => m.channelId === channelId && !m.deleted);
  },

  getMessagesByUser: (userId) => {
    const { messages } = get();
    return messages.filter(m => m.userId === userId && !m.deleted);
  }
}));
