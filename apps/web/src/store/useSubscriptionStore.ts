'use client';

import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { Subscription, UserProfile, fetchLogo, detectUserCountry } from '@subflow/core';

interface SubFlowState {
  subscriptions: Subscription[];
  profile: UserProfile;
  isSelectionMode: boolean;
  excludedIds: string[];
  isAmountBlurred: boolean;
  activeCategoryFilter: string | null;

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
}

const DEFAULT_SUBSCRIPTIONS: Subscription[] = [
  {
    id: 'sub-netflix',
    name: 'Netflix',
    amount: 13.49,
    category: 'Entertainment',
    cycle: 'Monthly',
    startDate: '2026-08-27',
    logoUrl: fetchLogo('Netflix'),
    status: 'active'
  },
  {
    id: 'sub-spotify',
    name: 'Spotify',
    amount: 10.99,
    category: 'Entertainment',
    cycle: 'Monthly',
    startDate: '2026-08-15',
    logoUrl: fetchLogo('Spotify'),
    status: 'active'
  },
  {
    id: 'sub-chatgpt',
    name: 'ChatGPT Plus',
    amount: 24.00,
    category: 'Productivity',
    cycle: 'Monthly',
    startDate: '2026-08-01',
    logoUrl: fetchLogo('ChatGPT'),
    status: 'active'
  }
];

const DEFAULT_PROFILE: UserProfile = {
  id: 'usr-default',
  name: 'Richard',
  email: 'richard@subflow.app',
  currency: 'EUR',
  currencySymbol: '€',
  countryCode: 'FR',
  spendingGoal: 80,
  monthlyIncome: 2500,
  isIncomeConfigured: true,
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

      setCategoryFilter: (category) => set({ activeCategoryFilter: category })
    }),
    {
      name: 'subflow-storage'
    }
  )
);
