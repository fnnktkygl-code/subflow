export interface TrueLayerTransaction {
  id: string;
  date: string; // ISO YYYY-MM-DD or full ISO
  description: string;
  amount: number; // Negative for debits/expenses (or positive in some raw APIs)
  currency?: string;
  accountId?: string;
  accountName?: string;
  accountType?: string;
  counterpartyName?: string;
  category?: string;
}

export interface DetectedSubscription {
  id: string;
  name: string;
  amount: number;
  currency: string;
  currencySymbol: string;
  cycle: 'monthly' | 'yearly' | 'weekly' | 'custom';
  category: string;
  lastChargeDate: string;
  nextEstimatedDate: string;
  frequencyDays: number;
  occurrencesCount: number;
  confidence: 'high' | 'medium' | 'low';
  confidenceScore: number; // 0.0 to 1.0
  matchedCatalogItem?: {
    id: string;
    name: string;
    domain?: string;
    logoUrl?: string;
    category: string;
    cancellationUrl?: string;
    supportUrl?: string;
  };
  sampleTransactions: Array<{
    id: string;
    date: string;
    amount: number;
    description: string;
  }>;
}

export interface TrueLayerBankProvider {
  id: string;
  name: string;
  country: string;
  logo: string;
  popular?: boolean;
}

export const POPULAR_FRENCH_BANKS: TrueLayerBankProvider[] = [
  { id: 'stet-boursorama', name: 'BoursoBank', country: 'FR', logo: '🏛️', popular: true },
  { id: 'stet-bnp-paribas', name: 'BNP Paribas', country: 'FR', logo: '🏦', popular: true },
  { id: 'stet-credit-agricole', name: 'Crédit Agricole', country: 'FR', logo: '🌾', popular: true },
  { id: 'stet-societe-generale', name: 'Société Générale', country: 'FR', logo: '🔴', popular: true },
  { id: 'stet-la-banque-postale', name: 'La Banque Postale', country: 'FR', logo: '📮', popular: true },
  { id: 'revolut', name: 'Revolut', country: 'FR', logo: '⚡', popular: true },
  { id: 'mock-sandbox', name: 'Banque Démo (Sandbox Test)', country: 'FR', logo: '🧪', popular: true }
];
