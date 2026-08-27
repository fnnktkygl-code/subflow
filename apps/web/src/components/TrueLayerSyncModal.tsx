'use client';

import React, { useState } from 'react';
import {
  X,
  Building2,
  CheckCircle2,
  AlertCircle,
  ArrowRight,
  ShieldCheck,
  RefreshCw,
  Plus,
  Check,
  Sparkles,
  ExternalLink,
  Zap
} from 'lucide-react';
import {
  POPULAR_FRENCH_BANKS,
  TrueLayerBankProvider,
  DetectedSubscription,
  detectSubscriptionsFromTransactions,
  getMockFrenchBankTransactions,
  formatCurrency,
  Subscription
} from '@subflow/core';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { BankLogo } from './BankLogo';
import { SubscriptionLogo } from '@subflow/ui';
import { useEscapeKey } from '../hooks/useEscapeKey';
import { useTranslation } from '../hooks/useTranslation';

interface TrueLayerSyncModalProps {
  isOpen: boolean;
  onClose: () => void;
}

type SyncStep = 'select_bank' | 'connecting' | 'review_detected' | 'sync_complete';

export const TrueLayerSyncModal: React.FC<TrueLayerSyncModalProps> = ({ isOpen, onClose }) => {
  useEscapeKey(isOpen, onClose);
  const { locale } = useTranslation();
  const { addSubscription, profile } = useSubscriptionStore();

  const [step, setStep] = useState<SyncStep>('select_bank');
  const [selectedBank, setSelectedBank] = useState<TrueLayerBankProvider>(POPULAR_FRENCH_BANKS[0]!);
  const [detectedSubs, setDetectedSubs] = useState<DetectedSubscription[]>([]);
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [importedCount, setImportedCount] = useState(0);

  if (!isOpen) return null;

  const getTrueLayerAuthUrl = (bank: TrueLayerBankProvider) => {
    const clientId = 'subflow-6571e7';
    const isLocal = typeof window !== 'undefined' && (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1');
    const redirectUri = isLocal ? 'http://localhost:3000/callback' : 'https://subflowapp.vercel.app/callback';
    return `https://auth.truelayer.com/?response_type=code&client_id=${clientId}&redirect_uri=${encodeURIComponent(redirectUri)}&scope=info%20accounts%20balance%20transactions%20offline_access&country_code=FR&providers=${bank.id}&provider_id=${bank.id}`;
  };

  const handleConnectBankOAuth = (bank: TrueLayerBankProvider) => {
    setSelectedBank(bank);
    if (bank.id === 'mock-sandbox') {
      handleRunSimulation(bank);
      return;
    }
    const authUrl = getTrueLayerAuthUrl(bank);
    if (typeof window !== 'undefined') {
      window.location.href = authUrl;
    }
  };

  const handleRunSimulation = (bank: TrueLayerBankProvider) => {
    setSelectedBank(bank);
    setStep('connecting');

    setTimeout(() => {
      const mockTxs = getMockFrenchBankTransactions(bank.id);
      const detected = detectSubscriptionsFromTransactions(mockTxs, {
        currency: profile.currency || 'EUR',
        currencySymbol: profile.currencySymbol || '€'
      });

      setDetectedSubs(detected);
      setSelectedIds(new Set(detected.map((s) => s.id)));
      setStep('review_detected');
    }, 1000);
  };

  const toggleSelect = (id: string) => {
    const next = new Set(selectedIds);
    if (next.has(id)) {
      next.delete(id);
    } else {
      next.add(id);
    }
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
        notes: `Importé automatiquement via TrueLayer Open Banking (${selectedBank.name})`
      };
      addSubscription(newSub);
    });

    setImportedCount(toImport.length);
    setStep('sync_complete');
  };

  const totalMonthlyDetected = detectedSubs
    .filter((s) => selectedIds.has(s.id))
    .reduce((sum, s) => sum + s.amount, 0);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-japandi-scrim/60 backdrop-blur-xs transition-opacity animate-in fade-in duration-200"
        onClick={onClose}
      />

      {/* Modal Card */}
      <div className="relative w-full max-w-lg rounded-japandi-2xl bg-japandi-surface border border-japandi-border shadow-japandi-xl overflow-hidden z-10 flex flex-col max-h-[90vh] animate-in zoom-in-95 duration-200">
        
        {/* Header */}
        <div className="flex items-center justify-between p-5 border-b border-japandi-border bg-japandi-sand/20">
          <div className="flex items-center gap-2.5">
            <div className="w-9 h-9 rounded-japandi-lg bg-japandi-pine/10 text-japandi-pine flex items-center justify-center">
              <Building2 className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-base font-bold text-japandi-text">
                {locale === 'fr' ? 'Synchronisation Bancaire TrueLayer' : 'TrueLayer Bank Sync'}
              </h2>
              <p className="text-[11px] text-japandi-muted flex items-center gap-1">
                <ShieldCheck className="w-3.5 h-3.5 text-japandi-pine" />
                {locale === 'fr' ? 'DSP2 Sécurisé • Détection automatique 90 jours' : 'PSD2 Encrypted • 90-Day Analysis'}
              </p>
            </div>
          </div>

          <button
            type="button"
            onClick={onClose}
            aria-label="Fermer la modal"
            className="p-2 rounded-japandi-md text-japandi-muted hover:text-japandi-text hover:bg-japandi-sand/60 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content Body */}
        <div className="p-5 overflow-y-auto flex-1 flex flex-col gap-4">
          
          {/* STEP 1: Select Bank */}
          {step === 'select_bank' && (
            <div className="flex flex-col gap-4">
              {/* Highlight BoursoBank Quick Connect */}
              <div className="p-4 rounded-japandi-xl bg-japandi-pine/10 border border-japandi-pine/30 flex items-center justify-between gap-3">
                <div className="flex items-center gap-3 min-w-0">
                  <BankLogo bank={POPULAR_FRENCH_BANKS[0]!} size={40} />
                  <div className="min-w-0">
                    <span className="text-xs font-bold text-japandi-text block truncate">
                      BoursoBank Direct Connect
                    </span>
                    <span className="text-[10px] text-japandi-pine font-medium block">
                      Connexion officielle TrueLayer Live (DSP2)
                    </span>
                  </div>
                </div>

                <button
                  type="button"
                  onClick={() => handleConnectBankOAuth(POPULAR_FRENCH_BANKS[0]!)}
                  className="px-3.5 py-2 rounded-japandi-lg bg-japandi-pine text-white text-xs font-bold hover:bg-japandi-pine/90 transition-all flex items-center gap-1.5 shadow-japandi-xs flex-shrink-0"
                >
                  <span>Se connecter</span>
                  <ExternalLink className="w-3.5 h-3.5" />
                </button>
              </div>

              <div className="flex flex-col gap-2">
                <div className="flex items-center justify-between">
                  <label className="text-xs font-bold text-japandi-muted uppercase tracking-wider">
                    {locale === 'fr' ? 'Ou choisissez une autre banque' : 'Or select another bank'}
                  </label>
                  <span className="text-[10px] font-semibold text-japandi-pine bg-japandi-pine/10 px-2 py-0.5 rounded-full">
                    DSP2 Live
                  </span>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
                  {POPULAR_FRENCH_BANKS.map((bank) => {
                    const isUserMainBank = bank.id === 'stet-boursorama' || bank.id === 'revolut';

                    return (
                      <button
                        key={bank.id}
                        type="button"
                        onClick={() => handleConnectBankOAuth(bank)}
                        className={`flex items-center justify-between p-3.5 rounded-japandi-xl border transition-all text-left group shadow-xs ${
                          isUserMainBank
                            ? 'bg-japandi-surface border-japandi-pine/40 hover:border-japandi-pine hover:bg-japandi-sand/40 ring-1 ring-japandi-pine/20'
                            : 'border-japandi-border bg-japandi-elevated hover:border-japandi-pine hover:bg-japandi-pine/5'
                        }`}
                      >
                        <div className="flex items-center gap-3 min-w-0">
                          <BankLogo bank={bank} size={36} />
                          <div className="min-w-0">
                            <div className="flex items-center gap-1.5">
                              <span className="text-xs font-bold text-japandi-text block group-hover:text-japandi-pine transition-colors truncate">
                                {bank.name}
                              </span>
                              {isUserMainBank && (
                                <span className="text-[9px] font-black px-1.5 py-0.2 rounded bg-japandi-pine text-white uppercase tracking-tight flex-shrink-0">
                                  Actif
                                </span>
                              )}
                            </div>
                            <span className="text-[10px] text-japandi-muted block truncate">
                              {bank.id === 'mock-sandbox' ? 'Démo 1-Tap' : 'Se connecter (OAuth)'}
                            </span>
                          </div>
                        </div>
                        <ExternalLink className="w-3.5 h-3.5 text-japandi-muted group-hover:text-japandi-pine transition-all flex-shrink-0" />
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Simulation fallback for testing */}
              <div className="pt-2 border-t border-japandi-border/60 flex items-center justify-between">
                <span className="text-[11px] text-japandi-muted">
                  Tester sans identifiants bancaires :
                </span>
                <button
                  type="button"
                  onClick={() => handleRunSimulation(POPULAR_FRENCH_BANKS[0]!)}
                  className="text-xs font-bold text-japandi-pine hover:underline flex items-center gap-1"
                >
                  <Zap className="w-3 h-3" />
                  <span>Simulation BoursoBank</span>
                </button>
              </div>
            </div>
          )}

          {/* STEP 2: Connecting / Loading State */}
          {step === 'connecting' && (
            <div className="py-10 flex flex-col items-center justify-center text-center gap-4">
              <div className="relative w-16 h-16 flex items-center justify-center">
                <div className="absolute inset-0 rounded-full border-2 border-japandi-pine/20 border-t-japandi-pine animate-spin" />
                <BankLogo bank={selectedBank} size={36} />
              </div>
              <div>
                <h3 className="text-sm font-bold text-japandi-text">
                  {locale === 'fr' ? `Connexion sécurisée à ${selectedBank.name}...` : `Secure connection to ${selectedBank.name}...`}
                </h3>
                <p className="text-xs text-japandi-muted mt-1 max-w-xs mx-auto">
                  {locale === 'fr'
                    ? 'Analyse des relevés de compte et identification des abonnements récurrents...'
                    : 'Analyzing statements & identifying recurring debits...'}
                </p>
              </div>
            </div>
          )}

          {/* STEP 3: Review Detected Subscriptions */}
          {step === 'review_detected' && (
            <div className="flex flex-col gap-3">
              {/* Selected Bank Banner */}
              <div className="flex items-center justify-between p-3 rounded-japandi-xl bg-japandi-sand/30 border border-japandi-border">
                <div className="flex items-center gap-2.5 min-w-0">
                  <BankLogo bank={selectedBank} size={32} />
                  <div className="min-w-0">
                    <span className="text-xs font-bold text-japandi-text block truncate">
                      {selectedBank.name}
                    </span>
                    <span className="text-[10px] text-japandi-muted flex items-center gap-1">
                      <ShieldCheck className="w-3 h-3 text-japandi-pine" />
                      {locale === 'fr' ? 'Relevé bancaire sécurisé' : 'Secure statement analysis'}
                    </span>
                  </div>
                </div>

                <button
                  type="button"
                  onClick={() => handleConnectBankOAuth(selectedBank)}
                  className="px-2.5 py-1 rounded-japandi-md bg-japandi-elevated hover:bg-japandi-sand/60 border border-japandi-border text-[10px] font-bold text-japandi-pine flex items-center gap-1 transition-colors"
                >
                  <span>OAuth Live</span>
                  <ExternalLink className="w-3 h-3" />
                </button>
              </div>

              <div className="flex items-center justify-between p-3.5 rounded-japandi-xl bg-japandi-pine/10 border border-japandi-pine/20">
                <div className="flex items-center gap-2.5">
                  <Sparkles className="w-4 h-4 text-japandi-pine" />
                  <div>
                    <span className="text-xs font-bold text-japandi-pine block">
                      {locale === 'fr'
                        ? `${detectedSubs.length} abonnements récurrents détectés`
                        : `${detectedSubs.length} subscriptions detected`}
                    </span>
                    <span className="text-[11px] text-japandi-muted">
                      {locale === 'fr'
                        ? `Total sélectionné : ${formatCurrency(totalMonthlyDetected, profile.currency || 'EUR', locale)} / mois`
                        : `Selected total: ${formatCurrency(totalMonthlyDetected, profile.currency || 'EUR', locale)} / mo`}
                    </span>
                  </div>
                </div>

                <button
                  type="button"
                  onClick={toggleSelectAll}
                  className="text-xs font-bold text-japandi-pine hover:underline"
                >
                  {selectedIds.size === detectedSubs.length
                    ? (locale === 'fr' ? 'Tout désélectionner' : 'Deselect all')
                    : (locale === 'fr' ? 'Tout sélectionner' : 'Select all')}
                </button>
              </div>

              {/* Subscriptions List */}
              <div className="flex flex-col gap-2 max-h-60 overflow-y-auto pr-1">
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
                            {sub.occurrencesCount} prélèvements détectés • Dernier : {sub.lastChargeDate}
                          </span>
                        </div>
                      </div>

                      <div className="text-right flex-shrink-0">
                        <span className="text-xs font-bold text-japandi-text block">
                          {formatCurrency(sub.amount, sub.currency, locale)}
                        </span>
                        <span className="text-[10px] text-japandi-muted">
                          / {sub.cycle === 'monthly' ? (locale === 'fr' ? 'mois' : 'mo') : sub.cycle}
                        </span>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          )}

          {/* STEP 4: Complete State */}
          {step === 'sync_complete' && (
            <div className="py-8 flex flex-col items-center justify-center text-center gap-4">
              <div className="w-14 h-14 rounded-full bg-japandi-pine/15 text-japandi-pine flex items-center justify-center animate-in zoom-in-90 duration-200">
                <CheckCircle2 className="w-8 h-8" />
              </div>
              <div>
                <h3 className="text-base font-bold text-japandi-text">
                  {locale === 'fr'
                    ? `${importedCount} abonnements importés avec succès !`
                    : `${importedCount} subscriptions successfully imported!`}
                </h3>
                <p className="text-xs text-japandi-muted mt-1 max-w-xs mx-auto">
                  {locale === 'fr'
                    ? `Vos abonnements ${selectedBank.name} sont maintenant synchronisés dans votre tableau de bord.`
                    : `Your ${selectedBank.name} subscriptions are now synced in your dashboard.`}
                </p>
              </div>
            </div>
          )}

        </div>

        {/* Footer Actions */}
        <div className="p-4 border-t border-japandi-border bg-japandi-sand/10 flex items-center justify-between gap-3">
          {step === 'select_bank' && (
            <>
              <button
                type="button"
                onClick={onClose}
                className="px-4 py-2 rounded-japandi-md border border-japandi-border text-japandi-text text-xs font-bold hover:bg-japandi-sand/40 transition-colors"
              >
                {locale === 'fr' ? 'Annuler' : 'Cancel'}
              </button>
              <div className="text-[11px] text-japandi-muted flex items-center gap-1.5">
                <ShieldCheck className="w-4 h-4 text-japandi-pine" />
                <span>Connexion sécurisée TLS 256-bit</span>
              </div>
            </>
          )}

          {step === 'connecting' && (
            <div className="w-full text-center text-xs text-japandi-muted py-1 flex items-center justify-center gap-2">
              <RefreshCw className="w-3.5 h-3.5 animate-spin text-japandi-pine" />
              <span>{locale === 'fr' ? 'Synchronisation en cours...' : 'Syncing in progress...'}</span>
            </div>
          )}

          {step === 'review_detected' && (
            <>
              <button
                type="button"
                onClick={() => setStep('select_bank')}
                className="px-4 py-2 rounded-japandi-md border border-japandi-border text-japandi-text text-xs font-bold hover:bg-japandi-sand/40 transition-colors"
              >
                {locale === 'fr' ? 'Retour' : 'Back'}
              </button>
              <button
                type="button"
                disabled={selectedIds.size === 0}
                onClick={handleImportSelected}
                className="px-5 py-2.5 rounded-japandi-md bg-japandi-pine text-white text-xs font-bold hover:bg-japandi-pine/90 disabled:opacity-50 transition-all flex items-center gap-1.5 shadow-japandi-xs"
              >
                <Plus className="w-4 h-4" />
                <span>
                  {locale === 'fr'
                    ? `Importer (${selectedIds.size})`
                    : `Import (${selectedIds.size})`}
                </span>
              </button>
            </>
          )}

          {step === 'sync_complete' && (
            <button
              type="button"
              onClick={onClose}
              className="w-full py-2.5 rounded-japandi-md bg-japandi-pine text-white text-xs font-bold hover:bg-japandi-pine/90 transition-all shadow-japandi-xs"
            >
              {locale === 'fr' ? 'Voir mon tableau de bord' : 'View my dashboard'}
            </button>
          )}
        </div>

      </div>
    </div>
  );
};
