'use client';

import React, { useEffect } from 'react';
import { usePathname } from 'next/navigation';
import { Sun, Moon, Sparkles, Eye, EyeOff, Languages } from 'lucide-react';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useTranslation } from '../hooks/useTranslation';
import { ThemeMode } from '@subflow/core';

export const TopAppBar: React.FC = () => {
  const pathname = usePathname();
  const { isAmountBlurred, toggleAmountBlur, profile, updateProfile } = useSubscriptionStore();
  const { t, locale, setLocale } = useTranslation();

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
          {/* Quick Language Toggle with National Flags (🇫🇷 FR / 🇬🇧 EN) */}
          <button
            type="button"
            onClick={toggleLanguage}
            aria-label={`Switch language from ${locale.toUpperCase()} to ${locale === 'fr' ? 'EN' : 'FR'}`}
            title={`Langue actuelle : ${locale === 'fr' ? 'Français 🇫🇷' : 'English 🇬🇧'} (Cliquer pour changer)`}
            className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-japandi-md border border-japandi-border bg-japandi-surface text-japandi-text text-xs font-bold hover:border-japandi-pine transition-all shadow-xs"
          >
            <span className="text-sm select-none" role="img" aria-label={locale === 'fr' ? 'Drapeau français' : 'British flag'}>
              {locale === 'fr' ? '🇫🇷' : '🇬🇧'}
            </span>
            <span className="uppercase tracking-wider">{locale}</span>
          </button>

          {/* Amount Blur Toggle */}
          <button
            type="button"
            onClick={toggleAmountBlur}
            aria-label={isAmountBlurred ? 'Show amounts' : 'Hide amounts'}
            title={isAmountBlurred ? 'Show amounts' : 'Hide amounts'}
            className="p-2 rounded-japandi-md text-japandi-muted hover:text-japandi-text hover:bg-japandi-sand/40 transition-colors"
          >
            {isAmountBlurred ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
          </button>

          {/* Theme Cycler (Light -> Dark -> Pinkbie) */}
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


        </div>
      </div>
    </header>
  );
};
