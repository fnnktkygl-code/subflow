'use client';

import { browserStorage, setBrowserStorageItemStrict } from './browserStorage';
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { Subscription, UserProfile, fetchLogo, subscriptionSchema, userProfileSchema } from '@subflow/core';

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

  // Storage and Onboarding Mode
  hasCompletedOnboarding: boolean;
  storageMode: 'cloud' | 'local' | null;

  // Google Drive Cloud Sync State
  googleAccount: GoogleAccount | null;
  driveSyncStatus: DriveSyncStatus;
  driveSyncError: string | null;
  googleClientId: string | null;

  // Actions
  completeOnboarding: (mode: 'cloud' | 'local') => void;
  resetOnboarding: () => void;
  addSubscription: (sub: Omit<Subscription, 'id'>) => void;
  updateSubscription: (id: string, updates: Partial<Subscription>) => void;
  deleteSubscription: (id: string) => void;
  importSubscriptions: (data: unknown) => number;
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
  name: 'Bienvenue',
  email: '',
  currency: 'EUR',
  currencySymbol: '€',
  countryCode: 'FR',
  spendingGoal: 0,
  monthlyIncome: 0,
  isIncomeConfigured: false,
  themeMode: 'light'
};

const STORAGE_KEY = 'subflow-storage-v2';

function persistedState(state: SubFlowState) {
  const { subscriptions, profile, isAmountBlurred, hasCompletedOnboarding, storageMode, googleClientId } = state;
  return { subscriptions, profile, isAmountBlurred, hasCompletedOnboarding, storageMode, googleClientId };
}

function persistBeforeCommit(state: SubFlowState): void {
  setBrowserStorageItemStrict(STORAGE_KEY, JSON.stringify({ state: persistedState(state), version: 0 }));
}


export const useSubscriptionStore = create<SubFlowState>()(
  persist(
    (set, get) => ({
      subscriptions: DEFAULT_SUBSCRIPTIONS,
      profile: DEFAULT_PROFILE,
      isSelectionMode: false,
      excludedIds: [],
      isAmountBlurred: false,
      activeCategoryFilter: null,

      // Storage & Onboarding Initial State
      hasCompletedOnboarding: false,
      storageMode: null,

      // Google Drive State
      googleAccount: null,
      driveSyncStatus: 'idle',
      driveSyncError: null,
      googleClientId: null,

      completeOnboarding: (mode) =>
        set({
          hasCompletedOnboarding: true,
          storageMode: mode
        }),

      resetOnboarding: () =>
        set({
          hasCompletedOnboarding: false,
          storageMode: null
        }),

      addSubscription: (input) => {
        const newSub = subscriptionSchema.omit({ id: true }).parse(input);
        return set((state) => ({
          subscriptions: [
            ...state.subscriptions,
            {
              ...newSub,
              logoUrl: newSub.logoUrl || fetchLogo(newSub.name),
              id: crypto.randomUUID()
            }
          ]
        }));
      },

      importSubscriptions: (data) => {
        const incoming = subscriptionSchema.array().max(10000).parse(data);
        const state = get();
        const fingerprint = (sub: Subscription) => JSON.stringify([sub.name.trim().toLowerCase(), sub.amount, sub.currency || 'EUR', sub.cycle.toLowerCase(), sub.startDate]);
        const keys = new Set(state.subscriptions.map(fingerprint));
        const ids = new Set(state.subscriptions.map(sub => sub.id));
        const additions = incoming.filter(sub => { const key = fingerprint(sub); if (keys.has(key) || ids.has(sub.id)) return false; keys.add(key); ids.add(sub.id); return true; });
        if (state.subscriptions.length + additions.length > 10000) throw new Error('Maximum 10 000 prélèvements');
        const subscriptions = [...state.subscriptions, ...additions];
        persistBeforeCommit({ ...state, subscriptions });
        set({ subscriptions });
        return additions.length;
      },

      updateSubscription: (id, updates) =>
        set((state) => ({
          subscriptions: state.subscriptions.map((sub) =>
            sub.id === id
              ? {
                  ...sub,
                  ...subscriptionSchema.parse({ ...sub, ...updates, id: sub.id }),
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
          storageMode: account ? 'cloud' : 'local',
          hasCompletedOnboarding: account ? true : state.hasCompletedOnboarding,
          driveSyncStatus: 'idle',
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

      restoreFromCloud: (data) => {
        const incoming = subscriptionSchema.array().max(10000).parse(data.subscriptions);
        const incomingProfile = data.profile ? userProfileSchema.partial().parse(data.profile) : {};
        const state = get();
        const profile = { ...state.profile, ...incomingProfile };
        setBrowserStorageItemStrict('subflow-recovery-v1', JSON.stringify({ subscriptions: state.subscriptions, profile: state.profile }));
        persistBeforeCommit({ ...state, subscriptions: incoming, profile });
        set({ subscriptions: incoming, profile, excludedIds: [], isSelectionMode: false, driveSyncStatus: 'synced', driveSyncError: null });
      }

    }),

    {
      name: STORAGE_KEY,
      partialize: persistedState,
      merge: (persisted, current) => {
        const saved = (persisted || {}) as Partial<SubFlowState>;
        return { ...current, subscriptions: Array.isArray(saved.subscriptions) ? saved.subscriptions : current.subscriptions, profile: saved.profile && typeof saved.profile === 'object' ? { ...current.profile, ...saved.profile } : current.profile, isAmountBlurred: saved.isAmountBlurred === true, hasCompletedOnboarding: saved.hasCompletedOnboarding === true, storageMode: saved.storageMode === 'cloud' ? 'cloud' : 'local', googleClientId: typeof saved.googleClientId === 'string' ? saved.googleClientId : null };
      },
      storage: createJSONStorage(() => browserStorage),
      onRehydrateStorage: () => (state) => {
        if (!state) return;
        if ((state.profile?.themeMode as string) === 'vibrant') {
          state.profile.themeMode = 'light';
        }

      }
    }

  )
);
