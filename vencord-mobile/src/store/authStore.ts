import { create } from 'zustand';

interface User {
  id: string;
  username: string;
  discriminator: string;
  avatar?: string;
  token: string;
}

interface AuthStore {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  setUser: (user: User) => void;
  setToken: (token: string) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthStore>((set) => ({
  user: null,
  token: null,
  isAuthenticated: false,

  setUser: (user) => set({
    user,
    isAuthenticated: true
  }),

  setToken: (token) => set({
    token,
    isAuthenticated: true
  }),

  logout: () => set({
    user: null,
    token: null,
    isAuthenticated: false
  })
}));
