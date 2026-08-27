'use client';

import React, { useState } from 'react';
import {
  X,
  Building2,
  CheckCircle2,
  AlertCircle,
  ExternalLink,
  ShieldCheck,
  Zap,
  Info
} from 'lucide-react';
import {
  POPULAR_FRENCH_BANKS,
  TrueLayerBankProvider
} from '@subflow/core';
import { BankLogo } from './BankLogo';
import { useEscapeKey } from '../hooks/useEscapeKey';
import { useTranslation } from '../hooks/useTranslation';

interface TrueLayerSyncModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function getTrueLayerAuthUrl(bankId: string = 'stet-boursorama') {
  const clientId = 'subflow-6571e7';
  const isLocal = typeof window !== 'undefined' && (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1');
  const redirectUri = isLocal ? 'http://localhost:3000/callback' : 'https://subflowapp.vercel.app/callback';
  return `https://auth.truelayer.com/?response_type=code&client_id=${clientId}&redirect_uri=${encodeURIComponent(redirectUri)}&scope=info%20accounts%20balance%20transactions%20offline_access&country_code=FR&providers=${bankId}&provider_id=${bankId}`;
}

export const TrueLayerSyncModal: React.FC<TrueLayerSyncModalProps> = ({ isOpen, onClose }) => {
  useEscapeKey(isOpen, onClose);
  const { locale } = useTranslation();
  const [connectingBankId, setConnectingBankId] = useState<string | null>(null);

  if (!isOpen) return null;

  const handleConnectBankOAuth = (bank: TrueLayerBankProvider) => {
    setConnectingBankId(bank.id);
    const authUrl = getTrueLayerAuthUrl(bank.id);
    if (typeof window !== 'undefined') {
      window.location.href = authUrl;
    }
  };

  const isLocal = typeof window !== 'undefined' && (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1');
  const currentRedirectUri = isLocal ? 'http://localhost:3000/callback' : 'https://subflowapp.vercel.app/callback';

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
                {locale === 'fr' ? 'Connexion Bancaire Live (DSP2)' : 'Live Open Banking (PSD2)'}
              </h2>
              <p className="text-[11px] text-japandi-muted flex items-center gap-1">
                <ShieldCheck className="w-3.5 h-3.5 text-japandi-pine" />
                {locale === 'fr' ? 'TrueLayer Live • Historique 90 jours' : 'TrueLayer Live • 90-Day Analysis'}
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
          
          {/* Highlight BoursoBank Quick Connect */}
          <div className="p-4 rounded-japandi-xl bg-japandi-pine/10 border border-japandi-pine/30 flex items-center justify-between gap-3">
            <div className="flex items-center gap-3 min-w-0">
              <BankLogo bank={POPULAR_FRENCH_BANKS[0]!} size={42} />
              <div className="min-w-0">
                <span className="text-sm font-bold text-japandi-text block truncate">
                  BoursoBank Live Connect
                </span>
                <span className="text-[11px] text-japandi-pine font-medium block">
                  Redirection directe vers BoursoBank
                </span>
              </div>
            </div>

            <button
              type="button"
              disabled={connectingBankId !== null}
              onClick={() => handleConnectBankOAuth(POPULAR_FRENCH_BANKS[0]!)}
              className="px-4 py-2.5 rounded-japandi-lg bg-japandi-pine text-white text-xs font-bold hover:bg-japandi-pine/90 transition-all flex items-center gap-1.5 shadow-japandi-xs flex-shrink-0 disabled:opacity-50"
            >
              <span>{connectingBankId === 'stet-boursorama' ? 'Redirection...' : 'Se connecter'}</span>
              <ExternalLink className="w-3.5 h-3.5" />
            </button>
          </div>

          {/* List of other authentic banks */}
          <div className="flex flex-col gap-2">
            <div className="flex items-center justify-between">
              <label className="text-xs font-bold text-japandi-muted uppercase tracking-wider">
                {locale === 'fr' ? 'Autres banques françaises' : 'Other French Banks'}
              </label>
              <span className="text-[10px] font-semibold text-japandi-pine bg-japandi-pine/10 px-2 py-0.5 rounded-full">
                DSP2 Live
              </span>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
              {POPULAR_FRENCH_BANKS.slice(1).map((bank) => (
                <button
                  key={bank.id}
                  type="button"
                  disabled={connectingBankId !== null}
                  onClick={() => handleConnectBankOAuth(bank)}
                  className="flex items-center justify-between p-3.5 rounded-japandi-xl border border-japandi-border bg-japandi-elevated hover:border-japandi-pine hover:bg-japandi-pine/5 transition-all text-left group shadow-xs disabled:opacity-50"
                >
                  <div className="flex items-center gap-3 min-w-0">
                    <BankLogo bank={bank} size={36} />
                    <div className="min-w-0">
                      <span className="text-xs font-bold text-japandi-text block group-hover:text-japandi-pine transition-colors truncate">
                        {bank.name}
                      </span>
                      <span className="text-[10px] text-japandi-muted block truncate">
                        {connectingBankId === bank.id ? 'Redirection...' : 'Se connecter (OAuth)'}
                      </span>
                    </div>
                  </div>
                  <ExternalLink className="w-3.5 h-3.5 text-japandi-muted group-hover:text-japandi-pine transition-all flex-shrink-0" />
                </button>
              ))}
            </div>
          </div>

          {/* Redirect URI Info Notice */}
          <div className="p-3 rounded-japandi-xl bg-japandi-sand/30 border border-japandi-border text-[11px] text-japandi-muted flex items-start gap-2">
            <Info className="w-4 h-4 text-japandi-pine flex-shrink-0 mt-0.5" />
            <div className="flex flex-col gap-0.5">
              <span className="font-semibold text-japandi-text">
                URL de redirection TrueLayer :
              </span>
              <code className="text-[10px] px-1.5 py-0.5 rounded bg-japandi-canvas border border-japandi-border text-japandi-pine font-mono break-all select-all">
                {currentRedirectUri}
              </code>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="p-4 border-t border-japandi-border bg-japandi-sand/10 flex items-center justify-end">
          <button
            type="button"
            onClick={onClose}
            className="px-4 py-2 rounded-japandi-lg border border-japandi-border text-japandi-muted hover:text-japandi-text text-xs font-semibold transition-colors"
          >
            {locale === 'fr' ? 'Fermer' : 'Close'}
          </button>
        </div>
      </div>
    </div>
  );
};
