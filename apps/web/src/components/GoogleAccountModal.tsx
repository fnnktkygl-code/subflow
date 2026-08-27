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
  Key
} from 'lucide-react';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useTranslation } from '../hooks/useTranslation';
import { useEscapeKey } from '../hooks/useEscapeKey';
import {
  loginWithGoogleAndSync,
  pushToGoogleDrive,
  pullFromGoogleDrive,
  disconnectGoogleAccount,
  DEFAULT_GOOGLE_CLIENT_ID
} from '../services/googleDriveSync';

interface GoogleAccountModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const GoogleAccountModal: React.FC<GoogleAccountModalProps> = ({ isOpen, onClose }) => {
  useEscapeKey(isOpen, onClose);
  const { locale } = useTranslation();
  const {
    googleAccount,
    driveSyncStatus,
    driveSyncError,
    googleClientId,
    setGoogleClientId
  } = useSubscriptionStore();

  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [showConfigClientId, setShowConfigClientId] = useState(false);
  const [customClientIdInput, setCustomClientIdInput] = useState(googleClientId || DEFAULT_GOOGLE_CLIENT_ID);
  const [successNotice, setSuccessNotice] = useState<string | null>(null);

  if (!isOpen) return null;

  const handleLogin = async () => {
    setIsLoading(true);
    setErrorMessage(null);
    setSuccessNotice(null);

    try {
      if (customClientIdInput.trim()) {
        setGoogleClientId(customClientIdInput.trim());
      }
      await loginWithGoogleAndSync(customClientIdInput.trim());
      setSuccessNotice(locale === 'fr' ? 'Connecté avec succès à Google Drive !' : 'Successfully connected to Google Drive!');
      setTimeout(() => setSuccessNotice(null), 3000);
    } catch (err: any) {
      setErrorMessage(err.message || (locale === 'fr' ? 'Impossible de se connecter à Google.' : 'Failed to connect to Google.'));
    } finally {
      setIsLoading(false);
    }
  };

  const handleManualSync = async () => {
    setIsLoading(true);
    setErrorMessage(null);
    try {
      await pushToGoogleDrive();
      setSuccessNotice(locale === 'fr' ? 'Sauvegarde Google Drive mise à jour !' : 'Google Drive backup updated!');
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
    setSuccessNotice(locale === 'fr' ? 'Compte Google déconnecté.' : 'Google account disconnected.');
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
      <div className="relative w-full max-w-md rounded-japandi-2xl bg-japandi-surface border border-japandi-border shadow-japandi-xl overflow-hidden z-10 flex flex-col max-h-[90vh] animate-in zoom-in-95 duration-200">
        
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
                  : (locale === 'fr' ? 'Connexion Google Drive' : 'Connect Google Drive')}
              </h2>
              <p className="text-[11px] text-japandi-muted flex items-center gap-1">
                <ShieldCheck className="w-3.5 h-3.5 text-japandi-pine" />
                {locale === 'fr' ? 'Synchronisation Cloud temps réel' : 'Real-time Cloud Sync'}
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

          {/* Success message banner */}
          {successNotice && (
            <div className="p-3 rounded-japandi-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-600 dark:text-emerald-400 text-xs font-semibold flex items-center gap-2 animate-in fade-in">
              <CheckCircle2 className="w-4 h-4 flex-shrink-0" />
              <span>{successNotice}</span>
            </div>
          )}

          {/* Error message banner */}
          {(errorMessage || driveSyncError) && (
            <div className="p-3 rounded-japandi-xl bg-japandi-terracotta/10 border border-japandi-terracotta/30 text-japandi-terracotta text-xs font-semibold flex items-start gap-2 animate-in fade-in">
              <AlertCircle className="w-4 h-4 flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <span>{errorMessage || driveSyncError}</span>
              </div>
            </div>
          )}

          {googleAccount ? (
            /* Logged-In State */
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
                  <span>{locale === 'fr' ? 'Actif' : 'Synced'}</span>
                </span>
              </div>

              {/* Multi-Device Feature Highlight */}
              <div className="p-3.5 rounded-japandi-xl bg-japandi-sand/30 border border-japandi-border flex flex-col gap-2">
                <span className="text-xs font-bold text-japandi-text flex items-center gap-1.5">
                  <Sparkles className="w-3.5 h-3.5 text-japandi-pine" />
                  <span>{locale === 'fr' ? 'Synchronisation multi-appareils' : 'Multi-Device Sync'}</span>
                </span>
                <p className="text-[11px] text-japandi-muted leading-relaxed">
                  {locale === 'fr'
                    ? 'Vos abonnements sont sauvegardés en temps réel sur votre Google Drive privé. Connectez-vous sur votre téléphone ou un autre ordinateur pour récupérer automatiquement toutes vos données.'
                    : 'Your subscriptions are backed up in real time to your private Google Drive. Log in on your phone or laptop to sync instantly.'}
                </p>
                <div className="flex items-center justify-center gap-3 text-xs font-semibold text-japandi-muted pt-1">
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

              {/* Action Buttons */}
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
                  <span>{locale === 'fr' ? 'Se déconnecter de Google' : 'Sign out of Google'}</span>
                </button>
              </div>
            </div>
          ) : (
            /* Logged-Out / Onboarding State */
            <div className="flex flex-col gap-4">
              <div className="text-center py-2 flex flex-col items-center gap-2">
                <div className="w-12 h-12 rounded-2xl bg-japandi-pine/10 text-japandi-pine flex items-center justify-center shadow-xs">
                  <Cloud className="w-6 h-6" />
                </div>
                <h3 className="text-sm font-extrabold text-japandi-text">
                  {locale === 'fr' ? 'Sauvegarde & Continuité multi-écrans' : 'Cloud Backup & Multi-device Sync'}
                </h3>
                <p className="text-xs text-japandi-muted max-w-xs">
                  {locale === 'fr'
                    ? 'Connectez votre compte Google pour synchroniser vos données en temps réel entre votre mobile et votre ordinateur.'
                    : 'Sign in with Google to sync your data in real time between your mobile and computer.'}
                </p>
              </div>

              {/* Benefits list */}
              <div className="p-3.5 rounded-japandi-xl bg-japandi-elevated border border-japandi-border flex flex-col gap-2.5 text-xs">
                <div className="flex items-start gap-2.5">
                  <CheckCircle2 className="w-4 h-4 text-japandi-pine flex-shrink-0 mt-0.5" />
                  <span className="text-japandi-text font-medium">
                    {locale === 'fr' ? 'Sauvegardes automatiques en temps réel' : 'Real-time automated backups'}
                  </span>
                </div>
                <div className="flex items-start gap-2.5">
                  <CheckCircle2 className="w-4 h-4 text-japandi-pine flex-shrink-0 mt-0.5" />
                  <span className="text-japandi-text font-medium">
                    {locale === 'fr' ? 'Restauration instantanée sur nouvel appareil' : 'Instant restore on any new device'}
                  </span>
                </div>
                <div className="flex items-start gap-2.5">
                  <CheckCircle2 className="w-4 h-4 text-japandi-pine flex-shrink-0 mt-0.5" />
                  <span className="text-japandi-text font-medium">
                    {locale === 'fr' ? 'Stockage privé sécurisé dans Google Drive AppData' : 'Private sandboxed storage in Google Drive'}
                  </span>
                </div>
              </div>

              {/* Google Sign-In Button */}
              <button
                type="button"
                disabled={isLoading}
                onClick={handleLogin}
                className="w-full py-3.5 px-4 rounded-japandi-xl bg-japandi-text text-japandi-canvas hover:opacity-90 active:scale-[0.99] transition-all flex items-center justify-center gap-3 font-bold text-xs shadow-japandi-md disabled:opacity-50 mt-1"
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
