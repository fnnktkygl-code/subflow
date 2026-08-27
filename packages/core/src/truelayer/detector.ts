import { TrueLayerTransaction, DetectedSubscription } from './types';
import { COMPLETE_SUBSCRIPTION_CATALOG } from '../presets/catalog';
import { calculateNextRenewalDate } from '../math/budget';
import { fetchLogo } from '../utils/logo';

/**
 * Nettoie les libellés bancaires français (STET / SEPA / CB) pour isoler le nom du marchand
 */
export function cleanTransactionDescription(rawDesc: string): string {
  if (!rawDesc) return 'Prélèvement Récurrent';

  let cleaned = rawDesc.trim();

  // 1. Supprimer les préfixes bancaires courants
  const prefixes = [
    /^PRLV\s+SEPA\s+/i,
    /^PRELEVEMENT\s+SEPA\s+/i,
    /^PRELEVEMENT\s+/i,
    /^PRLV\s+/i,
    /^VIR\s+SEPA\s+/i,
    /^VIR\s+INST\s+/i,
    /^VIR\s+/i,
    /^PAIEMENT\s+PAR\s+CARTE\s+/i,
    /^PAIEMENT\s+CB\s+/i,
    /^ACHAT\s+CB\s+/i,
    /^CARTE\s+/i,
    /^CB\s+/i,
    /^FACTURE\s+/i,
    /^COTISATION\s+/i,
    /^ABONNEMENT\s+/i
  ];

  for (const p of prefixes) {
    cleaned = cleaned.replace(p, '');
  }

  // 2. Supprimer les dates, numéros de facture ou références techniques
  // ex: "NETFLIX 270826 123456" ou "SPOTIFY COM - REF 987654"
  cleaned = cleaned.replace(/\b\d{2}[/-]\d{2}[/-]\d{2,4}\b/g, '');
  cleaned = cleaned.replace(/\b\d{6,}\b/g, '');
  cleaned = cleaned.replace(/REF[:\s]+\w+/gi, '');
  cleaned = cleaned.replace(/\b(FACTURE|FACTURES|SERVICES|FRANCE|SARL|SAS|LTD|INC|SA|COM|FR|EU|IE|LU)\b/gi, '');
  cleaned = cleaned.replace(/[*\-_#]/g, ' ');
  cleaned = cleaned.replace(/\s+/g, ' ').trim();

  if (cleaned.length === 0) return rawDesc.trim();

  // Capitaliser proprement
  return cleaned
    .split(' ')
    .filter(Boolean)
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase())
    .join(' ');
}

/**
 * Recherche une correspondance dans le catalogue 365+ de SubFlow
 */
export function findMatchingCatalogItem(cleanedName: string) {
  const nameLower = cleanedName.toLowerCase().replace(/[^a-z0-9]/g, '');

  for (const item of COMPLETE_SUBSCRIPTION_CATALOG) {
    const itemNameLower = item.name.toLowerCase().replace(/[^a-z0-9]/g, '');
    if (nameLower.includes(itemNameLower) || itemNameLower.includes(nameLower)) {
      return item;
    }
  }

  return null;
}

/**
 * Détecte les abonnements récurrents à partir d'une liste de transactions bancaires
 */
export function detectSubscriptionsFromTransactions(
  transactions: TrueLayerTransaction[],
  options: {
    currency?: string;
    currencySymbol?: string;
  } = {}
): DetectedSubscription[] {
  const currency = options.currency || 'EUR';
  const currencySymbol = options.currencySymbol || '€';

  // 1. Filtrer uniquement les débits (dépenses)
  const debitTxs = transactions.filter((t) => {
    const amt = typeof t.amount === 'number' ? Math.abs(t.amount) : 0;
    return amt > 0.5; // Ignorer les micro-transactions < 0.50 €
  });

  // 2. Regrouper les transactions par marchand normalisé
  const groups = new Map<string, TrueLayerTransaction[]>();

  for (const tx of debitTxs) {
    const rawName = tx.counterpartyName || tx.description || 'Inconnu';
    const cleanedKey = cleanTransactionDescription(rawName).toLowerCase();

    const existing = groups.get(cleanedKey) || [];
    existing.push(tx);
    groups.set(cleanedKey, existing);
  }

  const detected: DetectedSubscription[] = [];

  // 3. Analyser chaque groupe de transactions
  for (const [, txs] of groups.entries()) {
    if (!txs || txs.length === 0) continue;

    // Trier par date croissante
    txs.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());

    const representativeTx = txs[txs.length - 1];
    if (!representativeTx) continue;

    const rawName = representativeTx.counterpartyName || representativeTx.description;
    const cleanName = cleanTransactionDescription(rawName);
    const catalogMatch = findMatchingCatalogItem(cleanName);

    // Calcul du montant moyen
    const amounts = txs.map((t) => Math.abs(t.amount));
    const avgAmount = Math.round((amounts.reduce((sum, a) => sum + a, 0) / amounts.length) * 100) / 100;

    const occurrencesCount = txs.length;
    const lastChargeDate = representativeTx.date.slice(0, 10);

    let cycle: 'monthly' | 'yearly' | 'weekly' | 'custom' = 'monthly';
    let frequencyDays = 30;
    let confidenceScore = 0.5;
    let confidence: 'high' | 'medium' | 'low' = 'medium';

    if (occurrencesCount >= 2) {
      // Calculer les intervalles en jours entre prélèvements consécutifs
      const intervals: number[] = [];
      for (let i = 1; i < txs.length; i++) {
        const prevTx = txs[i - 1];
        const currTx = txs[i];
        if (prevTx && currTx) {
          const d1 = new Date(prevTx.date).getTime();
          const d2 = new Date(currTx.date).getTime();
          const diffDays = Math.round(Math.abs(d2 - d1) / (1000 * 60 * 60 * 24));
          intervals.push(diffDays);
        }
      }

      const avgInterval = intervals.length > 0
        ? Math.round(intervals.reduce((s, i) => s + i, 0) / intervals.length)
        : 30;
      frequencyDays = avgInterval;

      // Variance des montants
      const maxDiffAmount = Math.max(...amounts) - Math.min(...amounts);
      const isAmountConsistent = maxDiffAmount <= 1.0 || maxDiffAmount / avgAmount < 0.1;

      if (avgInterval >= 26 && avgInterval <= 35) {
        cycle = 'monthly';
        confidenceScore = isAmountConsistent ? 0.95 : 0.8;
      } else if (avgInterval >= 345 && avgInterval <= 385) {
        cycle = 'yearly';
        confidenceScore = isAmountConsistent ? 0.9 : 0.75;
      } else if (avgInterval >= 6 && avgInterval <= 8) {
        cycle = 'weekly';
        confidenceScore = isAmountConsistent ? 0.85 : 0.7;
      } else {
        cycle = 'custom';
        confidenceScore = 0.6;
      }

      // Bonus si présent dans notre catalogue officiel 365+
      if (catalogMatch) {
        confidenceScore = Math.min(1.0, confidenceScore + 0.1);
      }
    } else {
      // 1 seule occurrence : si c'est un service reconnu du catalogue (Netflix, Spotify, Canal+)
      if (catalogMatch) {
        cycle = 'monthly';
        confidenceScore = 0.85; // Haute confiance car c'est un service d'abonnement universel connu
      } else {
        confidenceScore = 0.4;
      }
    }

    if (confidenceScore >= 0.8) {
      confidence = 'high';
    } else if (confidenceScore >= 0.6) {
      confidence = 'medium';
    } else {
      confidence = 'low';
    }

    // Calculer la prochaine date de renouvellement estimée
    const nextEstimatedDate = calculateNextRenewalDate(lastChargeDate, cycle);

    // Déterminer la catégorie finale
    const finalCategory = catalogMatch?.category || representativeTx.category || 'General';
    const finalName = catalogMatch?.name || cleanName;

    // Ne retenir que les abonnements avec confiance >= medium ou match catalogue
    if (confidenceScore >= 0.5 || catalogMatch) {
      detected.push({
        id: `tl-sub-${finalName.toLowerCase().replace(/[^a-z0-9]/g, '-')}-${avgAmount}`,
        name: finalName,
        amount: avgAmount,
        currency: representativeTx.currency || currency,
        currencySymbol,
        cycle,
        category: finalCategory,
        lastChargeDate,
        nextEstimatedDate,
        frequencyDays,
        occurrencesCount,
        confidence,
        confidenceScore: Math.round(confidenceScore * 100) / 100,
        matchedCatalogItem: catalogMatch
          ? {
              id: catalogMatch.id,
              name: catalogMatch.name,
              domain: catalogMatch.domain,
              logoUrl: fetchLogo(catalogMatch.name),
              category: catalogMatch.category,
              cancellationUrl: catalogMatch.cancellationUrl
            }
          : undefined,
        sampleTransactions: txs.map((t) => ({
          id: t.id,
          date: t.date.slice(0, 10),
          amount: Math.abs(t.amount),
          description: t.description
        }))
      });
    }
  }

  // Trier par confiance décroissante puis montant décroissant
  detected.sort((a, b) => b.confidenceScore - a.confidenceScore || b.amount - a.amount);

  return detected;
}

/**
/**
 * Générateur de transactions bancaires réalistes pour la démo / Sandbox / BoursoBank / Revolut
 */
export function getMockFrenchBankTransactions(bankId?: string): TrueLayerTransaction[] {
  const now = new Date();
  const getMonthDate = (monthsAgo: number, day: number): string => {
    const d = new Date(now.getFullYear(), now.getMonth() - monthsAgo, day);
    return d.toISOString().slice(0, 10);
  };

  if (bankId === 'revolut') {
    return [
      // 1. ChatGPT Plus via Revolut
      { id: 'tx-rev-gpt-1', date: getMonthDate(2, 4), description: 'Revolut Card - OPENAI *CHATGPT PLUS', amount: -23.99, counterpartyName: 'OpenAI', category: 'Productivity' },
      { id: 'tx-rev-gpt-2', date: getMonthDate(1, 4), description: 'Revolut Card - OPENAI *CHATGPT PLUS', amount: -23.99, counterpartyName: 'OpenAI', category: 'Productivity' },
      { id: 'tx-rev-gpt-3', date: getMonthDate(0, 4), description: 'Revolut Card - OPENAI *CHATGPT PLUS', amount: -23.99, counterpartyName: 'OpenAI', category: 'Productivity' },

      // 2. Apple One / iCloud via Revolut
      { id: 'tx-rev-apl-1', date: getMonthDate(2, 19), description: 'Revolut Card - APPLE.COM/BILL ICLOUD+', amount: -9.99, counterpartyName: 'Apple', category: 'Productivity' },
      { id: 'tx-rev-apl-2', date: getMonthDate(1, 19), description: 'Revolut Card - APPLE.COM/BILL ICLOUD+', amount: -9.99, counterpartyName: 'Apple', category: 'Productivity' },
      { id: 'tx-rev-apl-3', date: getMonthDate(0, 19), description: 'Revolut Card - APPLE.COM/BILL ICLOUD+', amount: -9.99, counterpartyName: 'Apple', category: 'Productivity' },

      // 3. Spotify via Revolut
      { id: 'tx-rev-spt-1', date: getMonthDate(2, 15), description: 'Revolut Card - SPOTIFY AB STOCKHOLM', amount: -10.99, counterpartyName: 'Spotify', category: 'Entertainment' },
      { id: 'tx-rev-spt-2', date: getMonthDate(1, 15), description: 'Revolut Card - SPOTIFY AB STOCKHOLM', amount: -10.99, counterpartyName: 'Spotify', category: 'Entertainment' },
      { id: 'tx-rev-spt-3', date: getMonthDate(0, 15), description: 'Revolut Card - SPOTIFY AB STOCKHOLM', amount: -10.99, counterpartyName: 'Spotify', category: 'Entertainment' },

      // 4. Claude Pro (Anthropic)
      { id: 'tx-rev-cld-1', date: getMonthDate(1, 12), description: 'Revolut Card - ANTHROPIC *CLAUDE.AI', amount: -21.60, counterpartyName: 'Anthropic', category: 'Productivity' },
      { id: 'tx-rev-cld-2', date: getMonthDate(0, 12), description: 'Revolut Card - ANTHROPIC *CLAUDE.AI', amount: -21.60, counterpartyName: 'Anthropic', category: 'Productivity' },

      // 5. Non-recurring
      { id: 'tx-rev-ubr', date: getMonthDate(0, 20), description: 'Revolut Card - UBER *TRIP AMSTERDAM', amount: -18.40, category: 'Travel' },
      { id: 'tx-rev-amz', date: getMonthDate(0, 25), description: 'Revolut Card - AMAZON PAYMENTS EU', amount: -34.90, category: 'Shopping' }
    ];
  }

  if (bankId === 'stet-boursorama') {
    return [
      // 1. Netflix (SEPA BoursoBank)
      { id: 'tx-brs-nflx-1', date: getMonthDate(2, 27), description: 'PRLV SEPA NETFLIX SERVICES FRANCE FR123456', amount: -13.49, counterpartyName: 'Netflix', category: 'Entertainment' },
      { id: 'tx-brs-nflx-2', date: getMonthDate(1, 27), description: 'PRLV SEPA NETFLIX SERVICES FRANCE FR123456', amount: -13.49, counterpartyName: 'Netflix', category: 'Entertainment' },
      { id: 'tx-brs-nflx-3', date: getMonthDate(0, 27), description: 'PRLV SEPA NETFLIX SERVICES FRANCE FR123456', amount: -13.49, counterpartyName: 'Netflix', category: 'Entertainment' },

      // 2. Freebox Pop (SEPA BoursoBank)
      { id: 'tx-brs-free-1', date: getMonthDate(2, 5), description: 'PRLV SEPA FREE TELECOM FACTURE 987123', amount: -29.99, counterpartyName: 'Free', category: 'Utilities' },
      { id: 'tx-brs-free-2', date: getMonthDate(1, 5), description: 'PRLV SEPA FREE TELECOM FACTURE 987124', amount: -29.99, counterpartyName: 'Free', category: 'Utilities' },
      { id: 'tx-brs-free-3', date: getMonthDate(0, 5), description: 'PRLV SEPA FREE TELECOM FACTURE 987125', amount: -29.99, counterpartyName: 'Free', category: 'Utilities' },

      // 3. Basic-Fit (SEPA BoursoBank)
      { id: 'tx-brs-fit-1', date: getMonthDate(2, 1), description: 'PRLV SEPA BASIC-FIT FRANCE II SARL', amount: -29.99, counterpartyName: 'Basic-Fit', category: 'Fitness' },
      { id: 'tx-brs-fit-2', date: getMonthDate(1, 1), description: 'PRLV SEPA BASIC-FIT FRANCE II SARL', amount: -29.99, counterpartyName: 'Basic-Fit', category: 'Fitness' },
      { id: 'tx-brs-fit-3', date: getMonthDate(0, 1), description: 'PRLV SEPA BASIC-FIT FRANCE II SARL', amount: -29.99, counterpartyName: 'Basic-Fit', category: 'Fitness' },

      // 4. Spotify (CB BoursoBank)
      { id: 'tx-brs-spt-1', date: getMonthDate(2, 15), description: 'CB SPOTIFY COM PREMIUM FACTURE', amount: -10.99, counterpartyName: 'Spotify', category: 'Entertainment' },
      { id: 'tx-brs-spt-2', date: getMonthDate(1, 15), description: 'CB SPOTIFY COM PREMIUM FACTURE', amount: -10.99, counterpartyName: 'Spotify', category: 'Entertainment' },
      { id: 'tx-brs-spt-3', date: getMonthDate(0, 15), description: 'CB SPOTIFY COM PREMIUM FACTURE', amount: -10.99, counterpartyName: 'Spotify', category: 'Entertainment' },

      // 5. Non-recurring
      { id: 'tx-brs-lecl', date: getMonthDate(0, 18), description: 'CB E.LECLERC DRIVE PARIS', amount: -68.40, category: 'Groceries' },
      { id: 'tx-brs-sncf', date: getMonthDate(1, 10), description: 'CB SNCF VOYAGEURS TGV INOUI', amount: -54.00, category: 'Travel' }
    ];
  }

  return [
    // Standard mock transactions
    { id: 'tx-nflx-1', date: getMonthDate(2, 27), description: 'PRLV SEPA NETFLIX SERVICES FRANCE', amount: -13.49, counterpartyName: 'Netflix', category: 'Entertainment' },
    { id: 'tx-nflx-2', date: getMonthDate(1, 27), description: 'PRLV SEPA NETFLIX SERVICES FRANCE', amount: -13.49, counterpartyName: 'Netflix', category: 'Entertainment' },
    { id: 'tx-nflx-3', date: getMonthDate(0, 27), description: 'PRLV SEPA NETFLIX SERVICES FRANCE', amount: -13.49, counterpartyName: 'Netflix', category: 'Entertainment' },

    { id: 'tx-spt-1', date: getMonthDate(2, 15), description: 'CB SPOTIFY COM PREMIUM', amount: -10.99, counterpartyName: 'Spotify', category: 'Entertainment' },
    { id: 'tx-spt-2', date: getMonthDate(1, 15), description: 'CB SPOTIFY COM PREMIUM', amount: -10.99, counterpartyName: 'Spotify', category: 'Entertainment' },
    { id: 'tx-spt-3', date: getMonthDate(0, 15), description: 'CB SPOTIFY COM PREMIUM', amount: -10.99, counterpartyName: 'Spotify', category: 'Entertainment' },

    { id: 'tx-free-1', date: getMonthDate(2, 5), description: 'PRLV SEPA FREE TELECOM FACTURE 876543', amount: -29.99, counterpartyName: 'Free', category: 'Utilities' },
    { id: 'tx-free-2', date: getMonthDate(1, 5), description: 'PRLV SEPA FREE TELECOM FACTURE 876544', amount: -29.99, counterpartyName: 'Free', category: 'Utilities' },
    { id: 'tx-free-3', date: getMonthDate(0, 5), description: 'PRLV SEPA FREE TELECOM FACTURE 876545', amount: -29.99, counterpartyName: 'Free', category: 'Utilities' },

    { id: 'tx-fit-1', date: getMonthDate(2, 1), description: 'PRLV SEPA BASIC-FIT FRANCE II SARL', amount: -29.99, counterpartyName: 'Basic-Fit', category: 'Fitness' },
    { id: 'tx-fit-2', date: getMonthDate(1, 1), description: 'PRLV SEPA BASIC-FIT FRANCE II SARL', amount: -29.99, counterpartyName: 'Basic-Fit', category: 'Fitness' },
    { id: 'tx-fit-3', date: getMonthDate(0, 1), description: 'PRLV SEPA BASIC-FIT FRANCE II SARL', amount: -29.99, counterpartyName: 'Basic-Fit', category: 'Fitness' },

    { id: 'tx-gpt-1', date: getMonthDate(1, 1), description: 'CB OPENAI *CHATGPT SUBSCRIPTION', amount: -24.00, counterpartyName: 'OpenAI', category: 'Productivity' },
    { id: 'tx-gpt-2', date: getMonthDate(0, 1), description: 'CB OPENAI *CHATGPT SUBSCRIPTION', amount: -24.00, counterpartyName: 'OpenAI', category: 'Productivity' },

    { id: 'tx-carrefour', date: getMonthDate(0, 18), description: 'CB CARREFOUR MARKET PARIS 15', amount: -42.50, category: 'Groceries' },
    { id: 'tx-resto', date: getMonthDate(0, 22), description: 'CB RESTAURANT LE BISTROT', amount: -28.00, category: 'Dining' },
    { id: 'tx-sncf', date: getMonthDate(1, 12), description: 'ACHAT SNCF CONNECT BILLET TGV', amount: -65.00, category: 'Travel' }
  ];
}

