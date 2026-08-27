import { z } from 'zod';

export const billingCycleSchema = z.enum([
  'Daily',
  'Weekly',
  'Bi-Weekly',
  'Monthly',
  'Quarterly',
  'Semi-Annual',
  'Yearly'
]);

export const subscriptionCategorySchema = z.enum([
  'Entertainment',
  'Productivity',
  'Utilities',
  'Health & Fitness',
  'Food & Dining',
  'Shopping',
  'General'
]);

export const subscriptionSchema = z.object({
  id: z.string().min(1),
  name: z.string().min(1, 'Name is required').max(100),
  amount: z.number().positive('Amount must be greater than 0'),
  currency: z.string().default('EUR').optional(),
  currencySymbol: z.string().default('€').optional(),
  category: z.string().min(1),
  cycle: z.string().min(1),
  startDate: z.string().regex(/^\d{4}-\d{2}-\d{2}/, 'Invalid date format (YYYY-MM-DD)'),
  logoUrl: z.string().optional(),
  status: z.enum(['active', 'paused', 'snoozed']).optional().default('active'),
  notes: z.string().max(500).optional()
});

export const userProfileSchema = z.object({
  name: z.string().min(1).default('User'),
  email: z.string().email().optional(),
  currency: z.string().default('EUR'),
  currencySymbol: z.string().default('€'),
  countryCode: z.string().default('FR').optional(),
  spendingGoal: z.number().min(0).default(0).optional(),
  monthlyIncome: z.number().min(0).default(0),
  monthlyTarget: z.number().min(0).default(0).optional(),
  isIncomeConfigured: z.boolean().default(false).optional(),
  theme: z.string().optional(),
  themeMode: z.enum(['system', 'light', 'dark', 'barbie', 'japandi-light', 'japandi-dark']).default('system').optional()
});
