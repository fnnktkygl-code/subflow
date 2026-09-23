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
  amount: z.number().finite().positive('Amount must be greater than 0').max(1000000000),
  currency: z.string().default('EUR').optional(),
  currencySymbol: z.string().default('€').optional(),
  category: z.string().min(1).max(100),
  cycle: z.string().min(1).max(30).refine(value => ['daily','weekly','biweekly','fortnightly','monthly','quarterly','semiannual','semiannually','halfyearly','yearly','annual','annually'].includes(value.toLowerCase().replace(/[\s_-]/g, '')), 'Invalid cycle'),
  startDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Invalid date format (YYYY-MM-DD)').refine(value => { const date = new Date(value + 'T00:00:00Z'); return Number.isFinite(date.getTime()) && date.toISOString().slice(0, 10) === value; }, 'Invalid calendar date'),
  logoUrl: z.string().optional(),
  status: z.enum(['active', 'paused', 'snoozed']).optional().default('active'),
  notes: z.string().max(500).optional()
});

export const userProfileSchema = z.object({
  name: z.string().min(1).default('User'),
  email: z.union([z.string().email(), z.literal('')]).optional(),
  currency: z.string().default('EUR'),
  currencySymbol: z.string().default('€'),
  countryCode: z.string().default('FR').optional(),
  spendingGoal: z.number().min(0).default(0).optional(),
  monthlyIncome: z.number().min(0).default(0),
  monthlyTarget: z.number().min(0).default(0).optional(),
  isIncomeConfigured: z.boolean().default(false).optional(),
  theme: z.string().optional(),
  themeMode: z.enum(['system', 'light', 'dark', 'barbie']).default('system').optional()
});
