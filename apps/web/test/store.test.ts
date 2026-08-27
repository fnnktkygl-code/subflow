import { describe, it, expect, beforeEach } from 'vitest';
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
      id: 'test-sub-1',
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
      id: 'test-sub-edit',
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
    const testSubId = 'to-delete-sub';
    store.addSubscription({
      id: testSubId,
      name: 'Temp App',
      amount: 5,
      category: 'Utilities',
      cycle: 'Monthly',
      startDate: '2026-08-01'
    });

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
});
