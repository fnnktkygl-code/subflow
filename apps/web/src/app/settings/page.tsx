'use client';

import React, { useState, useId } from 'react';
import { useSubscriptionStore } from '../../store/useSubscriptionStore';
import { useTranslation } from '../../hooks/useTranslation';
import { ThemeMode, Locale } from '@subflow/core';

import { StarterPackModal } from '../../components/StarterPackModal';
import { BackupManagerModal } from '../../components/BackupManagerModal';
import { TrueLayerSyncModal } from '../../components/TrueLayerSyncModal';
import { NotificationSettingsCard } from '../../components/NotificationSettingsCard';
import {
  Globe,
  Languages,
  Palette,
  Bell,
  Sparkles,
  Download,
  Upload,
  Trash2,
  Check,
  CheckCircle2,
  ChevronRight,
  Shield,
  FileSpreadsheet,
  Sun,
  Moon,
  Rocket,
  Landmark,
  Building2,
  AlertCircle,
  User
} from 'lucide-react';

const CURRENCIES = [
  { code: 'EUR', symbol: '€', flag: '🇪🇺', name: 'Euro' },
  { code: 'USD', symbol: '$', flag: '🇺🇸', name: 'Dollar US' },
  { code: 'GBP', symbol: '£', flag: '🇬🇧', name: 'Livre' },
  { code: 'CAD', symbol: 'CA$', flag: '🇨🇦', name: 'Dollar CA' },
  { code: 'CHF', symbol: 'CHF', flag: '🇨🇭', name: 'Franc Suisse' },
  { code: 'JPY', symbol: '¥', flag: '🇯🇵', name: 'Yen' },
  { code: 'AUD', symbol: 'AU$', flag: '🇦🇺', name: 'Dollar AU' }
];


export default function SettingsPage() {
  const { profile, updateProfile, subscriptions } = useSubscriptionStore();
  const { t, locale, setLocale } = useTranslation();

  const [userName, setUserName] = useState(profile.name || 'Richard');
  const [isNameSaved, setIsNameSaved] = useState(false);
  const [spendingGoal, setSpendingGoal] = useState((profile.spendingGoal ?? 80).toString());
  const [monthlyIncome, setMonthlyIncome] = useState((profile.monthlyIncome ?? 2500).toString());
  const [isSaved, setIsSaved] = useState(false);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);

  // Modals
  const [isBackupModalOpen, setIsBackupModalOpen] = useState(false);
  const [isStarterPackOpen, setIsStarterPackOpen] = useState(false);
  const [isTrueLayerModalOpen, setIsTrueLayerModalOpen] = useState(false);

  const handleSaveName = (e: React.FormEvent) => {
    e.preventDefault();
    updateProfile({ name: userName.trim() });
    setIsNameSaved(true);
    setTimeout(() => setIsNameSaved(false), 2000);
  };

  const handleSaveFinancials = (e: React.FormEvent) => {
    e.preventDefault();
    updateProfile({
      spendingGoal: parseFloat(spendingGoal) || 0,
      monthlyIncome: parseFloat(monthlyIncome) || 0,
      isIncomeConfigured: true
    });
    setIsSaved(true);
    setTimeout(() => setIsSaved(false), 2000);
  };

  const handleThemeChange = (mode: ThemeMode) => {
    updateProfile({ themeMode: mode });
  };

  const handleCurrencyChange = (curr: string) => {
    let symbol = '€';
    if (curr === 'USD' || curr === 'CAD') symbol = '$';
    if (curr === 'GBP') symbol = '£';
    if (curr === 'CHF') symbol = 'CHF ';
    if (curr === 'JPY') symbol = '¥';

    updateProfile({ currency: curr, currencySymbol: symbol });
  };

  const handleConfirmDeleteAll = () => {
    localStorage.clear();
    window.location.reload();
  };

  return (
    <div className="flex flex-col gap-6 animate-in fade-in duration-300 max-w-3xl mx-auto pb-24">
      {/* 1. Header */}
      <div>
        <h1 className="text-xl font-bold tracking-tight text-japandi-text">
          {t('settings.title')}
        </h1>
        <p className="text-xs text-japandi-muted">
          {t('settings.subtitle')}
        </p>
      </div>

      {/* 2. User Profile & Identity (Name Customization) */}
      <div className="rounded-japandi-2xl p-5 shadow-japandi-sm flex flex-col gap-4 bg-japandi-surface border border-japandi-border">
        <div className="flex items-center gap-2">
          <User className="w-4 h-4 text-japandi-pine" />
          <h2 className="text-sm font-bold text-japandi-text">
            {t('settings.profileSection')}
          </h2>
        </div>

        <form onSubmit={handleSaveName} className="flex flex-col sm:flex-row sm:items-end justify-between gap-3">
          <div className="flex-1">
            <label className="block text-xs font-semibold mb-1 text-japandi-text">
              {t('settings.userNameLabel')}
            </label>
            <p className="text-[11px] mb-2 text-japandi-muted">
              {t('settings.userNameSubtitle')}
            </p>
            <div className="relative">
              <input
                type="text"
                value={userName}
                onChange={(e) => setUserName(e.target.value)}
                onBlur={() => updateProfile({ name: userName.trim() })}
                placeholder={t('settings.userNamePlaceholder')}
                maxLength={30}
                className="w-full px-3.5 py-2.5 rounded-japandi-md text-sm focus:outline-none transition-all bg-japandi-elevated border border-japandi-border text-japandi-text focus:ring-1 focus:ring-japandi-pine"
              />
            </div>
          </div>

          <button
            type="submit"
            className="px-4 py-2.5 rounded-japandi-md text-xs font-bold flex items-center justify-center gap-1.5 transition-all shadow-japandi-xs flex-shrink-0 bg-japandi-pine hover:bg-japandi-pine/90 text-white"
          >
            {isNameSaved ? <Check className="w-4 h-4" /> : null}
            <span>{isNameSaved ? (t('settings.saveNameSuccess') || 'Enregistré !') : t('common.save')}</span>
          </button>
        </form>
      </div>

      {/* 3. Language & Regional Settings */}
      <div className="rounded-japandi-2xl p-5 shadow-japandi-sm flex flex-col gap-4 bg-japandi-surface border border-japandi-border">
        <div className="flex items-center gap-2">
          <Languages className="w-4 h-4 text-japandi-pine" />
          <h2 className="text-sm font-bold text-japandi-text">{t('settings.regional')}</h2>
        </div>

        {/* Language Switcher */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          <div>
            <label className="text-xs font-semibold text-japandi-text">
              {t('settings.languageLabel')}
            </label>
            <p className="text-[11px] text-japandi-muted">
              Français ou English
            </p>
          </div>

          <div className="flex rounded-japandi-xl bg-japandi-elevated border border-japandi-border p-1">
            <button
              type="button"
              onClick={() => setLocale('fr')}
              className={`px-4 py-2 rounded-japandi-md text-xs font-bold transition-all ${
                locale === 'fr'
                  ? 'bg-japandi-pine text-white shadow-japandi-xs'
                  : 'text-japandi-muted hover:text-japandi-text'
              }`}
            >
              🇫🇷 Français
            </button>
            <button
              type="button"
              onClick={() => setLocale('en')}
              className={`px-4 py-2 rounded-japandi-md text-xs font-bold transition-all ${
                locale === 'en'
                  ? 'bg-japandi-pine text-white shadow-japandi-xs'
                  : 'text-japandi-muted hover:text-japandi-text'
              }`}
            >
              🇬🇧 English
            </button>
          </div>
        </div>

        {/* Primary Currency Switcher Grid */}
        <div className="flex flex-col gap-2 pt-3 border-t border-japandi-border">
          <div>
            <label className="text-xs font-semibold text-japandi-text">
              {t('settings.currencyLabel')}
            </label>
            <p className="text-[11px] text-japandi-muted">
              {locale === 'fr' ? 'Choisissez votre devise principale d\'affichage' : 'Choose your primary display currency'}
            </p>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-4 md:grid-cols-7 gap-2 pt-1">
            {CURRENCIES.map((curr) => {
              const isSelected = (profile.currency || 'EUR') === curr.code;
              return (
                <button
                  key={curr.code}
                  type="button"
                  onClick={() => handleCurrencyChange(curr.code)}
                  className={`p-2.5 rounded-japandi-xl border flex flex-col items-center justify-center gap-1 transition-all text-center ${
                    isSelected
                      ? 'border-japandi-pine bg-japandi-sand/60 text-japandi-pine ring-1 ring-japandi-pine shadow-japandi-xs scale-[1.02]'
                      : 'border-japandi-border bg-japandi-elevated text-japandi-text hover:border-japandi-border-strong hover:bg-japandi-sand/20'
                  }`}
                >
                  <span className="text-xl">{curr.flag}</span>
                  <div className="flex items-center gap-1">
                    <span className="text-xs font-extrabold">{curr.code}</span>
                    <span className={`text-[10px] font-bold px-1 rounded ${
                      isSelected
                        ? 'bg-japandi-pine/15 text-japandi-pine'
                        : 'bg-japandi-border/60 text-japandi-muted'
                    }`}>
                      {curr.symbol}
                    </span>
                  </div>
                  <span className={`text-[9px] truncate max-w-full ${
                    isSelected
                      ? 'text-japandi-pine font-semibold'
                      : 'text-japandi-muted'
                  }`}>
                    {curr.name}
                  </span>
                </button>
              );
            })}
          </div>
        </div>
      </div>

      {/* 4. Theme Selector */}
      <div className="rounded-japandi-2xl bg-japandi-surface border border-japandi-border p-5 shadow-japandi-sm flex flex-col gap-4">
        <div className="flex items-center gap-2">
          <Palette className="w-4 h-4 text-japandi-pine" />
          <h2 className="text-sm font-bold text-japandi-text">{t('settings.appearance')}</h2>
        </div>

        <div className="grid grid-cols-3 gap-2.5">
          {/* Light */}
          <button
            type="button"
            onClick={() => handleThemeChange('light')}
            className={`p-3 rounded-japandi-xl border flex flex-col items-center gap-2 transition-all ${
              profile.themeMode === 'light' || !profile.themeMode
                ? 'border-japandi-pine bg-japandi-sand/40 ring-1 ring-japandi-pine'
                : 'border-japandi-border bg-japandi-elevated hover:border-japandi-border-strong'
            }`}
          >
            <Sun className="w-5 h-5 text-amber-500" />
            <span className="text-xs font-bold text-japandi-text">{t('settings.themeLight')}</span>
          </button>

          {/* Dark */}
          <button
            type="button"
            onClick={() => handleThemeChange('dark')}
            className={`p-3 rounded-japandi-xl border flex flex-col items-center gap-2 transition-all ${
              profile.themeMode === 'dark'
                ? 'border-japandi-pine bg-japandi-sand/40 ring-1 ring-japandi-pine'
                : 'border-japandi-border bg-japandi-elevated hover:border-japandi-border-strong'
            }`}
          >
            <Moon className="w-5 h-5 text-indigo-400" />
            <span className="text-xs font-bold text-japandi-text">{t('settings.themeDark')}</span>
          </button>

          {/* Barbie / Pinkbie */}
          <button
            type="button"
            onClick={() => handleThemeChange('barbie')}
            className={`p-3 rounded-japandi-xl border flex flex-col items-center gap-2 transition-all ${
              profile.themeMode === 'barbie'
                ? 'border-pink-500 bg-pink-500/10 ring-1 ring-pink-500'
                : 'border-japandi-border bg-japandi-elevated hover:border-japandi-border-strong'
            }`}
          >
            <Sparkles className="w-5 h-5 text-pink-500" />
            <span className="text-xs font-bold text-japandi-text">{t('settings.themeBarbie')}</span>
          </button>
        </div>
      </div>

      {/* 4. Strategic Tools: Starter Pack & Backups */}

      <div className="rounded-japandi-2xl bg-japandi-surface border border-japandi-border p-5 shadow-japandi-sm flex flex-col gap-4">
        <div className="flex items-center gap-2">
          <Rocket className="w-4 h-4 text-japandi-pine" />
          <h2 className="text-sm font-bold text-japandi-text">{t('settings.toolsSection')}</h2>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
          {/* Starter Pack Trigger */}
          <button
            type="button"
            onClick={() => setIsStarterPackOpen(true)}
            className="p-3.5 rounded-japandi-xl bg-japandi-elevated border border-japandi-border hover:border-japandi-pine flex items-center justify-between transition-all text-left group shadow-2xs"
          >
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-japandi-full bg-japandi-pine/10 flex items-center justify-center text-japandi-pine group-hover:scale-105 transition-transform">
                <Rocket className="w-4 h-4" />
              </div>
              <div>
                <h3 className="font-bold text-xs text-japandi-text">{t('settings.openStarterPack')}</h3>
                <span className="text-[10px] text-japandi-muted">Catalogue 350+ services</span>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-japandi-muted group-hover:text-japandi-pine transition-colors" />
          </button>

          {/* TrueLayer Open Banking Sync */}
          <button
            type="button"
            onClick={() => setIsTrueLayerModalOpen(true)}
            className="p-3.5 rounded-japandi-xl bg-japandi-elevated border border-japandi-border hover:border-japandi-pine flex items-center justify-between transition-all text-left group shadow-2xs"
          >
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-japandi-full bg-japandi-pine/10 flex items-center justify-center text-japandi-pine group-hover:scale-105 transition-transform">
                <Building2 className="w-4 h-4" />
              </div>
              <div>
                <h3 className="font-bold text-xs text-japandi-text">
                  {locale === 'fr' ? 'Synchro Bancaire' : 'TrueLayer Bank Sync'}
                </h3>
                <span className="text-[10px] text-japandi-muted">DSP2 & Détection auto</span>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-japandi-muted group-hover:text-japandi-pine transition-colors" />
          </button>

          {/* Backup Manager Trigger */}
          <button
            type="button"
            onClick={() => setIsBackupModalOpen(true)}
            className="p-3.5 rounded-japandi-xl bg-japandi-elevated border border-japandi-border hover:border-japandi-pine flex items-center justify-between transition-all text-left group shadow-2xs"
          >
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-japandi-full bg-japandi-pine/10 flex items-center justify-center text-japandi-pine group-hover:scale-105 transition-transform">
                <FileSpreadsheet className="w-4 h-4" />
              </div>
              <div>
                <h3 className="font-bold text-xs text-japandi-text">{t('settings.openBackup')}</h3>
                <span className="text-[10px] text-japandi-muted">Drive, CSV & AES</span>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-japandi-muted group-hover:text-japandi-pine transition-colors" />
          </button>
        </div>
      </div>

      {/* 5. Local 48h Notifications Card */}
      <NotificationSettingsCard />

      {/* 6. Budget & Financial Goals Form */}
      <div className="rounded-japandi-2xl bg-japandi-surface border border-japandi-border p-5 shadow-japandi-sm flex flex-col gap-4">
        <div className="flex items-center gap-2">
          <Landmark className="w-4 h-4 text-japandi-pine" />
          <h2 className="text-sm font-bold text-japandi-text">{t('settings.incomeGoalSection')}</h2>
        </div>

        <form onSubmit={handleSaveFinancials} className="flex flex-col gap-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-semibold text-japandi-muted uppercase tracking-wider mb-1.5">
                {t('settings.monthlyIncome')}
              </label>
              <div className="relative">
                <span className="absolute left-3.5 top-2.5 text-japandi-muted text-sm font-medium">
                  {profile.currencySymbol || '€'}
                </span>
                <input
                  type="text"
                  inputMode="decimal"
                  value={monthlyIncome}
                  onChange={(e) => setMonthlyIncome(e.target.value)}
                  className="w-full pl-8 pr-3.5 py-2.5 rounded-japandi-md bg-japandi-elevated border border-japandi-border text-japandi-text text-sm focus:outline-none focus:ring-1 focus:ring-japandi-pine"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-japandi-muted uppercase tracking-wider mb-1.5">
                {t('settings.monthlyTargetLimit')}
              </label>
              <div className="relative">
                <span className="absolute left-3.5 top-2.5 text-japandi-muted text-sm font-medium">
                  {profile.currencySymbol || '€'}
                </span>
                <input
                  type="text"
                  inputMode="decimal"
                  value={spendingGoal}
                  onChange={(e) => setSpendingGoal(e.target.value)}
                  className="w-full pl-8 pr-3.5 py-2.5 rounded-japandi-md bg-japandi-elevated border border-japandi-border text-japandi-text text-sm focus:outline-none focus:ring-1 focus:ring-japandi-pine"
                />
              </div>
            </div>
          </div>

          <button
            type="submit"
            className="self-end px-5 py-2.5 rounded-japandi-md bg-japandi-pine hover:bg-japandi-pine/90 text-white font-bold text-xs flex items-center gap-2 transition-all shadow-japandi-xs"
          >
            {isSaved ? <CheckCircle2 className="w-4 h-4" /> : null}
            <span>{isSaved ? t('common.saved', {} as any) || 'Enregistré !' : t('common.save')}</span>
          </button>
        </form>
      </div>

      {/* 7. Danger Zone */}
      <div className="rounded-japandi-2xl bg-japandi-surface border border-japandi-terracotta/30 p-5 shadow-japandi-sm flex flex-col gap-3">
        <div className="flex items-center gap-2">
          <Trash2 className="w-4 h-4 text-japandi-terracotta" />
          <h2 className="text-sm font-bold text-japandi-terracotta">{t('settings.dangerZone')}</h2>
        </div>

        <p className="text-xs text-japandi-muted">
          {t('settings.resetConfirm')}
        </p>

        <button
          type="button"
          onClick={() => setShowDeleteConfirm(true)}
          className="self-start px-4 py-2 rounded-japandi-md bg-japandi-terracotta/10 text-japandi-terracotta hover:bg-japandi-terracotta text-xs font-bold hover:text-white transition-colors"
        >
          {t('settings.resetAllData')}
        </button>
      </div>

      {/* Modals */}
      {isBackupModalOpen && (
        <BackupManagerModal
          isOpen={isBackupModalOpen}
          onClose={() => setIsBackupModalOpen(false)}
        />
      )}

      {isStarterPackOpen && (
        <StarterPackModal
          isOpen={isStarterPackOpen}
          onClose={() => setIsStarterPackOpen(false)}
        />
      )}

      {isTrueLayerModalOpen && (
        <TrueLayerSyncModal
          isOpen={isTrueLayerModalOpen}
          onClose={() => setIsTrueLayerModalOpen(false)}
        />
      )}

      {/* Delete Confirmation Modal */}
      {showDeleteConfirm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in duration-150">
          <div
            role="dialog"
            aria-modal="true"
            className="w-full max-w-sm rounded-japandi-2xl bg-japandi-surface border border-japandi-border p-6 shadow-japandi-xl flex flex-col gap-4"
          >
            <div className="w-10 h-10 rounded-japandi-full bg-japandi-terracotta/10 text-japandi-terracotta flex items-center justify-center">
              <AlertCircle className="w-5 h-5" />
            </div>

            <div>
              <h3 className="font-extrabold text-base text-japandi-text">
                {t('settings.resetAllData')}
              </h3>
              <p className="text-xs text-japandi-muted mt-1">
                {t('settings.resetConfirm')}
              </p>
            </div>

            <div className="flex items-center justify-end gap-2.5 pt-2">
              <button
                type="button"
                onClick={() => setShowDeleteConfirm(false)}
                className="px-4 py-2 rounded-japandi-md border border-japandi-border text-xs font-bold text-japandi-muted hover:text-japandi-text"
              >
                {t('common.cancel')}
              </button>
              <button
                type="button"
                onClick={handleConfirmDeleteAll}
                className="px-4 py-2 rounded-japandi-md bg-japandi-terracotta text-white text-xs font-bold hover:bg-japandi-terracotta/90"
              >
                {t('common.confirm')}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
