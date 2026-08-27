'use client';

import React, { useEffect, useState } from 'react';
import { usePathname } from 'next/navigation';
import { Sun, Moon, Sparkles, Eye, EyeOff, Languages, Cloud } from 'lucide-react';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useTranslation } from '../hooks/useTranslation';
import { ThemeMode } from '@subflow/core';
import { Tooltip } from '@subflow/ui';
import { GoogleAccountModal } from './GoogleAccountModal';


export const TopAppBar: React.FC = () => {
  const pathname = usePathname();
  const { isAmountBlurred, toggleAmountBlur, profile, updateProfile, googleAccount, driveSyncStatus } = useSubscriptionStore();
  const { t, locale, setLocale } = useTranslation();
  const [isGoogleModalOpen, setIsGoogleModalOpen] = useState(false);

  const getTitle = () => {
    switch (pathname) {
      case '/':
        return 'SubFlow';
      case '/schedule':
        return t('nav.schedule');
      case '/subs':
        return t('nav.subscriptions');
      case '/settings':
        return t('nav.settings');
      default:
        return 'SubFlow';
    }
  };

  const currentTheme = profile.themeMode || 'light';

  // Apply theme to HTML root element
  useEffect(() => {
    const root = document.documentElement;
    root.classList.remove('dark', 'barbie', 'vibrant');
    root.removeAttribute('data-theme');

    if (currentTheme === 'dark') {
      root.classList.add('dark');
      root.setAttribute('data-theme', 'dark');
    } else if (currentTheme === 'barbie') {
      root.classList.add('barbie');
      root.setAttribute('data-theme', 'barbie');
    } else {
      root.setAttribute('data-theme', 'light');
    }

    if (typeof window !== 'undefined') {
      (window as any).__store = useSubscriptionStore;
      (window as any).__toggleBlur = toggleAmountBlur;
      (window as any).__cycleTheme = cycleTheme;
      (window as any).__updateProfile = updateProfile;
    }
  }, [currentTheme, toggleAmountBlur, updateProfile]);

  const cycleTheme = () => {
    let nextTheme: ThemeMode = 'light';
    if (currentTheme === 'light') nextTheme = 'dark';
    else if (currentTheme === 'dark') nextTheme = 'barbie';
    else nextTheme = 'light';

    updateProfile({ themeMode: nextTheme });
  };

  const toggleLanguage = () => {
    const nextLocale = locale === 'fr' ? 'en' : 'fr';
    setLocale(nextLocale);
  };

  const getThemeIcon = () => {
    switch (currentTheme) {
      case 'dark':
        return <Moon className="w-4 h-4 text-amber-300" />;
      case 'barbie':
        return <Sparkles className="w-4 h-4 text-pink-500 animate-pulse" />;
      default:
        return <Sun className="w-4 h-4 text-amber-500" />;
    }
  };

  return (
    <header className="sticky top-0 z-30 w-full bg-japandi-canvas/80 backdrop-blur-md border-b border-japandi-border/60">
      <div className="max-w-[1120px] mx-auto px-4 sm:px-6 h-16 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <span className="text-xl font-extrabold tracking-tight text-japandi-text font-sans">
            {getTitle()}
          </span>
          {currentTheme === 'barbie' && (
            <span className="text-[10px] uppercase font-bold tracking-wider px-2 py-0.5 rounded-full bg-pink-100 text-pink-600 border border-pink-200">
              Pinkbie
            </span>
          )}
        </div>

        <div className="flex items-center gap-2">
          {/* Google Account & Cloud Sync Status Button */}
          <Tooltip
            content={
              googleAccount
                ? `Google Drive : ${googleAccount.name} (${locale === 'fr' ? 'Synchronisé' : 'Synced'})`
                : (locale === 'fr' ? 'Connexion Google & Sauvegarde Drive' : 'Sign in with Google & Cloud Sync')
            }
            side="bottom"
          >
            <button
              type="button"
              onClick={() => setIsGoogleModalOpen(true)}
              aria-label="Google Account & Cloud Backup"
              className={`flex items-center gap-1.5 px-2.5 py-1.5 rounded-japandi-md border text-xs font-bold transition-all shadow-xs ${
                googleAccount
                  ? 'bg-japandi-surface border-japandi-border text-japandi-text hover:border-japandi-pine'
                  : 'bg-japandi-surface border-japandi-border text-japandi-text hover:border-japandi-pine hover:bg-japandi-sand/30'
              }`}
            >
              {googleAccount ? (
                googleAccount.picture ? (
                  <img
                    src={googleAccount.picture}
                    alt={googleAccount.name}
                    className="w-5 h-5 rounded-full border border-japandi-border object-cover"
                  />
                ) : (
                  <div className="w-5 h-5 rounded-full bg-japandi-pine text-white text-[10px] font-extrabold flex items-center justify-center">
                    {googleAccount.name.slice(0, 1).toUpperCase()}
                  </div>
                )
              ) : (
                /* Google G Icon */
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
              )}

              {googleAccount ? (
                <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
              ) : (
                <span className="hidden sm:inline text-xs font-semibold">Google</span>
              )}
            </button>
          </Tooltip>

          {/* Quick Language Toggle with National Flags (🇫🇷 FR / 🇬🇧 EN) */}
          <Tooltip content={`Langue : ${locale === 'fr' ? 'Français 🇫🇷' : 'English 🇬🇧'} (Changer)`} side="bottom">
            <button
              type="button"
              onClick={toggleLanguage}
              aria-label={`Switch language from ${locale.toUpperCase()} to ${locale === 'fr' ? 'EN' : 'FR'}`}
              className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-japandi-md border border-japandi-border bg-japandi-surface text-japandi-text text-xs font-bold hover:border-japandi-pine transition-all shadow-xs"
            >
              <span className="text-sm select-none" role="img" aria-label={locale === 'fr' ? 'Drapeau français' : 'British flag'}>
                {locale === 'fr' ? '🇫🇷' : '🇬🇧'}
              </span>
              <span className="uppercase tracking-wider">{locale}</span>
            </button>
          </Tooltip>

          {/* Amount Blur Toggle */}
          <Tooltip content={isAmountBlurred ? (locale === 'fr' ? 'Afficher les montants' : 'Show amounts') : (locale === 'fr' ? 'Masquer les montants' : 'Hide amounts')} side="bottom">
            <button
              type="button"
              onClick={toggleAmountBlur}
              aria-label={isAmountBlurred ? 'Show amounts' : 'Hide amounts'}
              className="p-2 rounded-japandi-md text-japandi-muted hover:text-japandi-text hover:bg-japandi-sand/40 transition-colors"
            >
              {isAmountBlurred ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
            </button>
          </Tooltip>

          {/* Theme Cycler (Light -> Dark -> Pinkbie) */}
          <Tooltip content={locale === 'fr' ? 'Changer de thème' : 'Switch theme'} side="bottom">
            <button
              type="button"
              onClick={cycleTheme}
              aria-label={`Cycle theme, currently ${currentTheme}`}
              className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-japandi-md border border-japandi-border bg-japandi-surface text-japandi-muted hover:text-japandi-text hover:border-japandi-border-strong transition-all shadow-xs"
            >
              {getThemeIcon()}
              <span className="text-xs font-semibold capitalize hidden sm:inline text-japandi-text">
                {currentTheme === 'barbie'
                  ? 'Pinkbie'
                  : currentTheme === 'dark'
                  ? (locale === 'fr' ? 'Sombre' : 'Dark')
                  : (locale === 'fr' ? 'Clair' : 'Light')}
              </span>
            </button>
          </Tooltip>
        </div>
      </div>

      <GoogleAccountModal isOpen={isGoogleModalOpen} onClose={() => setIsGoogleModalOpen(false)} />
    </header>
  );
};


