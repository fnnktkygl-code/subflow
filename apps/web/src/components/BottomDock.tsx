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
        className="w-full max-w-[580px] h-[68px] rounded-japandi-xl bg-japandi-surface/95 backdrop-blur-xl border border-japandi-border shadow-japandi-lg pointer-events-auto flex items-center justify-around px-3"
      >
        {/* Home */}
        <Link
          href="/"
          aria-label={t('nav.home')}
          className={`flex flex-col items-center justify-center w-16 h-12 rounded-japandi-md transition-colors ${
            pathname === '/' ? 'text-japandi-pine font-bold' : 'text-japandi-muted hover:text-japandi-text'
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
            pathname === '/schedule' ? 'text-japandi-pine font-bold' : 'text-japandi-muted hover:text-japandi-text'
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
            className="w-12 h-12 rounded-japandi-full bg-japandi-pine text-white flex items-center justify-center shadow-japandi-md hover:scale-105 active:scale-95 transition-transform"
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
            pathname === '/subs' ? 'text-japandi-pine font-bold' : 'text-japandi-muted hover:text-japandi-text'
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
            pathname === '/settings' ? 'text-japandi-pine font-bold' : 'text-japandi-muted hover:text-japandi-text'
          }`}
        >
          <Settings className="w-5 h-5" />
          <span className="text-[10px] mt-0.5 tracking-tight">{t('nav.settings')}</span>
        </Link>
      </nav>
    </div>
  );
};
