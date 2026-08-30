import { create } from 'zustand';

export interface MessageEdit {
  content: string;
  timestamp: number;
}

export interface Message {
  id: string;
  channelId: string;
  userId: string;
  username: string;
  content: string;
  timestamp: number;
  editHistory: MessageEdit[];
  deletedAt?: number;
  deletedBy?: string;
}

interface MessageStore {
  messages: Message[];
  addMessage: (message: Omit<Message, 'editHistory' | 'deletedAt' | 'deletedBy'>) => void;
  editMessage: (messageId: string, newContent: string) => void;
  deleteMessage: (messageId: string, deletedBy?: string) => void;
  clearMessages: () => void;
  getMessagesByChannel: (channelId: string) => Message[];
  getMessagesByUser: (userId: string) => Message[];
  getMessage: (messageId: string) => Message | undefined;
}

export const useMessageStore = create<MessageStore>((set, get) => ({
  messages: [],

  addMessage: (message) => set((state) => ({
    messages: [...state.messages, {
      ...message,
      editHistory: [],
    }]
  })),

  editMessage: (messageId, newContent) => set((state) => ({
    messages: state.messages.map(msg => {
      if (msg.id !== messageId) return msg;

      return {
        ...msg,
        editHistory: [...msg.editHistory, { content: msg.content, timestamp: Date.now() }],
        content: newContent
      };
    })
  })),

  deleteMessage: (messageId, deletedBy) => set((state) => ({
    messages: state.messages.map(msg =>
      msg.id === messageId
        ? { ...msg, deletedAt: Date.now(), deletedBy }
        : msg
    )
  })),

  clearMessages: () => set({ messages: [] }),

  getMessagesByChannel: (channelId) => {
    const { messages } = get();
    return messages.filter(m => m.channelId === channelId);
  },

  getMessagesByUser: (userId) => {
    const { messages } = get();
    return messages.filter(m => m.userId === userId);
  },

  getMessage: (messageId) => {
    const { messages } = get();
    return messages.find(m => m.id === messageId);
  }
}));
