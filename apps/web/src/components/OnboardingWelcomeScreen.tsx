'use client';

import React, { useState } from 'react';
import {
  Cloud,
  HardDrive,
  CheckCircle2,
  AlertTriangle,
  ShieldCheck,
  Smartphone,
  Laptop,
  ArrowRight,
  Sparkles,
  AlertCircle
} from 'lucide-react';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useTranslation } from '../hooks/useTranslation';
import { loginWithGoogleAndSync } from '../services/googleDriveSync';

export const OnboardingWelcomeScreen: React.FC = () => {
  const { locale } = useTranslation();
  const { completeOnboarding } = useSubscriptionStore();
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const handleGoogleSignIn = async () => {
    setIsLoading(true);
    setErrorMessage(null);
    try {
      await loginWithGoogleAndSync();
      completeOnboarding('cloud');
    } catch (err: any) {
      setErrorMessage(
        err.message ||
        (locale === 'fr'
          ? 'Impossible de se connecter à Google. Vous pouvez réessayer ou continuer en mode local.'
          : 'Failed to connect to Google. You can retry or continue in local mode.')
      );
    } finally {
      setIsLoading(false);
    }
  };

  const handleLocalMode = () => {
    completeOnboarding('local');
  };

  return (
    <div className="min-h-[85vh] flex items-center justify-center p-4 sm:p-6 animate-in fade-in duration-300">
      <div className="w-full max-w-xl flex flex-col gap-6">
        
        {/* Brand Header */}
        <div className="text-center flex flex-col items-center gap-2 pt-2">
          <div className="inline-flex items-center justify-center w-14 h-14 rounded-japandi-2xl bg-japandi-pine text-white shadow-japandi-md mb-1 ring-4 ring-japandi-pine/10">
            <svg className="w-8 h-8" viewBox="0 0 512 512" fill="none">
              <path
                d="M 100 256 C 180 176, 220 176, 256 256 C 292 336, 332 336, 412 256"
                stroke="#F5EFE6"
                strokeWidth="52"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </svg>
          </div>

          <h1 className="text-2xl sm:text-3xl font-extrabold text-japandi-text tracking-tight">
            SubFlow
          </h1>
          <p className="text-sm text-japandi-muted max-w-md mx-auto leading-relaxed">
            {locale === 'fr'
              ? 'Gérez vos abonnements et maîtrisez vos prélèvements récurrents en toute sérénité.'
              : 'Track and master your subscriptions and recurring expenses effortlessly.'}
          </p>
        </div>

        {/* Error Banner */}
        {errorMessage && (
          <div className="p-3.5 rounded-japandi-xl bg-japandi-terracotta/10 border border-japandi-terracotta/30 text-japandi-terracotta text-xs font-semibold flex items-start gap-2.5 animate-in fade-in">
            <AlertCircle className="w-4 h-4 flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <span>{errorMessage}</span>
            </div>
          </div>
        )}

        {/* Choices Container */}
        <div className="flex flex-col gap-4">
          
          {/* OPTION 1: Cloud Google Drive (Recommended) */}
          <div className="p-5 sm:p-6 rounded-japandi-2xl border-2 border-japandi-pine bg-japandi-surface shadow-japandi-md flex flex-col gap-4 relative overflow-hidden transition-all hover:border-japandi-pine/90">
            {/* Subtle glow */}
            <div className="absolute top-0 right-0 w-36 h-36 bg-japandi-pine/5 rounded-full blur-3xl pointer-events-none -mr-10 -mt-10" />

            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-japandi-xl bg-japandi-pine/10 text-japandi-pine flex items-center justify-center font-bold">
                  <Cloud className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-sm sm:text-base font-extrabold text-japandi-text">
                    {locale === 'fr' ? 'Sauvegarde Cloud Google Drive' : 'Google Drive Cloud Sync'}
                  </h3>
                  <span className="text-[11px] text-japandi-muted flex items-center gap-1 font-medium">
                    <Smartphone className="w-3 h-3 text-japandi-pine" />
                    <span>Mobile</span>
                    <span>⟷</span>
                    <Laptop className="w-3 h-3 text-japandi-pine" />
                    <span>Ordinateur</span>
                  </span>
                </div>
              </div>

              <span className="text-[10px] font-black uppercase tracking-wider px-2.5 py-1 rounded-full bg-japandi-pine text-white shadow-xs">
                {locale === 'fr' ? 'Recommandé' : 'Recommended'}
              </span>
            </div>

            <p className="text-xs text-japandi-muted leading-relaxed">
              {locale === 'fr'
                ? 'Sauvegardez vos données en temps réel sur votre Google Drive privé pour les retrouver instantanément sur tous vos appareils.'
                : 'Automatically back up subscriptions in real time to your private Google Drive across all devices.'}
            </p>

            <div className="flex flex-col gap-2 text-xs text-japandi-text bg-japandi-sand/30 p-3.5 rounded-japandi-xl border border-japandi-border">
              <div className="flex items-start gap-2">
                <CheckCircle2 className="w-4 h-4 text-japandi-pine flex-shrink-0 mt-0.5" />
                <span>
                  {locale === 'fr'
                    ? 'Synchronisation temps réel entre votre téléphone et votre ordinateur'
                    : 'Real-time multi-device sync'}
                </span>
              </div>
              <div className="flex items-start gap-2">
                <CheckCircle2 className="w-4 h-4 text-japandi-pine flex-shrink-0 mt-0.5" />
                <span>
                  {locale === 'fr'
                    ? 'Restauration automatique si vous changez ou réinitialisez votre appareil'
                    : 'Instant restore on any new device or reinstall'}
                </span>
              </div>
              <div className="flex items-start gap-2">
                <CheckCircle2 className="w-4 h-4 text-japandi-pine flex-shrink-0 mt-0.5" />
                <span>
                  {locale === 'fr'
                    ? '100% privé : vos données vous appartiennent dans votre Drive sécurisé'
                    : '100% private: stored in your own secure Google Drive'}
                </span>
              </div>
            </div>

            {/* Official Google Sign-In Button */}
            <button
              type="button"
              disabled={isLoading}
              onClick={handleGoogleSignIn}
              className="w-full py-3.5 px-4 rounded-japandi-xl bg-japandi-text text-japandi-canvas hover:opacity-90 active:scale-[0.99] transition-all flex items-center justify-center gap-3 font-bold text-xs shadow-japandi-md disabled:opacity-50 mt-1 cursor-pointer"
            >
              {/* Official Google G Logo */}
              <svg className="w-4 h-4" viewBox="0 0 24 24">
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
              <span>
                {isLoading
                  ? (locale === 'fr' ? 'Connexion à Google en cours...' : 'Connecting...')
                  : (locale === 'fr' ? 'Continuer avec Google' : 'Continue with Google')}
              </span>
            </button>
          </div>

          {/* OPTION 2: Local Mode Only */}
          <div className="p-5 rounded-japandi-2xl border border-japandi-border bg-japandi-surface shadow-japandi-sm flex flex-col gap-3 transition-all hover:border-japandi-muted/40">
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-japandi-xl bg-japandi-elevated border border-japandi-border text-japandi-muted flex items-center justify-center font-bold">
                <HardDrive className="w-4 h-4" />
              </div>
              <div>
                <h3 className="text-xs sm:text-sm font-bold text-japandi-text">
                  {locale === 'fr' ? 'Mode Local Uniquement (Hors-ligne)' : 'Local Only Mode (Offline)'}
                </h3>
                <p className="text-[11px] text-japandi-muted">
                  {locale === 'fr' ? 'Aucune connexion requise' : 'No account required'}
                </p>
              </div>
            </div>

            <div className="p-3 rounded-japandi-xl bg-amber-500/10 border border-amber-500/20 flex items-start gap-2.5 text-xs text-amber-800 dark:text-amber-300">
              <AlertTriangle className="w-4 h-4 flex-shrink-0 mt-0.5 text-amber-600 dark:text-amber-400" />
              <div className="leading-relaxed">
                <span>
                  {locale === 'fr'
                    ? 'Vos abonnements sont stockés uniquement sur cet appareil. Ils ne seront pas synchronisés et seront perdus si vous videz le cache de votre navigateur.'
                    : 'Data is stored exclusively on this device. You will not be able to sync across devices or recover data if you clear browser storage.'}
                </span>
              </div>
            </div>

            <button
              type="button"
              disabled={isLoading}
              onClick={handleLocalMode}
              className="w-full py-2.5 px-4 rounded-japandi-xl border border-japandi-border bg-japandi-elevated hover:bg-japandi-sand/60 hover:border-japandi-pine text-japandi-text text-xs font-semibold transition-all flex items-center justify-center gap-1.5 cursor-pointer"
            >
              <span>{locale === 'fr' ? 'Utiliser en mode local (sans compte)' : 'Continue in Local Mode'}</span>
              <ArrowRight className="w-3.5 h-3.5 text-japandi-muted" />
            </button>
          </div>

        </div>

        {/* Reassurance Footer */}
        <div className="text-center pt-1 pb-4">
          <p className="text-[11px] text-japandi-muted flex items-center justify-center gap-1.5 font-medium">
            <ShieldCheck className="w-3.5 h-3.5 text-japandi-pine" />
            <span>
              {locale === 'fr'
                ? 'Zéro publicité • Vos données vous appartiennent • Modifiable à tout moment dans les Réglages'
                : 'Zero ads • Your data stays yours • Switch anytime in Settings'}
            </span>
          </p>
        </div>

      </div>
    </div>
  );
};
