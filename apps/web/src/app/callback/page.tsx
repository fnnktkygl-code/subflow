'use client';

import React, { useEffect, useState, useRef, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import {
  Building2,
  CheckCircle2,
  AlertCircle,
  Sparkles,
  ShieldCheck,
  RefreshCw,
  Plus,
  Check,
  Home
} from 'lucide-react';
import {
  DetectedSubscription,
  detectSubscriptionsFromTransactions,
  formatCurrency,
  Subscription,
  TrueLayerTransaction
} from '@subflow/core';
import { useSubscriptionStore } from '../../store/useSubscriptionStore';
import { SubscriptionLogo } from '@subflow/ui';
import { useTranslation } from '../../hooks/useTranslation';

type CallbackStatus = 'loading' | 'exchanging' | 'fetching_data' | 'review' | 'success' | 'error';

function TrueLayerCallbackContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { addSubscription, profile } = useSubscriptionStore();
  const { locale } = useTranslation();

  const [status, setStatus] = useState<CallbackStatus>('loading');
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [bankName, setBankName] = useState<string>('BoursoBank');
  const [accountsCount, setAccountsCount] = useState<number>(0);
  const [detectedSubs, setDetectedSubs] = useState<DetectedSubscription[]>([]);
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [importedCount, setImportedCount] = useState<number>(0);

  const hasProcessedRef = useRef(false);

  useEffect(() => {
    if (hasProcessedRef.current) return;

    const code = searchParams.get('code');
    const error = searchParams.get('error');
    const errorDescription = searchParams.get('error_description');

    if (error) {
      hasProcessedRef.current = true;
      setStatus('error');
      setErrorMessage(errorDescription || error || 'Autorisation TrueLayer annulée ou refusée.');
      return;
    }

    if (!code) {
      hasProcessedRef.current = true;
      setStatus('error');
      setErrorMessage('Code d\'autorisation manquant dans la redirection.');
      return;
    }

    hasProcessedRef.current = true;
    processTrueLayerAuth(code);
  }, [searchParams]);

    const processTrueLayerAuth = async (code: string) => {
    try {
      setStatus('exchanging');

      // Clean URL immediately
      if (typeof window !== 'undefined') {
        window.history.replaceState({}, document.title, window.location.pathname);
      }

      const redirectUri = typeof window !== 'undefined'
        ? `${window.location.origin}/callback`
        : 'https://subflowapp.vercel.app/callback';

      // 1. Exchange authorization code for token
      let tokenData: any = null;
      try {
        const tokenRes = await fetch('/api/truelayer/token', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ code, redirect_uri: redirectUri })
        });
        if (tokenRes.ok) {
          tokenData = await tokenRes.json();
        }
      } catch (_) {}

      // Direct fallback if API route is not present in static export
      if (!tokenData || !tokenData.access_token) {
        const params = new URLSearchParams();
        params.append('grant_type', 'authorization_code');
        params.append('client_id', 'subflow-6571e7');
        params.append('redirect_uri', redirectUri);
        params.append('code', code);

        const directRes = await fetch('https://auth.truelayer.com/connect/token', {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: params.toString()
        });
        tokenData = await directRes.json();
      }

      if (!tokenData || !tokenData.access_token) {
        throw new Error(tokenData?.error_description || tokenData?.error || 'Impossible d\'échanger le code d\'autorisation avec TrueLayer.');
      }

      const accessToken = tokenData.access_token;
      setStatus('fetching_data');

      // 2. Fetch Bank Accounts
      let accountsData: any = null;
      try {
        const accountsRes = await fetch('/api/truelayer/accounts', {
          headers: { Authorization: `Bearer ${accessToken}` }
        });
        if (accountsRes.ok) {
          accountsData = await accountsRes.json();
        }
      } catch (_) {}

      if (!accountsData || !Array.isArray(accountsData.results)) {
        const directAccountsRes = await fetch('https://api.truelayer.com/data/v1/accounts', {
          headers: { Authorization: `Bearer ${accessToken}` }
        });
        accountsData = await directAccountsRes.json();
      }

      const accountsList = Array.isArray(accountsData?.results) ? accountsData.results : [];
      setAccountsCount(accountsList.length);

      if (accountsList[0]?.provider?.display_name) {
        setBankName(accountsList[0].provider.display_name);
      }

      // 3. Fetch 90 days of transactions across all accounts
      const allTransactions: TrueLayerTransaction[] = [];
      const fromDate = new Date(Date.now() - 90 * 86400000).toISOString();
      const toDate = new Date().toISOString();

      for (const acc of accountsList) {
        try {
          let txData: any = null;
          try {
            const txRes = await fetch(`/api/truelayer/transactions?account_id=${encodeURIComponent(acc.account_id)}`, {
              headers: { Authorization: `Bearer ${accessToken}` }
            });
            if (txRes.ok) txData = await txRes.json();
          } catch (_) {}

          if (!txData || !Array.isArray(txData.results)) {
            const directTxRes = await fetch(
              `https://api.truelayer.com/data/v1/accounts/${acc.account_id}/transactions?from=${fromDate}&to=${toDate}`,
              { headers: { Authorization: `Bearer ${accessToken}` } }
            );
            txData = await directTxRes.json();
          }

          if (Array.isArray(txData?.results)) {
            txData.results.forEach((tx: any) => {
              const txDate = tx.timestamp || tx.date || new Date().toISOString();
              allTransactions.push({
                id: tx.transaction_id || tx.id || String(Math.random()),
                date: txDate,
                description: tx.description || tx.merchant_name || 'Transaction',
                counterpartyName: tx.merchant_name || tx.description,
                amount: Math.abs(Number(tx.amount || 0)),
                currency: tx.currency || 'EUR',
                accountId: acc.account_id,
                accountName: acc.display_name || acc.account_type,
                category: tx.transaction_category || 'DIRECT_DEBIT'
              });
            });
          }
        } catch (_) {}
      }


      // 4. Détection intelligente des récurrences
      const detected = detectSubscriptionsFromTransactions(allTransactions, {
        currency: profile.currency || 'EUR',
        currencySymbol: profile.currencySymbol || '€'
      });

      setDetectedSubs(detected);
      setSelectedIds(new Set(detected.map((s) => s.id)));
      setStatus('review');
    } catch (err: any) {
      setStatus('error');
      setErrorMessage(err.message || 'Une erreur est survenue lors de la synchronisation bancaire.');
    }
  };

  const toggleSelect = (id: string) => {
    const next = new Set(selectedIds);
    if (next.has(id)) next.delete(id);
    else next.add(id);
    setSelectedIds(next);
  };

  const toggleSelectAll = () => {
    if (selectedIds.size === detectedSubs.length) {
      setSelectedIds(new Set());
    } else {
      setSelectedIds(new Set(detectedSubs.map((s) => s.id)));
    }
  };

  const handleImportSelected = () => {
    const toImport = detectedSubs.filter((s) => selectedIds.has(s.id));

    toImport.forEach((s) => {
      const newSub: Omit<Subscription, 'id' | 'createdAt'> = {
        name: s.name,
        amount: s.amount,
        currency: s.currency,
        currencySymbol: s.currencySymbol,
        cycle: s.cycle === 'yearly' ? 'Yearly' : s.cycle === 'weekly' ? 'Weekly' : 'Monthly',
        category: (s.category as any) || 'General',
        startDate: s.lastChargeDate || new Date().toISOString().slice(0, 10),
        logoUrl: s.matchedCatalogItem?.logoUrl,
        status: 'active',
        notes: `Synchronisé via TrueLayer Live (${bankName})`
      };
      addSubscription(newSub);
    });

    setImportedCount(toImport.length);
    setStatus('success');
  };

  const totalMonthlyDetected = detectedSubs
    .filter((s) => selectedIds.has(s.id))
    .reduce((sum, s) => sum + s.amount, 0);

  return (
    <div className="min-h-[80vh] flex items-center justify-center p-4">
      <div className="w-full max-w-lg rounded-japandi-2xl bg-japandi-surface border border-japandi-border shadow-japandi-xl overflow-hidden flex flex-col animate-in fade-in duration-300">
        
        {/* Header */}
        <div className="flex items-center justify-between p-5 border-b border-japandi-border bg-japandi-sand/20">
          <div className="flex items-center gap-2.5">
            <div className="w-9 h-9 rounded-japandi-lg bg-japandi-pine/10 text-japandi-pine flex items-center justify-center">
              <Building2 className="w-5 h-5" />
            </div>
            <div>
              <h1 className="text-base font-bold text-japandi-text">
                {locale === 'fr' ? 'Synchronisation TrueLayer Live' : 'TrueLayer Live Bank Sync'}
              </h1>
              <p className="text-[11px] text-japandi-muted flex items-center gap-1">
                <ShieldCheck className="w-3.5 h-3.5 text-japandi-pine" />
                {locale === 'fr' ? 'DSP2 Sécurisé • Analyse 90 jours' : 'PSD2 Encrypted • 90-Day Analysis'}
              </p>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="p-6">
          {/* Loading / Exchanging / Fetching */}
          {(status === 'loading' || status === 'exchanging' || status === 'fetching_data') && (
            <div className="py-12 flex flex-col items-center justify-center text-center gap-4">
              <div className="w-14 h-14 rounded-full bg-japandi-pine/10 text-japandi-pine flex items-center justify-center animate-spin">
                <RefreshCw className="w-7 h-7" />
              </div>
              <div>
                <h2 className="text-sm font-bold text-japandi-text">
                  {status === 'exchanging'
                    ? (locale === 'fr' ? 'Validation de l\'autorisation bancaire...' : 'Validating authorization...')
                    : (locale === 'fr' ? `Analyse des relevés de ${bankName}...` : `Analyzing statements from ${bankName}...`)}
                </h2>
                <p className="text-xs text-japandi-muted mt-1 max-w-xs mx-auto">
                  {locale === 'fr'
                    ? 'Détection automatique des prélèvements et abonnements récurrents sur vos 90 derniers jours.'
                    : 'Discovering recurring debits and subscriptions from the last 90 days.'}
                </p>
              </div>
            </div>
          )}

          {/* Error State */}
          {status === 'error' && (
            <div className="py-8 flex flex-col items-center justify-center text-center gap-4">
              <div className="w-12 h-12 rounded-full bg-japandi-akane/10 text-japandi-akane flex items-center justify-center">
                <AlertCircle className="w-6 h-6" />
              </div>
              <div>
                <h2 className="text-sm font-bold text-japandi-text">
                  {locale === 'fr' ? 'Échec de la synchronisation' : 'Sync Failed'}
                </h2>
                <p className="text-xs text-japandi-muted mt-1 max-w-xs mx-auto">
                  {errorMessage}
                </p>
              </div>
              <button
                type="button"
                onClick={() => router.push('/')}
                className="mt-2 px-5 py-2.5 rounded-japandi-md bg-japandi-pine text-white text-xs font-bold hover:bg-japandi-pine/90 transition-all flex items-center gap-2 shadow-japandi-xs"
              >
                <Home className="w-4 h-4" />
                <span>{locale === 'fr' ? 'Retour au tableau de bord' : 'Return to Dashboard'}</span>
              </button>
            </div>
          )}

          {/* Review Detected Subscriptions */}
          {status === 'review' && (
            <div className="flex flex-col gap-4">
              <div className="flex items-center justify-between p-3.5 rounded-japandi-xl bg-japandi-pine/10 border border-japandi-pine/20">
                <div className="flex items-center gap-2.5">
                  <Sparkles className="w-4 h-4 text-japandi-pine" />
                  <div>
                    <span className="text-xs font-bold text-japandi-pine block">
                      {detectedSubs.length} abonnements détectés ({bankName})
                    </span>
                    <span className="text-[11px] text-japandi-muted">
                      Total sélectionné : {formatCurrency(totalMonthlyDetected, profile.currency || 'EUR', locale)} / mois
                    </span>
                  </div>
                </div>

                <button
                  type="button"
                  onClick={toggleSelectAll}
                  className="text-xs font-bold text-japandi-pine hover:underline"
                >
                  {selectedIds.size === detectedSubs.length ? 'Tout désélectionner' : 'Tout sélectionner'}
                </button>
              </div>

              {detectedSubs.length === 0 ? (
                <div className="py-8 text-center text-xs text-japandi-muted">
                  Aucun prélèvement récurrent détecté sur les 90 derniers jours.
                </div>
              ) : (
                <div className="flex flex-col gap-2 max-h-72 overflow-y-auto pr-1">
                  {detectedSubs.map((sub) => {
                    const isChecked = selectedIds.has(sub.id);
                    return (
                      <div
                        key={sub.id}
                        onClick={() => toggleSelect(sub.id)}
                        className={`p-3 rounded-japandi-xl border flex items-center justify-between gap-3 cursor-pointer transition-all ${
                          isChecked
                            ? 'border-japandi-pine bg-japandi-sand/40'
                            : 'border-japandi-border bg-japandi-elevated opacity-60'
                        }`}
                      >
                        <div className="flex items-center gap-3 min-w-0">
                          <div
                            className={`w-5 h-5 rounded-md flex items-center justify-center border transition-all flex-shrink-0 ${
                              isChecked
                                ? 'bg-japandi-pine border-japandi-pine text-white'
                                : 'border-japandi-border bg-japandi-surface'
                            }`}
                          >
                            {isChecked && <Check className="w-3.5 h-3.5" />}
                          </div>

                          <SubscriptionLogo
                            name={sub.name}
                            logoUrl={sub.matchedCatalogItem?.logoUrl}
                            size={36}
                          />

                          <div className="min-w-0">
                            <span className="text-xs font-bold text-japandi-text truncate block">
                              {sub.name}
                            </span>
                            <span className="text-[10px] text-japandi-muted block truncate">
                              {sub.occurrencesCount} prélèvements • Dernier : {sub.lastChargeDate}
                            </span>
                          </div>
                        </div>

                        <div className="text-right flex-shrink-0">
                          <span className="text-xs font-bold text-japandi-text block">
                            {formatCurrency(sub.amount, sub.currency, locale)}
                          </span>
                          <span className="text-[10px] text-japandi-muted">
                            / {sub.cycle === 'monthly' ? 'mois' : sub.cycle}
                          </span>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}

              <div className="flex items-center justify-between gap-3 pt-2 border-t border-japandi-border">
                <button
                  type="button"
                  onClick={() => router.push('/')}
                  className="px-4 py-2 rounded-japandi-md border border-japandi-border text-japandi-text text-xs font-bold hover:bg-japandi-sand/40 transition-colors"
                >
                  Annuler
                </button>

                <button
                  type="button"
                  disabled={selectedIds.size === 0}
                  onClick={handleImportSelected}
                  className="px-5 py-2.5 rounded-japandi-md bg-japandi-pine text-white text-xs font-bold hover:bg-japandi-pine/90 disabled:opacity-50 transition-all flex items-center gap-1.5 shadow-japandi-xs"
                >
                  <Plus className="w-4 h-4" />
                  <span>Importer ({selectedIds.size})</span>
                </button>
              </div>
            </div>
          )}

          {/* Success State */}
          {status === 'success' && (
            <div className="py-8 flex flex-col items-center justify-center text-center gap-4">
              <div className="w-14 h-14 rounded-full bg-japandi-pine/15 text-japandi-pine flex items-center justify-center animate-in zoom-in-90 duration-200">
                <CheckCircle2 className="w-8 h-8" />
              </div>
              <div>
                <h2 className="text-base font-bold text-japandi-text">
                  {importedCount} abonnements importés avec succès !
                </h2>
                <p className="text-xs text-japandi-muted mt-1 max-w-xs mx-auto">
                  Vos abonnements issus de {bankName} sont désormais synchronisés dans SubFlow.
                </p>
              </div>
              <button
                type="button"
                onClick={() => router.push('/')}
                className="w-full mt-3 py-2.5 rounded-japandi-md bg-japandi-pine text-white text-xs font-bold hover:bg-japandi-pine/90 transition-all shadow-japandi-xs"
              >
                Voir mon tableau de bord
              </button>
            </div>
          )}
        </div>

      </div>
    </div>
  );
}

export default function TrueLayerCallbackPage() {
  return (
    <Suspense
      fallback={
        <div className="min-h-[80vh] flex items-center justify-center">
          <div className="w-10 h-10 rounded-full border-2 border-japandi-pine/20 border-t-japandi-pine animate-spin" />
        </div>
      }
    >
      <TrueLayerCallbackContent />
    </Suspense>
  );
}
