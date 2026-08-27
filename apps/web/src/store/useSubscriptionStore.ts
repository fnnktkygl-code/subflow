'use client';

import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { Subscription, UserProfile, fetchLogo, detectUserCountry } from '@subflow/core';

export interface GoogleAccount {
  email: string;
  name: string;
  picture?: string;
  accessToken: string;
  expiresAt?: number;
  lastSyncedAt?: string;
}

export type DriveSyncStatus = 'idle' | 'syncing' | 'synced' | 'error';

interface SubFlowState {
  subscriptions: Subscription[];
  profile: UserProfile;
  isSelectionMode: boolean;
  excludedIds: string[];
  isAmountBlurred: boolean;
  activeCategoryFilter: string | null;

  // Google Drive Cloud Sync State
  googleAccount: GoogleAccount | null;
  driveSyncStatus: DriveSyncStatus;
  driveSyncError: string | null;
  googleClientId: string | null;

  // Actions
  addSubscription: (sub: Omit<Subscription, 'id'>) => void;
  updateSubscription: (id: string, updates: Partial<Subscription>) => void;
  deleteSubscription: (id: string) => void;
  toggleSelectionMode: () => void;
  toggleExcludedId: (id: string) => void;
  selectAllExcludedIds: () => void;
  clearExcludedIds: () => void;
  toggleAmountBlur: () => void;
  updateProfile: (profile: Partial<UserProfile>) => void;
  setMonthlySpendLimit: (limit: number | null) => void;
  setCategoryFilter: (category: string | null) => void;
  setGoogleAccount: (account: GoogleAccount | null) => void;
  setDriveSyncStatus: (status: DriveSyncStatus, error?: string | null) => void;
  setGoogleClientId: (clientId: string | null) => void;
  restoreFromCloud: (data: { subscriptions?: Subscription[]; profile?: Partial<UserProfile> }) => void;
}


const DEFAULT_SUBSCRIPTIONS: Subscription[] = [];

const DEFAULT_PROFILE: UserProfile = {
  id: 'usr-default',
  name: 'Richard',
  email: '',
  currency: 'EUR',
  currencySymbol: '€',
  countryCode: 'FR',
  spendingGoal: 0,
  monthlyIncome: 0,
  isIncomeConfigured: false,
  themeMode: 'light'
};


export const useSubscriptionStore = create<SubFlowState>()(
  persist(
    (set) => ({
      subscriptions: DEFAULT_SUBSCRIPTIONS,
      profile: DEFAULT_PROFILE,
      isSelectionMode: false,
      excludedIds: [],
      isAmountBlurred: false,
      activeCategoryFilter: null,

      // Google Drive State
      googleAccount: null,
      driveSyncStatus: 'idle',
      driveSyncError: null,
      googleClientId: null,

      addSubscription: (newSub) =>
        set((state) => ({
          subscriptions: [
            ...state.subscriptions,
            {
              ...newSub,
              logoUrl: newSub.logoUrl || fetchLogo(newSub.name),
              id: `sub-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`
            }
          ]
        })),

      updateSubscription: (id, updates) =>
        set((state) => ({
          subscriptions: state.subscriptions.map((sub) =>
            sub.id === id
              ? {
                  ...sub,
                  ...updates,
                  logoUrl: updates.logoUrl || (updates.name ? fetchLogo(updates.name) : sub.logoUrl)
                }
              : sub
          )
        })),

      deleteSubscription: (id) =>
        set((state) => ({
          subscriptions: state.subscriptions.filter((sub) => sub.id !== id),
          excludedIds: state.excludedIds.filter((excludedId) => excludedId !== id)
        })),

      toggleSelectionMode: () =>
        set((state) => ({
          isSelectionMode: !state.isSelectionMode,
          excludedIds: state.isSelectionMode ? [] : state.excludedIds
        })),

      toggleExcludedId: (id) =>
        set((state) => ({
          excludedIds: state.excludedIds.includes(id)
            ? state.excludedIds.filter((item) => item !== id)
            : [...state.excludedIds, id]
        })),

      selectAllExcludedIds: () =>
        set((state) => ({
          excludedIds: state.subscriptions.map((s) => s.id)
        })),

      clearExcludedIds: () => set({ excludedIds: [] }),

      toggleAmountBlur: () => set((state) => ({ isAmountBlurred: !state.isAmountBlurred })),

      updateProfile: (updated) =>
        set((state) => ({
          profile: { ...state.profile, ...updated }
        })),

      setMonthlySpendLimit: (limit) =>
        set((state) => ({
          profile: {
            ...state.profile,
            spendingGoal: limit !== null ? limit : undefined,
            monthlySpendLimit: limit !== null ? limit : undefined
          }
        })),

      setCategoryFilter: (category) => set({ activeCategoryFilter: category }),

      setGoogleAccount: (account) =>
        set((state) => ({
          googleAccount: account,
          driveSyncStatus: account ? 'synced' : 'idle',
          driveSyncError: null
        })),

      setDriveSyncStatus: (status, error = null) =>
        set((state) => ({
          driveSyncStatus: status,
          driveSyncError: error,
          googleAccount: state.googleAccount
            ? {
                ...state.googleAccount,
                lastSyncedAt: status === 'synced' ? new Date().toISOString() : state.googleAccount.lastSyncedAt
              }
            : null
        })),

      setGoogleClientId: (clientId) => set({ googleClientId: clientId }),

      restoreFromCloud: (data) =>
        set((state) => ({
          subscriptions: Array.isArray(data.subscriptions) && data.subscriptions.length > 0
            ? data.subscriptions
            : state.subscriptions,
          profile: data.profile
            ? { ...state.profile, ...data.profile }
            : state.profile,
          driveSyncStatus: 'synced',
          driveSyncError: null
        }))
    }),

    {
      name: 'subflow-storage',
      onRehydrateStorage: () => (state) => {
        if (state && (state.profile?.themeMode as string) === 'vibrant') {
          state.profile.themeMode = 'light';
        }
      }
    }
  )
);

if (typeof window !== 'undefined') {
  (window as any).__store = useSubscriptionStore;
}


