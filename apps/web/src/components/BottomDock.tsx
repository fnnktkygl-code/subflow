'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Home, Calendar, List, Settings, Plus } from 'lucide-react';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useTranslation } from '../hooks/useTranslation';
import { WhatIfBar } from '@subflow/ui';
import { calculateWhatIfSavings } from '@subflow/core';

interface BottomDockProps {
  onOpenAddModal: () => void;
}

export const BottomDock: React.FC<BottomDockProps> = ({ onOpenAddModal }) => {
  const pathname = usePathname();
  const {
    subscriptions,
    isSelectionMode,
    excludedIds,
    selectAllExcludedIds,
    clearExcludedIds,
    toggleSelectionMode,
    profile
  } = useSubscriptionStore();
  const { t } = useTranslation();

  const savings = calculateWhatIfSavings(subscriptions, new Set(excludedIds));

  const isVibrant = profile.themeMode === 'vibrant';

  return (
    <div className="fixed bottom-6 inset-x-0 z-40 flex flex-col items-center pointer-events-none px-4">
      {/* What-If Floating Action Bar */}
      {isSelectionMode && (
        <div className="w-full max-w-[580px] mb-3 pointer-events-auto animate-in slide-in-from-bottom-3 duration-200">
          <WhatIfBar
            savings={savings}
            currencySymbol={profile.currencySymbol}
            onSelectAll={selectAllExcludedIds}
            onClearAll={clearExcludedIds}
            onExit={toggleSelectionMode}
          />
        </div>
      )}

      {/* Centered Modern Floating Dock */}
      <nav
        aria-label="Navigation principale"
        className={`w-full max-w-[580px] h-[68px] rounded-japandi-xl pointer-events-auto flex items-center justify-around px-3 transition-all ${
          isVibrant
            ? 'bg-white/90 backdrop-blur-2xl border-2 border-purple-200/90 shadow-[0_16px_40px_rgba(139,92,246,0.22)] rounded-3xl'
            : 'bg-japandi-surface/95 backdrop-blur-xl border border-japandi-border shadow-japandi-lg'
        }`}
      >
        {/* Home */}
        <Link
          href="/"
          aria-label={t('nav.home')}
          className={`flex flex-col items-center justify-center w-16 h-12 rounded-japandi-md transition-colors ${
            pathname === '/'
              ? isVibrant ? 'text-pink-600 font-black' : 'text-japandi-pine font-bold'
              : isVibrant ? 'text-purple-400 hover:text-purple-900 font-semibold' : 'text-japandi-muted hover:text-japandi-text'
          }`}
        >
          <Home className="w-5 h-5" />
          <span className="text-[10px] mt-0.5 tracking-tight">{t('nav.home')}</span>
        </Link>

        {/* Schedule */}
        <Link
          href="/schedule"
          aria-label={t('nav.schedule')}
          className={`flex flex-col items-center justify-center w-16 h-12 rounded-japandi-md transition-colors ${
            pathname === '/schedule'
              ? isVibrant ? 'text-pink-600 font-black' : 'text-japandi-pine font-bold'
              : isVibrant ? 'text-purple-400 hover:text-purple-900 font-semibold' : 'text-japandi-muted hover:text-japandi-text'
          }`}
        >
          <Calendar className="w-5 h-5" />
          <span className="text-[10px] mt-0.5 tracking-tight">{t('nav.schedule')}</span>
        </Link>

        {/* Center Gamified FAB */}
        <div className="relative -top-2 flex items-center justify-center">
          <button
            type="button"
            onClick={onOpenAddModal}
            className={`w-12 h-12 rounded-full flex items-center justify-center hover:scale-105 active:scale-95 transition-transform ${
              isVibrant
                ? 'btn-3d-coral text-white shadow-lg'
                : 'bg-japandi-pine text-white shadow-japandi-md'
            }`}
            aria-label={t('modal.addTitle')}
          >
            <Plus className="w-6 h-6" />
          </button>
        </div>

        {/* Subs */}
        <Link
          href="/subs"
          aria-label={t('nav.subscriptions')}
          className={`flex flex-col items-center justify-center w-16 h-12 rounded-japandi-md transition-colors ${
            pathname === '/subs'
              ? isVibrant ? 'text-pink-600 font-black' : 'text-japandi-pine font-bold'
              : isVibrant ? 'text-purple-400 hover:text-purple-900 font-semibold' : 'text-japandi-muted hover:text-japandi-text'
          }`}
        >
          <List className="w-5 h-5" />
          <span className="text-[10px] mt-0.5 tracking-tight">{t('nav.subscriptions')}</span>
        </Link>

        {/* Settings */}
        <Link
          href="/settings"
          aria-label={t('nav.settings')}
          className={`flex flex-col items-center justify-center w-16 h-12 rounded-japandi-md transition-colors ${
            pathname === '/settings'
              ? isVibrant ? 'text-pink-600 font-black' : 'text-japandi-pine font-bold'
              : isVibrant ? 'text-purple-400 hover:text-purple-900 font-semibold' : 'text-japandi-muted hover:text-japandi-text'
          }`}
        >
          <Settings className="w-5 h-5" />
          <span className="text-[10px] mt-0.5 tracking-tight">{t('nav.settings')}</span>
        </Link>
      </nav>

    </div>
  );
};

