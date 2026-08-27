'use client';

import React, { useState } from 'react';
import {
  X,
  Cloud,
  CheckCircle2,
  AlertCircle,
  RefreshCw,
  LogOut,
  ShieldCheck,
  Smartphone,
  Laptop,
  ArrowRight,
  Sparkles,
  HardDrive,
  AlertTriangle
} from 'lucide-react';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useTranslation } from '../hooks/useTranslation';
import { useEscapeKey } from '../hooks/useEscapeKey';
import {
  loginWithGoogleAndSync,
  pushToGoogleDrive,
  pullFromGoogleDrive,
  disconnectGoogleAccount
} from '../services/googleDriveSync';

interface GoogleAccountModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const GoogleAccountModal: React.FC<GoogleAccountModalProps> = ({ isOpen, onClose }) => {
  useEscapeKey(isOpen, onClose);
  const { locale } = useTranslation();
  const { googleAccount, driveSyncStatus, driveSyncError } = useSubscriptionStore();

  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [successNotice, setSuccessNotice] = useState<string | null>(null);

  if (!isOpen) return null;

  const handleLogin = async () => {
    setIsLoading(true);
    setErrorMessage(null);
    setSuccessNotice(null);

    try {
      await loginWithGoogleAndSync();
      setSuccessNotice(locale === 'fr' ? 'Connecté avec succès à Google Drive !' : 'Successfully connected to Google Drive!');
      setTimeout(() => {
        setSuccessNotice(null);
        onClose();
      }, 1500);
    } catch (err: any) {
      setErrorMessage(err.message || (locale === 'fr' ? 'Impossible d\'ouvrir la fenêtre de connexion Google.' : 'Unable to open Google login.'));
    } finally {
      setIsLoading(false);
    }
  };

  const handleManualSync = async () => {
    setIsLoading(true);
    setErrorMessage(null);
    try {
      await pushToGoogleDrive();
      setSuccessNotice(locale === 'fr' ? 'Sauvegarde Google Drive synchronisée !' : 'Google Drive backup synced!');
      setTimeout(() => setSuccessNotice(null), 3000);
    } catch (err: any) {
      setErrorMessage(err.message || 'Erreur lors de la synchronisation.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleManualRestore = async () => {
    setIsLoading(true);
    setErrorMessage(null);
    try {
      await pullFromGoogleDrive();
      setSuccessNotice(locale === 'fr' ? 'Données restaurées depuis Google Drive !' : 'Data restored from Google Drive!');
      setTimeout(() => setSuccessNotice(null), 3000);
    } catch (err: any) {
      setErrorMessage(err.message || 'Erreur lors de la restauration.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleLogout = () => {
    disconnectGoogleAccount();
    setSuccessNotice(locale === 'fr' ? 'Déconnecté. Vos données sont désormais conservées en local.' : 'Disconnected. Your data is now kept locally.');
    setTimeout(() => setSuccessNotice(null), 3000);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-japandi-scrim/60 backdrop-blur-xs transition-opacity animate-in fade-in duration-200"
        onClick={onClose}
      />

      {/* Modal Box */}
      <div className="relative w-full max-w-lg rounded-japandi-2xl bg-japandi-surface border border-japandi-border shadow-japandi-xl overflow-hidden z-10 flex flex-col max-h-[92vh] animate-in zoom-in-95 duration-200">
        
        {/* Header */}
        <div className="flex items-center justify-between p-5 border-b border-japandi-border bg-japandi-sand/20">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-japandi-xl bg-blue-500/10 text-blue-500 flex items-center justify-center">
              <Cloud className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-base font-bold text-japandi-text">
                {googleAccount
                  ? (locale === 'fr' ? 'Compte Google & Drive' : 'Google Account & Drive')
                  : (locale === 'fr' ? 'Sauvegarde & Stockage' : 'Cloud Backup & Storage')}
              </h2>
              <p className="text-[11px] text-japandi-muted flex items-center gap-1">
                <ShieldCheck className="w-3.5 h-3.5 text-japandi-pine" />
                {locale === 'fr' ? 'Sécurisé & Privé (zéro publicité)' : 'Private & Sandboxed'}
              </p>
            </div>
          </div>

          <button
            type="button"
            onClick={onClose}
            aria-label="Fermer"
            className="p-2 rounded-japandi-md text-japandi-muted hover:text-japandi-text hover:bg-japandi-sand/60 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content Body */}
        <div className="p-5 overflow-y-auto flex-1 flex flex-col gap-4">

          {/* Success Banner */}
          {successNotice && (
            <div className="p-3 rounded-japandi-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-600 dark:text-emerald-400 text-xs font-semibold flex items-center gap-2 animate-in fade-in">
              <CheckCircle2 className="w-4 h-4 flex-shrink-0" />
              <span>{successNotice}</span>
            </div>
          )}

          {/* Error Banner */}
          {(errorMessage || driveSyncError) && (
            <div className="p-3 rounded-japandi-xl bg-japandi-terracotta/10 border border-japandi-terracotta/30 text-japandi-terracotta text-xs font-semibold flex items-start gap-2 animate-in fade-in">
              <AlertCircle className="w-4 h-4 flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <span>{errorMessage || driveSyncError}</span>
              </div>
            </div>
          )}

          {googleAccount ? (
            /* ================= STATE 1: ALREADY CONNECTED ================= */
            <div className="flex flex-col gap-4">
              {/* Profile Card */}
              <div className="p-4 rounded-japandi-xl bg-japandi-elevated border border-japandi-border flex items-center justify-between gap-3 shadow-xs">
                <div className="flex items-center gap-3 min-w-0">
                  {googleAccount.picture ? (
                    <img
                      src={googleAccount.picture}
                      alt={googleAccount.name}
                      className="w-11 h-11 rounded-full border border-japandi-border object-cover"
                    />
                  ) : (
                    <div className="w-11 h-11 rounded-full bg-japandi-pine text-white font-extrabold text-sm flex items-center justify-center">
                      {googleAccount.name.slice(0, 1).toUpperCase()}
                    </div>
                  )}
                  <div className="min-w-0">
                    <span className="text-sm font-bold text-japandi-text block truncate">
                      {googleAccount.name}
                    </span>
                    <span className="text-xs text-japandi-muted block truncate">
                      {googleAccount.email}
                    </span>
                  </div>
                </div>

                <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-emerald-500/10 border border-emerald-500/20 text-emerald-600 dark:text-emerald-400">
                  <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                  <span>{locale === 'fr' ? 'Synchronisé' : 'Synced'}</span>
                </span>
              </div>

              {/* Multi-Device Continuity Summary */}
              <div className="p-4 rounded-japandi-xl bg-japandi-sand/30 border border-japandi-border flex flex-col gap-2">
                <span className="text-xs font-bold text-japandi-text flex items-center gap-1.5">
                  <Sparkles className="w-3.5 h-3.5 text-japandi-pine" />
                  <span>{locale === 'fr' ? 'Synchronisation automatique en temps réel' : 'Real-Time Auto Sync'}</span>
                </span>
                <p className="text-xs text-japandi-muted leading-relaxed">
                  {locale === 'fr'
                    ? 'Tous vos abonnements et réglages sont sauvegardés sur votre Google Drive privé. Lorsque vous ouvrez SubFlow sur votre téléphone ou un autre ordinateur, vos données se synchronisent automatiquement.'
                    : 'All your subscriptions and settings are backed up to your private Google Drive and stay up-to-date across all your devices.'}
                </p>
                <div className="flex items-center justify-center gap-3 text-xs font-semibold text-japandi-muted pt-2 border-t border-japandi-border/40">
                  <div className="flex items-center gap-1">
                    <Smartphone className="w-3.5 h-3.5 text-japandi-pine" />
                    <span>Mobile</span>
                  </div>
                  <span className="text-japandi-border">⟷</span>
                  <div className="flex items-center gap-1">
                    <Laptop className="w-3.5 h-3.5 text-japandi-pine" />
                    <span>Ordinateur</span>
                  </div>
                </div>
              </div>

              {/* Actions */}
              <div className="flex flex-col gap-2 pt-1">
                <button
                  type="button"
                  disabled={isLoading}
                  onClick={handleManualSync}
                  className="w-full py-2.5 px-4 rounded-japandi-xl bg-japandi-pine text-white text-xs font-bold hover:bg-japandi-pine/90 transition-all flex items-center justify-center gap-2 shadow-japandi-xs disabled:opacity-50"
                >
                  <RefreshCw className={`w-3.5 h-3.5 ${isLoading ? 'animate-spin' : ''}`} />
                  <span>{locale === 'fr' ? 'Sauvegarder maintenant sur Google Drive' : 'Sync to Google Drive Now'}</span>
                </button>

                <button
                  type="button"
                  disabled={isLoading}
                  onClick={handleManualRestore}
                  className="w-full py-2.5 px-4 rounded-japandi-xl bg-japandi-elevated border border-japandi-border text-japandi-text text-xs font-bold hover:border-japandi-pine transition-all flex items-center justify-center gap-2 disabled:opacity-50"
                >
                  <Cloud className="w-3.5 h-3.5 text-japandi-pine" />
                  <span>{locale === 'fr' ? 'Restaurer depuis Google Drive' : 'Restore from Google Drive'}</span>
                </button>

                <button
                  type="button"
                  onClick={handleLogout}
                  className="w-full py-2 px-4 rounded-japandi-xl border border-japandi-border text-japandi-terracotta hover:bg-japandi-terracotta/10 text-xs font-semibold transition-all flex items-center justify-center gap-1.5 mt-2"
                >
                  <LogOut className="w-3.5 h-3.5" />
                  <span>{locale === 'fr' ? 'Se déconnecter (Repasser en mode local)' : 'Sign out (Switch to Local Only)'}</span>
                </button>
              </div>
            </div>
          ) : (
            /* ================= STATE 2: CAPTURE-INSPIRED CHOICE (CLOUD VS LOCAL) ================= */
            <div className="flex flex-col gap-4">
              
              {/* Option 1: Cloud Google Drive (Recommended) */}
              <div className="p-4 rounded-japandi-2xl border-2 border-japandi-pine bg-japandi-sand/30 flex flex-col gap-3 relative shadow-sm">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Cloud className="w-4 h-4 text-japandi-pine" />
                    <span className="font-extrabold text-sm text-japandi-text">
                      {locale === 'fr' ? '1. Sauvegarde Cloud Google Drive' : '1. Google Drive Cloud Sync'}
                    </span>
                  </div>
                  <span className="text-[10px] font-black uppercase tracking-wider px-2 py-0.5 rounded-full bg-japandi-pine text-white">
                    {locale === 'fr' ? 'Recommandé' : 'Recommended'}
                  </span>
                </div>

                <p className="text-xs text-japandi-muted leading-relaxed">
                  {locale === 'fr'
                    ? 'Connectez votre compte Google pour sauvegarder vos abonnements en temps réel sur votre Google Drive privé.'
                    : 'Connect your Google account to back up subscriptions in real time to your private Google Drive.'}
                </p>

                <div className="flex flex-col gap-1.5 text-xs text-japandi-text pt-1">
                  <div className="flex items-start gap-2">
                    <CheckCircle2 className="w-3.5 h-3.5 text-japandi-pine flex-shrink-0 mt-0.5" />
                    <span>{locale === 'fr' ? 'Synchronisation automatique entre téléphone et ordinateur' : 'Real-time sync between phone & computer'}</span>
                  </div>
                  <div className="flex items-start gap-2">
                    <CheckCircle2 className="w-3.5 h-3.5 text-japandi-pine flex-shrink-0 mt-0.5" />
                    <span>{locale === 'fr' ? 'Restauration garantie en cas de réinitialisation ou changement d\'appareil' : 'Instant recovery if you change or reset your phone'}</span>
                  </div>
                  <div className="flex items-start gap-2">
                    <CheckCircle2 className="w-3.5 h-3.5 text-japandi-pine flex-shrink-0 mt-0.5" />
                    <span>{locale === 'fr' ? 'Stockage privé 100% sécurisé (vos données vous appartiennent)' : '100% private sandboxed storage in your own Drive'}</span>
                  </div>
                </div>

                {/* Google Sign-in Action Button */}
                <button
                  type="button"
                  disabled={isLoading}
                  onClick={handleLogin}
                  className="w-full mt-2 py-3 px-4 rounded-japandi-xl bg-japandi-text text-japandi-canvas hover:opacity-90 active:scale-[0.99] transition-all flex items-center justify-center gap-3 font-bold text-xs shadow-japandi-md disabled:opacity-50"
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
                      ? (locale === 'fr' ? 'Connexion en cours...' : 'Connecting...')
                      : (locale === 'fr' ? 'Se connecter avec Google' : 'Sign in with Google')}
                  </span>
                </button>
              </div>

              {/* Option 2: Local Only Warning Card */}
              <div className="p-4 rounded-japandi-xl border border-japandi-border bg-japandi-elevated flex flex-col gap-2.5">
                <div className="flex items-center gap-2">
                  <HardDrive className="w-4 h-4 text-japandi-muted" />
                  <span className="font-bold text-xs text-japandi-text">
                    {locale === 'fr' ? '2. Mode Local Uniquement (Hors-ligne)' : '2. Local Only Mode (Offline)'}
                  </span>
                </div>

                <div className="p-2.5 rounded-japandi-lg bg-amber-500/10 border border-amber-500/20 flex items-start gap-2 text-[11px] text-amber-700 dark:text-amber-400">
                  <AlertTriangle className="w-4 h-4 flex-shrink-0 mt-0.5" />
                  <span>
                    {locale === 'fr'
                      ? 'Attention : en mode local, vos données restent uniquement dans ce navigateur. Elles ne seront pas synchronisées sur votre téléphone et seront perdues si vous videz le cache ou changez d\'appareil.'
                      : 'Notice: in local mode, data is only stored in this browser. You won\'t be able to sync across devices or recover data if you reset your browser cache.'}
                  </span>
                </div>

                <button
                  type="button"
                  onClick={onClose}
                  className="w-full py-2 px-3 rounded-japandi-lg border border-japandi-border bg-japandi-surface text-japandi-muted hover:text-japandi-text hover:border-japandi-pine text-xs font-semibold transition-all mt-1"
                >
                  {locale === 'fr' ? 'Continuer en mode local uniquement' : 'Continue in Local Mode'}
                </button>
              </div>

            </div>
          )}
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
