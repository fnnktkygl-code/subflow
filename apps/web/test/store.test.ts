import { describe, it, expect, beforeEach } from 'vitest';

// Initialize top-level in-memory storage before Zustand store module evaluation
const storageMap = new Map<string, string>();
const localStorageMock = {
  getItem: (key: string) => storageMap.get(key) ?? null,
  setItem: (key: string, value: string) => {
    storageMap.set(key, String(value));
  },
  removeItem: (key: string) => {
    storageMap.delete(key);
  },
  clear: () => {
    storageMap.clear();
  },
  length: 0,
  key: (i: number) => Array.from(storageMap.keys())[i] ?? null
};

if (typeof window === 'undefined') {
  (globalThis as any).window = globalThis;
}
Object.defineProperty(globalThis, 'localStorage', {
  value: localStorageMock,
  writable: true,
  configurable: true
});
Object.defineProperty(globalThis.window, 'localStorage', {
  value: localStorageMock,
  writable: true,
  configurable: true
});

import { useSubscriptionStore } from '../src/store/useSubscriptionStore';

describe('Zustand State Store & Business Interactions', () => {

  beforeEach(() => {
    // Reset store state
    const store = useSubscriptionStore.getState();
    store.clearExcludedIds();
  });

  it('initializes with empty subscriptions array and clean profile', () => {
    const state = useSubscriptionStore.getState();
    expect(Array.isArray(state.subscriptions)).toBe(true);
    expect(state.profile.currencySymbol).toBe('€');
  });

  it('adds a new subscription successfully', () => {
    const store = useSubscriptionStore.getState();
    const initialCount = store.subscriptions.length;

    store.addSubscription({
      name: 'Claude Pro',
      amount: 20,
      category: 'Productivity',
      cycle: 'Monthly',
      startDate: '2026-08-27'
    });

    const updated = useSubscriptionStore.getState();
    expect(updated.subscriptions.length).toBe(initialCount + 1);
    expect(updated.subscriptions.some((s) => s.name === 'Claude Pro')).toBe(true);
  });

  it('updates an existing subscription', () => {
    const store = useSubscriptionStore.getState();
    store.addSubscription({
      name: 'Service to Edit',
      amount: 10,
      category: 'Productivity',
      cycle: 'Monthly',
      startDate: '2026-08-01'
    });

    const created = useSubscriptionStore.getState().subscriptions.find((s) => s.name === 'Service to Edit');
    expect(created).toBeDefined();

    if (created) {
      store.updateSubscription(created.id, { amount: 99.99 });
      const updatedSub = useSubscriptionStore.getState().subscriptions.find((s) => s.id === created.id);
      expect(updatedSub?.amount).toBe(99.99);
    }
  });

  it('deletes a subscription cleanly and removes it from excluded list', () => {
    const store = useSubscriptionStore.getState();
    store.addSubscription({
      name: 'Temp App',
      amount: 5,
      category: 'Utilities',
      cycle: 'Monthly',
      startDate: '2026-08-01'
    });

    const created = useSubscriptionStore.getState().subscriptions.find((s) => s.name === 'Temp App');
    expect(created).toBeDefined();
    const testSubId = created!.id;

    store.toggleExcludedId(testSubId);
    expect(useSubscriptionStore.getState().excludedIds).toContain(testSubId);

    store.deleteSubscription(testSubId);
    const state = useSubscriptionStore.getState();
    expect(state.subscriptions.some((s) => s.id === testSubId)).toBe(false);
    expect(state.excludedIds).not.toContain(testSubId);
  });

  it('handles What-If selection mode toggles and exclusions', () => {
    const store = useSubscriptionStore.getState();
    expect(store.isSelectionMode).toBe(false);

    store.toggleSelectionMode();
    expect(useSubscriptionStore.getState().isSelectionMode).toBe(true);

    const firstId = store.subscriptions[0]?.id || '1';
    store.toggleExcludedId(firstId);
    expect(useSubscriptionStore.getState().excludedIds).toContain(firstId);

    store.toggleExcludedId(firstId);
    expect(useSubscriptionStore.getState().excludedIds).not.toContain(firstId);

    store.selectAllExcludedIds();
    expect(useSubscriptionStore.getState().excludedIds.length).toBe(store.subscriptions.length);

    store.clearExcludedIds();
    expect(useSubscriptionStore.getState().excludedIds.length).toBe(0);
  });

  it('toggles privacy amount blur state', () => {
    const store = useSubscriptionStore.getState();
    const initialBlur = store.isAmountBlurred;

    store.toggleAmountBlur();
    expect(useSubscriptionStore.getState().isAmountBlurred).toBe(!initialBlur);

    store.toggleAmountBlur();
    expect(useSubscriptionStore.getState().isAmountBlurred).toBe(initialBlur);
  });

  it('updates profile settings and income goal', () => {
    const store = useSubscriptionStore.getState();
    store.updateProfile({
      monthlyIncome: 4500,
      spendingGoal: 100,
      currencySymbol: '$',
      currency: 'USD'
    });

    const updated = useSubscriptionStore.getState().profile;
    expect(updated.monthlyIncome).toBe(4500);
    expect(updated.spendingGoal).toBe(100);
    expect(updated.currencySymbol).toBe('$');
  });

  it('manages onboarding state and storage mode', () => {
    const store = useSubscriptionStore.getState();
    store.resetOnboarding();
    expect(useSubscriptionStore.getState().hasCompletedOnboarding).toBe(false);
    expect(useSubscriptionStore.getState().storageMode).toBeNull();

    store.completeOnboarding('local');
    expect(useSubscriptionStore.getState().hasCompletedOnboarding).toBe(true);
    expect(useSubscriptionStore.getState().storageMode).toBe('local');

    store.completeOnboarding('cloud');
    expect(useSubscriptionStore.getState().hasCompletedOnboarding).toBe(true);
    expect(useSubscriptionStore.getState().storageMode).toBe('cloud');
  });

  it('manages filters and monthly spending limits', () => {
    const store = useSubscriptionStore.getState();
    store.setCategoryFilter('Entertainment');
    expect(useSubscriptionStore.getState().activeCategoryFilter).toBe('Entertainment');

    store.setCategoryFilter(null);
    expect(useSubscriptionStore.getState().activeCategoryFilter).toBeNull();

    store.setMonthlySpendLimit(250);
    expect(useSubscriptionStore.getState().profile.spendingGoal).toBe(250);
  });

  it('restores snapshot seamlessly from Google Drive cloud data', () => {
    const store = useSubscriptionStore.getState();
    const cloudSubs = [
      {
        id: 'cloud-1',
        name: 'Disney+',
        amount: 8.99,
        category: 'Entertainment',
        cycle: 'Monthly',
        startDate: '2026-01-01'
      }
    ];

    store.restoreFromCloud({
      subscriptions: cloudSubs,
      profile: { spendingGoal: 150 }
    });

    const state = useSubscriptionStore.getState();
    expect(state.subscriptions.some((s) => s.id === 'cloud-1')).toBe(true);
    expect(state.profile.spendingGoal).toBe(150);
    expect(state.driveSyncStatus).toBe('synced');
    expect(state.driveSyncError).toBeNull();
  });

  it('manages Google Drive cloud sync states', () => {
    const store = useSubscriptionStore.getState();
    store.setGoogleClientId('custom-client-id-xyz');
    expect(useSubscriptionStore.getState().googleClientId).toBe('custom-client-id-xyz');

    store.setGoogleAccount({
      email: 'alex@example.com',
      name: 'Alexandre',
      accessToken: 'token-abc'
    });
    expect(useSubscriptionStore.getState().googleAccount?.email).toBe('alex@example.com');

    store.setDriveSyncStatus('syncing');
    expect(useSubscriptionStore.getState().driveSyncStatus).toBe('syncing');

    store.setDriveSyncStatus('synced');
    expect(useSubscriptionStore.getState().driveSyncStatus).toBe('synced');
    expect(useSubscriptionStore.getState().googleAccount?.lastSyncedAt).toBeDefined();

    store.setDriveSyncStatus('error', 'Token Expired');
    expect(useSubscriptionStore.getState().driveSyncStatus).toBe('error');
    expect(useSubscriptionStore.getState().driveSyncError).toBe('Token Expired');
  });
});

