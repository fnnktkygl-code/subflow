'use client';

import React, { useState } from 'react';
import { Cloud, CheckCircle2, RefreshCw, Smartphone, Laptop, Sparkles, ChevronRight, ShieldCheck } from 'lucide-react';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useTranslation } from '../hooks/useTranslation';
import { GoogleAccountModal } from './GoogleAccountModal';

interface GoogleDriveSyncCardProps {
  variant?: 'banner' | 'settings_card';
}

export const GoogleDriveSyncCard: React.FC<GoogleDriveSyncCardProps> = ({ variant = 'banner' }) => {
  const { googleAccount, driveSyncStatus } = useSubscriptionStore();
  const { locale } = useTranslation();
  const [isModalOpen, setIsModalOpen] = useState(false);

  if (variant === 'banner') {
    if (googleAccount) return null; // If already connected, no need to show the prompt banner on home

    return (
      <>
        <div
          onClick={() => setIsModalOpen(true)}
          className="rounded-japandi-2xl p-4 sm:p-4.5 bg-gradient-to-r from-japandi-sand/80 to-japandi-canvas border border-japandi-border hover:border-japandi-pine/50 shadow-japandi-xs transition-all cursor-pointer flex items-center justify-between gap-3 group"
        >
          <div className="flex items-center gap-3.5 min-w-0">
            <div className="w-10 h-10 rounded-japandi-xl bg-japandi-surface border border-japandi-border flex items-center justify-center shadow-2xs group-hover:scale-105 transition-transform flex-shrink-0">
              {/* Google G Icon */}
              <svg className="w-5 h-5" viewBox="0 0 24 24">
                <path
                  fill="#4285F4"
                  d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                />
                <path
                  fill="#34A853"
                  d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                />
                <path
                  fill="#FBBC05"
                  d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
                />
                <path
                  fill="#EA4335"
                  d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
                />
              </svg>
            </div>

            <div className="min-w-0">
              <div className="flex items-center gap-2">
                <h4 className="text-xs sm:text-sm font-bold text-japandi-text truncate">
                  {locale === 'fr' ? 'Sauvegarde Google Drive temps réel' : 'Real-Time Google Drive Backup'}
                </h4>
                <span className="text-[10px] font-black px-1.5 py-0.2 rounded bg-japandi-pine text-white uppercase tracking-tight hidden sm:inline-block">
                  Cloud
                </span>
              </div>
              <p className="text-[11px] text-japandi-muted truncate">
                {locale === 'fr'
                  ? 'Synchronisez vos abonnements entre votre mobile et votre ordinateur.'
                  : 'Sync your subscriptions seamlessly across phone and computer.'}
              </p>
            </div>
          </div>

          <button
            type="button"
            onClick={(e) => {
              e.stopPropagation();
              setIsModalOpen(true);
            }}
            className="px-3.5 py-1.5 rounded-japandi-lg bg-japandi-surface border border-japandi-border text-japandi-text group-hover:border-japandi-pine text-xs font-bold transition-all flex items-center gap-1.5 shadow-2xs flex-shrink-0"
          >
            <span>{locale === 'fr' ? 'Activer' : 'Enable'}</span>
            <ChevronRight className="w-3.5 h-3.5 text-japandi-muted group-hover:text-japandi-pine transition-colors" />
          </button>
        </div>

        <GoogleAccountModal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
      </>
    );
  }

  // Settings Card Variant
  return (
    <>
      <div
        onClick={() => setIsModalOpen(true)}
        className="p-4 rounded-japandi-xl bg-japandi-elevated border border-japandi-border hover:border-japandi-pine flex items-center justify-between transition-all cursor-pointer group shadow-2xs"
      >
        <div className="flex items-center gap-3 min-w-0">
          {googleAccount ? (
            googleAccount.picture ? (
              <img
                src={googleAccount.picture}
                alt={googleAccount.name}
                className="w-10 h-10 rounded-full border border-japandi-border object-cover flex-shrink-0"
              />
            ) : (
              <div className="w-10 h-10 rounded-full bg-japandi-pine text-white font-extrabold text-xs flex items-center justify-center flex-shrink-0">
                {googleAccount.name.slice(0, 1).toUpperCase()}
              </div>
            )
          ) : (
            <div className="w-10 h-10 rounded-japandi-lg bg-japandi-surface border border-japandi-border flex items-center justify-center flex-shrink-0">
              <Cloud className="w-5 h-5 text-blue-500" />
            </div>
          )}

          <div className="min-w-0">
            <div className="flex items-center gap-2">
              <h3 className="font-bold text-xs sm:text-sm text-japandi-text truncate">
                {googleAccount ? googleAccount.name : (locale === 'fr' ? 'Compte Google & Drive' : 'Google Account & Drive')}
              </h3>
              {googleAccount && (
                <span className="inline-flex items-center gap-1 text-[10px] font-bold text-emerald-600 dark:text-emerald-400 bg-emerald-500/10 px-1.5 py-0.2 rounded-full">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
                  <span>{locale === 'fr' ? 'Synchronisé' : 'Synced'}</span>
                </span>
              )}
            </div>
            <span className="text-[11px] text-japandi-muted block truncate">
              {googleAccount
                ? googleAccount.email
                : (locale === 'fr' ? 'Sauvegardes automatiques en temps réel' : 'Real-time automatic cloud backups')}
            </span>
          </div>
        </div>

        <div className="flex items-center gap-2 flex-shrink-0">
          <span className="text-xs font-semibold text-japandi-pine hidden sm:inline">
            {googleAccount ? (locale === 'fr' ? 'Gérer' : 'Manage') : (locale === 'fr' ? 'Connecter' : 'Connect')}
          </span>
          <ChevronRight className="w-4 h-4 text-japandi-muted group-hover:text-japandi-pine transition-colors" />
        </div>
      </div>

      <GoogleAccountModal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
    </>
  );
};
