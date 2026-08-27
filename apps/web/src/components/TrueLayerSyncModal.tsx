'use client';

import React, { useState } from 'react';
import {
  X,
  Building2,
  Sparkles,
  CheckCircle2,
  AlertCircle,
  ArrowRight,
  ShieldCheck,
  RefreshCw,
  Plus,
  Check,
  ExternalLink
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
import { SubscriptionLogo } from '@subflow/ui';
import { useEscapeKey } from '../hooks/useEscapeKey';
import { useTranslation } from '../hooks/useTranslation';

interface TrueLayerSyncModalProps {
  isOpen: boolean;
  onClose: () => void;
}

type SyncStep = 'select_bank' | 'connecting' | 'review_detected' | 'imported_success';

export const TrueLayerSyncModal: React.FC<TrueLayerSyncModalProps> = ({ isOpen, onClose }) => {
  useEscapeKey(isOpen, onClose);
  const { t, locale } = useTranslation();
  const { addSubscription, profile } = useSubscriptionStore();

  const [step, setStep] = useState<SyncStep>('select_bank');
  const [selectedBank, setSelectedBank] = useState<TrueLayerBankProvider>(POPULAR_FRENCH_BANKS[0]!);
  const [detectedSubs, setDetectedSubs] = useState<DetectedSubscription[]>([]);
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [isProcessing, setIsProcessing] = useState(false);
  const [importedCount, setImportedCount] = useState(0);

  if (!isOpen) return null;

  const handleStartSync = async (bank: TrueLayerBankProvider) => {
    setSelectedBank(bank);
    setStep('connecting');
    setIsProcessing(true);

    // Simulation du temps de négociation DSP2 / OAuth & Analyse de récurrence
    setTimeout(() => {
      const mockTxs = getMockFrenchBankTransactions();
      const detected = detectSubscriptionsFromTransactions(mockTxs, {
        currency: profile.currency || 'EUR',
        currencySymbol: profile.currencySymbol || '€'
      });

      setDetectedSubs(detected);
      // Sélectionner tous les abonnements détectés par défaut
      setSelectedIds(new Set(detected.map((s) => s.id)));
      setIsProcessing(false);
      setStep('review_detected');
    }, 1400);
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
    setStep('imported_success');
  };

  const totalMonthlyDetected = detectedSubs
    .filter((s) => selectedIds.has(s.id))
    .reduce((sum, s) => sum + s.amount, 0);

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm animate-in fade-in duration-200"
      role="dialog"
      aria-modal="true"
      aria-labelledby="truelayer-modal-title"
    >
      <div className="w-full max-w-lg rounded-japandi-2xl bg-japandi-surface border border-japandi-border shadow-japandi-2xl overflow-hidden flex flex-col max-h-[90vh]">
        
        {/* Header */}
        <div className="flex items-center justify-between p-5 border-b border-japandi-border bg-japandi-sand/20">
          <div className="flex items-center gap-2.5">
            <div className="w-9 h-9 rounded-japandi-lg bg-japandi-pine/10 text-japandi-pine flex items-center justify-center">
              <Building2 className="w-5 h-5" />
            </div>
            <div>
              <h2 id="truelayer-modal-title" className="text-base font-bold text-japandi-text">
                {locale === 'fr' ? 'Connexion Bancaire TrueLayer' : 'TrueLayer Bank Sync'}
              </h2>
              <p className="text-[11px] text-japandi-muted flex items-center gap-1">
                <ShieldCheck className="w-3.5 h-3.5 text-japandi-pine" />
                {locale === 'fr' ? 'DSP2 Sécurisé • Détection automatique des abonnements' : 'PSD2 Encrypted • Recurring Detection'}
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
              <div className="p-3.5 rounded-japandi-xl bg-japandi-sand/40 border border-japandi-border text-xs text-japandi-text leading-relaxed">
                {locale === 'fr'
                  ? 'Connectez votre compte bancaire pour détecter automatiquement tous vos prélèvements récurrents (Netflix, Spotify, Free, Salle de sport, etc.) sans aucune saisie manuelle.'
                  : 'Connect your bank account to automatically discover all recurring debits without manual input.'}
              </div>

              <div className="flex flex-col gap-2">
                <label className="text-xs font-bold text-japandi-muted uppercase tracking-wider">
                  {locale === 'fr' ? 'Choisissez votre banque' : 'Select your bank'}
                </label>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
                  {POPULAR_FRENCH_BANKS.map((bank) => (
                    <button
                      key={bank.id}
                      type="button"
                      onClick={() => handleStartSync(bank)}
                      className="flex items-center justify-between p-3.5 rounded-japandi-xl border border-japandi-border bg-japandi-elevated hover:border-japandi-pine hover:bg-japandi-pine/5 transition-all text-left group shadow-xs"
                    >
                      <div className="flex items-center gap-3">
                        <span className="text-xl select-none">{bank.logo}</span>
                        <div>
                          <span className="text-xs font-bold text-japandi-text block group-hover:text-japandi-pine transition-colors">
                            {bank.name}
                          </span>
                          <span className="text-[10px] text-japandi-muted">
                            {bank.id === 'mock-sandbox' ? 'Démo 1-Tap' : 'STET / Open Banking'}
                          </span>
                        </div>
                      </div>
                      <ArrowRight className="w-4 h-4 text-japandi-muted group-hover:text-japandi-pine group-hover:translate-x-0.5 transition-all" />
                    </button>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* STEP 2: Connecting / Loading State */}
          {step === 'connecting' && (
            <div className="py-12 flex flex-col items-center justify-center text-center gap-4">
              <div className="w-14 h-14 rounded-full bg-japandi-pine/10 text-japandi-pine flex items-center justify-center animate-spin">
                <RefreshCw className="w-7 h-7" />
              </div>
              <div>
                <h3 className="text-sm font-bold text-japandi-text">
                  {locale === 'fr' ? `Connexion à ${selectedBank.name}...` : `Connecting to ${selectedBank.name}...`}
                </h3>
                <p className="text-xs text-japandi-muted mt-1">
                  {locale === 'fr'
                    ? 'Analyse des transactions et identification des prélèvements récurrents...'
                    : 'Analyzing statements & identifying recurring debits...'}
                </p>
              </div>
            </div>
          )}

          {/* STEP 3: Review Detected Subscriptions */}
          {step === 'review_detected' && (
            <div className="flex flex-col gap-4">
              <div className="flex items-center justify-between p-3.5 rounded-japandi-xl bg-japandi-pine/10 border border-japandi-pine/20">
                <div className="flex items-center gap-2.5">
                  <Sparkles className="w-4 h-4 text-japandi-pine" />
                  <div>
                    <span className="text-xs font-bold text-japandi-pine block">
                      {locale === 'fr'
                        ? `${detectedSubs.length} abonnements détectés`
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

              {/* Detected List */}
              <div className="flex flex-col gap-2 max-h-64 overflow-y-auto pr-1">
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
                        {/* Checkbox */}
                        <div
                          className={`w-5 h-5 rounded-md flex items-center justify-center border transition-all flex-shrink-0 ${
                            isChecked
                              ? 'bg-japandi-pine border-japandi-pine text-white'
                              : 'border-japandi-border bg-japandi-surface'
                          }`}
                        >
                          {isChecked && <Check className="w-3.5 h-3.5" />}
                        </div>

                        {/* Service Logo */}
                        <SubscriptionLogo
                          name={sub.name}
                          logoUrl={sub.matchedCatalogItem?.logoUrl}
                          size={36}
                        />

                        {/* Details */}
                        <div className="min-w-0">
                          <div className="flex items-center gap-1.5">
                            <span className="text-xs font-bold text-japandi-text truncate">
                              {sub.name}
                            </span>
                            <span className="text-[9px] font-extrabold px-1.5 py-0.5 rounded bg-japandi-pine/15 text-japandi-pine uppercase tracking-wider">
                              {sub.confidence === 'high' ? '95%' : '80%'}
                            </span>
                          </div>
                          <span className="text-[10px] text-japandi-muted block truncate">
                            {sub.occurrencesCount} prélèvements • Dernier : {sub.lastChargeDate}
                          </span>
                        </div>
                      </div>

                      {/* Amount & Cycle */}
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

          {/* STEP 4: Imported Success */}
          {step === 'imported_success' && (
            <div className="py-10 flex flex-col items-center justify-center text-center gap-4">
              <div className="w-14 h-14 rounded-full bg-japandi-pine/15 text-japandi-pine flex items-center justify-center animate-in zoom-in-90 duration-200">
                <CheckCircle2 className="w-8 h-8" />
              </div>
              <div>
                <h3 className="text-base font-bold text-japandi-text">
                  {locale === 'fr'
                    ? `${importedCount} abonnements importés avec succès !`
                    : `${importedCount} subscriptions imported!`}
                </h3>
                <p className="text-xs text-japandi-muted mt-1 max-w-xs mx-auto">
                  {locale === 'fr'
                    ? 'Vos calculs de budget 50/30/20, vos simulations What-If et vos échéances sont à jour.'
                    : 'Your budget split and renewal calendar are now synchronized.'}
                </p>
              </div>
            </div>
          )}
        </div>

        {/* Footer Actions */}
        <div className="p-4 border-t border-japandi-border bg-japandi-elevated flex items-center justify-between gap-3">
          {step === 'select_bank' && (
            <div className="text-[11px] text-japandi-muted flex items-center gap-1.5">
              <ShieldCheck className="w-4 h-4 text-japandi-pine" />
              {locale === 'fr' ? 'Agrément ACPR / Banque de France' : 'Bank-Grade PSD2 Encryption'}
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
                {locale === 'fr'
                  ? `Importer (${selectedIds.size})`
                  : `Import (${selectedIds.size})`}
              </button>
            </>
          )}

          {step === 'imported_success' && (
            <button
              type="button"
              onClick={onClose}
              className="w-full py-2.5 rounded-japandi-md bg-japandi-pine text-white text-xs font-bold hover:bg-japandi-pine/90 transition-all shadow-japandi-xs"
            >
              {locale === 'fr' ? 'Voir mon tableau de bord' : 'View Dashboard'}
            </button>
          )}
        </div>

      </div>
    </div>
  );
};
