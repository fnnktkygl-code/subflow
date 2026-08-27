export type BillingCycle = 'Daily' | 'Weekly' | 'Monthly' | 'Quarterly' | 'Yearly';

export type SubscriptionCategory =
  | 'Entertainment'
  | 'Productivity'
  | 'Utilities'
  | 'Health & Fitness'
  | 'Food & Dining'
  | 'Shopping'
  | 'General';

export type ThemeMode = 'light' | 'dark' | 'barbie' | 'vibrant' | 'system';

export interface Subscription {
  id: string;
  name: string;
  amount: number;
  category: SubscriptionCategory | string;
  cycle: BillingCycle | string;
  startDate: string; // ISO date string (YYYY-MM-DD)
  logoUrl?: string;
  status?: 'active' | 'paused' | 'snoozed';
  notes?: string;
  currency?: string;
  currencySymbol?: string;
}

export type IncomeHealthStatus = 'optimal' | 'healthy' | 'warning' | 'critical' | 'unknown';

export interface UserProfile {
  id?: string;
  name: string;
  email?: string;
  currency: string;
  currencySymbol: string;
  countryCode: string;
  spendingGoal?: number;
  monthlySpendLimit?: number;
  monthlyIncome: number;
  isIncomeConfigured: boolean;
  themeMode: ThemeMode;
  language?: 'fr' | 'en';
}

export interface PresetCatalogItem {
  id: string;
  name: string;
  category: SubscriptionCategory | string;
  defaultCycle: BillingCycle | string;
  pricesByCountry: Record<string, { amount: number; currency: string; symbol: string }>;
  iconName: string;
  brandColor?: string;
}

export interface WhatIfSavings {
  monthlySavings: number;
  yearlySavings: number;
  remainingMonthlyCost: number;
  excludedCount: number;
  totalCount: number;
  savingsPercentage: number;
}

export interface Budget503020Split {
  monthlyIncome: number;
  needsTarget: number;
  wantsTarget: number;
  savingsTarget: number;
  fixedCommitmentsTotal: number;
  freeCashFlowRemaining: number;
  healthStatus: IncomeHealthStatus;
  healthMessage: string;
  needs50Limit: number;
  subscriptionsPercentageOfIncome: number;
  isBudgetHealthy: boolean;
}

export interface OccurrencesByMonth {
  [monthIndex: number]: {
    date: Date;
    dayNumber: number;
    subscriptions: Subscription[];
    totalAmount: number;
  }[];
}
