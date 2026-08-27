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
  domain: string;
  logoUrl: string;
  brandColor?: string;
  popular?: boolean;
}

export const POPULAR_FRENCH_BANKS: TrueLayerBankProvider[] = [
  {
    id: 'stet-boursorama',
    name: 'BoursoBank',
    country: 'FR',
    domain: 'boursobank.com',
    logoUrl: 'https://img.logo.dev/boursobank.com?token=pk_X1cpD_81THS3lP56vQoYTw',
    brandColor: '#E6007E',
    popular: true
  },
  {
    id: 'revolut',
    name: 'Revolut',
    country: 'FR',
    domain: 'revolut.com',
    logoUrl: 'https://img.logo.dev/revolut.com?token=pk_X1cpD_81THS3lP56vQoYTw',
    brandColor: '#000000',
    popular: true
  },
  {
    id: 'stet-bnp-paribas',
    name: 'BNP Paribas',
    country: 'FR',
    domain: 'bnpparibas.com',
    logoUrl: 'https://img.logo.dev/bnpparibas.com?token=pk_X1cpD_81THS3lP56vQoYTw',
    brandColor: '#00965E',
    popular: true
  },
  {
    id: 'stet-credit-agricole',
    name: 'Crédit Agricole',
    country: 'FR',
    domain: 'credit-agricole.fr',
    logoUrl: 'https://img.logo.dev/credit-agricole.fr?token=pk_X1cpD_81THS3lP56vQoYTw',
    brandColor: '#007D8F',
    popular: true
  },
  {
    id: 'stet-societe-generale',
    name: 'Société Générale',
    country: 'FR',
    domain: 'societegenerale.fr',
    logoUrl: 'https://img.logo.dev/societegenerale.fr?token=pk_X1cpD_81THS3lP56vQoYTw',
    brandColor: '#E60028',
    popular: true
  },
  {
    id: 'stet-la-banque-postale',
    name: 'La Banque Postale',
    country: 'FR',
    domain: 'labanquepostale.fr',
    logoUrl: 'https://img.logo.dev/labanquepostale.fr?token=pk_X1cpD_81THS3lP56vQoYTw',
    brandColor: '#0C2340',
    popular: true
  },
  {
    id: 'mock-sandbox',
    name: 'Banque Démo (Sandbox Test)',
    country: 'FR',
    domain: 'truelayer.com',
    logoUrl: 'https://img.logo.dev/truelayer.com?token=pk_X1cpD_81THS3lP56vQoYTw',
    brandColor: '#2563EB',
    popular: true
  }
];

