'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useTranslation } from '../hooks/useTranslation';
import {
  calculateTotalMonthlyCost,
  calculateTotalYearlyCost,
  calculateCategoryBreakdown,
  SubscriptionCategory,
  Subscription
} from '@subflow/core';
import { SpendingDonut, SubscriptionLogo } from '@subflow/ui';
import { CategoryIcon } from '../components/CategoryIcon';
import { GoalDialog } from '../components/GoalDialog';
import { ActionableInsightHeader } from '../components/ActionableInsightHeader';
import { CancellationArenaModal } from '../components/CancellationArenaModal';
import { ScanInvoiceModal } from '../components/ScanInvoiceModal';
import { VibrantMascot } from '../components/VibrantMascot';
import {
  SlidersHorizontal,
  Target,
  Calendar,
  PieChart,
  ArrowRight,
  ChevronRight,
  Check,
  Info,
  Sparkles,
  Scissors,
  Camera,
  Flame,
  Zap,
  TrendingDown
} from 'lucide-react';


export default function HomePage() {
  const {
    subscriptions,
    profile,
    isAmountBlurred,
    toggleAmountBlur,
    isSelectionMode,
    excludedIds,
    toggleSelectionMode
  } = useSubscriptionStore();
  const { t, format, locale } = useTranslation();

  const [selectedCategory, setSelectedCategory] = useState<SubscriptionCategory | null>(null);
  const [isGoalModalOpen, setIsGoalModalOpen] = useState(false);
  const [isCancellationModalOpen, setIsCancellationModalOpen] = useState(false);
  const [isScanInvoiceModalOpen, setIsScanInvoiceModalOpen] = useState(false);
  const longPressTimerRef = React.useRef<NodeJS.Timeout | null>(null);

  const activeExcluded = isSelectionMode ? new Set(excludedIds) : new Set<string>();
  const totalMonthly = calculateTotalMonthlyCost(subscriptions, activeExcluded);
  const totalYearly = calculateTotalYearlyCost(subscriptions, activeExcluded);
  const categoryBreakdown = calculateCategoryBreakdown(subscriptions, activeExcluded);

  const spendingGoal = profile.spendingGoal ?? 0;
  const goalProgress = spendingGoal > 0 ? Math.min(totalMonthly / spendingGoal, 1) : 0;
  const isUnderGoal = totalMonthly <= spendingGoal;
  const goalDiff = Math.abs(spendingGoal - totalMonthly);

  const isVibrant = profile.themeMode === 'vibrant';

  return (
    <div className="flex flex-col gap-6 animate-in fade-in duration-300 max-w-4xl mx-auto">

      {/* 1. Actionable Financial Insight Header */}
      <ActionableInsightHeader />

      {/* 2. Spending Card with Goal & Long Press to Blur */}
      <div
        onContextMenu={(e) => { e.preventDefault(); toggleAmountBlur(); }}
        onTouchStart={() => {
          longPressTimerRef.current = setTimeout(toggleAmountBlur, 500);
        }}
        onTouchEnd={() => {
          if (longPressTimerRef.current) clearTimeout(longPressTimerRef.current);
        }}
        className={`rounded-japandi-2xl p-5 sm:p-6 flex flex-col gap-4 relative overflow-hidden transition-all select-none ${
          isVibrant
            ? 'bg-gradient-to-br from-[#FF2A6D] via-[#8B5CF6] to-[#06B6D4] text-white shadow-[0_15px_35px_rgba(139,92,246,0.3)] border-2 border-white/30'
            : 'bg-japandi-surface border border-japandi-border hover:border-japandi-pine/50 shadow-japandi-sm'
        }`}
        title="Appui long ou clic sur l'œil en haut pour masquer les montants"
      >
        {/* Subtle accent backdrop */}
        {!isVibrant && (
          <div className="absolute top-0 right-0 w-32 h-32 bg-japandi-pine/5 rounded-full blur-2xl -mr-10 -mt-10 pointer-events-none" />
        )}

        {/* Header: Title + yearly subtitle + tune button */}
        <div className="flex items-start justify-between">
          <div className="flex flex-col gap-0.5">
            <div className="flex items-center gap-2">
              <span className="text-lg">💰</span>
              <h3 className={`font-bold text-sm ${isVibrant ? 'text-white/95 uppercase tracking-wider text-[11px] font-black' : 'text-japandi-muted'}`}>
                {t('home.spendingTitle')}
              </h3>
            </div>
            <p className={`text-xs ml-7 ${isVibrant ? 'text-white/90 font-medium' : 'text-japandi-muted'}`}>
              {t('home.annualized', { amount: isAmountBlurred ? '•••• €' : format(totalYearly) })}
            </p>
          </div>
          <button
            type="button"
            onClick={(e) => { e.stopPropagation(); setIsGoalModalOpen(true); }}
            aria-label={t('home.monthlyTarget')}
            className={`flex items-center gap-1 px-3 py-1.5 rounded-japandi-md text-xs font-semibold transition-all shadow-xs ${
              isVibrant
                ? 'bg-black/25 backdrop-blur-md border border-white/30 text-white hover:bg-black/35'
                : 'bg-japandi-elevated border border-japandi-border hover:border-japandi-pine text-japandi-text'
            }`}
          >
            <SlidersHorizontal className={`w-3.5 h-3.5 ${isVibrant ? 'text-amber-300' : 'text-japandi-pine'}`} />
            <span className="hidden sm:inline">{t('settings.configureBudget')}</span>
          </button>
        </div>

        {/* Big Hero Amount */}
        <div
          onClick={toggleAmountBlur}
          className="flex items-baseline gap-2 cursor-pointer"
        >
          <span className={`text-4xl sm:text-5xl font-extrabold tracking-tight ${isVibrant ? 'text-white drop-shadow-sm' : 'text-japandi-text'} ${isAmountBlurred ? 'privacy-blur' : ''}`}>
            {format(totalMonthly)}
          </span>
          <span className={`text-sm font-semibold ${isVibrant ? 'text-white/80' : 'text-japandi-muted'}`}>
            {t('cycles.perMonth')}
          </span>
        </div>

        {/* Spending Goal Progress Bar */}
        {spendingGoal > 0 && (
          <div className="flex flex-col gap-2 pt-2 border-t border-japandi-border/40">
            <div className="flex items-center justify-between text-xs">
              <div className={`flex items-center gap-1.5 ${isVibrant ? 'text-white/90 font-bold' : 'text-japandi-muted'}`}>
                <Target className={`w-3.5 h-3.5 ${isVibrant ? 'text-teal-300' : 'text-japandi-pine'}`} />
                <span>{t('home.targetBudget')} : {format(spendingGoal)}</span>
              </div>
              <span className={`font-bold ${isVibrant ? (isUnderGoal ? 'text-teal-200' : 'text-amber-200') : (isUnderGoal ? 'text-japandi-pine' : 'text-japandi-terracotta')}`}>
                {isUnderGoal
                  ? `${format(goalDiff)} ${t('home.remainingBudget').toLowerCase()}`
                  : `${format(goalDiff)} ${t('home.targetExceeded').toLowerCase()}`}
              </span>
            </div>
            <div
              role="progressbar"
              aria-valuenow={Math.round(goalProgress * 100)}
              aria-valuemin={0}
              aria-valuemax={100}
              className={`w-full h-2.5 rounded-japandi-full overflow-hidden ${isVibrant ? 'bg-black/30 p-0.5' : 'bg-japandi-elevated'}`}
            >
              <div
                className={`h-full rounded-japandi-full transition-all duration-500 ${
                  isVibrant
                    ? 'bg-gradient-to-r from-amber-300 via-teal-300 to-teal-400 shadow-sm'
                    : (isUnderGoal ? 'bg-japandi-pine' : 'bg-japandi-terracotta')
                }`}
                style={{ width: `${Math.min(goalProgress * 100, 100)}%` }}
              />
            </div>
          </div>
        )}

        {/* Unified What-If Simulator Action Trigger */}
        <div className="pt-2">
          <button
            type="button"
            onClick={toggleSelectionMode}
            aria-expanded={isSelectionMode}
            className={`w-full py-2.5 px-4 rounded-japandi-xl border text-xs font-bold flex items-center justify-between transition-all ${
              isVibrant
                ? isSelectionMode
                  ? 'bg-white/30 border-white text-white shadow-sm'
                  : 'bg-black/20 border-white/25 hover:bg-black/30 text-white'
                : isSelectionMode
                ? 'bg-japandi-sand/60 border-japandi-pine text-japandi-pine'
                : 'bg-japandi-elevated border-japandi-border hover:border-japandi-pine text-japandi-text'
            }`}
          >
            <div className="flex items-center gap-2">
              <span className={`w-2 h-2 rounded-full animate-pulse ${isVibrant ? 'bg-amber-300' : 'bg-japandi-pine'}`} />
              <span>{isSelectionMode ? t('whatIf.modeActive') : t('home.whatIfTitle')}</span>
            </div>
            <span className={`text-[11px] ${isVibrant ? 'text-white/80' : 'text-japandi-muted'}`}>
              {isSelectionMode ? t('whatIf.exitMode') : t('home.whatIfButton')} →
            </span>
          </button>
        </div>
      </div>

      {/* 3. Category Breakdown & Donut */}
      {subscriptions.length > 0 && (
        <div className={`rounded-japandi-2xl border p-5 sm:p-6 flex flex-col gap-4 ${
          isVibrant
            ? 'pop-card border-2 border-purple-200/90 shadow-lg shadow-purple-500/10'
            : 'bg-japandi-surface border-japandi-border shadow-japandi-sm'
        }`}>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <PieChart className={`w-4 h-4 ${isVibrant ? 'text-purple-600' : 'text-japandi-pine'}`} />
              <h3 className={`font-bold text-sm ${isVibrant ? 'text-indigo-950 font-black' : 'text-japandi-text'}`}>
                {t('home.categoriesTitle')}
              </h3>
            </div>
            <span className={`text-xs ${isVibrant ? 'text-purple-600 font-bold bg-purple-100 px-2.5 py-0.5 rounded-full' : 'text-japandi-muted'}`}>
              {t('home.activeCount', { count: subscriptions.length })}
            </span>
          </div>


          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 items-center">
            {/* Donut Chart */}
            <div className="flex justify-center">
              <SpendingDonut
                categories={categoryBreakdown}
                totalMonthlyAmount={totalMonthly}
                currencySymbol={profile.currencySymbol || '€'}
                selectedCategory={selectedCategory}
                onSelectCategory={setSelectedCategory}
                isAmountBlurred={isAmountBlurred}
                themeMode={profile.themeMode}
              />
            </div>


            {/* Category List with interactive selection */}
            <div className="flex flex-col gap-2">
              {Object.entries(categoryBreakdown).map(([catKey, cat]) => {
                const isSelected = selectedCategory === catKey;
                const percentage = totalMonthly > 0 ? (cat.total / totalMonthly) * 100 : 0;

                return (
                  <button
                    key={catKey}
                    type="button"
                    aria-expanded={isSelected}
                    onClick={() => setSelectedCategory(isSelected ? null : (catKey as SubscriptionCategory))}
                    className={`flex items-center justify-between p-2.5 rounded-japandi-lg border transition-all text-left ${
                      isVibrant
                        ? isSelected
                          ? 'bg-purple-100 border-purple-400 text-indigo-950 shadow-sm'
                          : 'bg-purple-50/60 border-purple-100/80 hover:border-purple-300 text-indigo-950'
                        : isSelected
                        ? 'bg-japandi-sand/60 border-japandi-pine'
                        : 'bg-japandi-elevated border-japandi-border hover:border-japandi-border-strong'
                    }`}
                  >
                    <div className="flex items-center gap-2.5 min-w-0">
                      <CategoryIcon category={catKey} className="w-3.5 h-3.5" showBackground={true} />
                      <div className="min-w-0">
                        <span className={`font-semibold text-xs truncate block ${isVibrant ? 'text-indigo-950 font-bold' : 'text-japandi-text'}`}>
                          {t(`categories.${catKey}` as any) || catKey}
                        </span>
                        <span className={`text-[10px] ${isVibrant ? 'text-purple-600 font-medium' : 'text-japandi-muted'}`}>
                          {cat.count} service{cat.count > 1 ? 's' : ''} ({percentage.toFixed(0)}%)
                        </span>
                      </div>
                    </div>

                    <span className={`font-bold text-xs ${isVibrant ? 'text-pink-600 font-black' : 'text-japandi-text'} ${isAmountBlurred ? 'privacy-blur' : ''}`}>
                      {format(cat.total)}
                    </span>
                  </button>
                );
              })}
            </div>
          </div>
        </div>
      )}

      {/* 4. Upcoming Renewals Widget */}
      <div className={`rounded-japandi-2xl border p-5 sm:p-6 flex flex-col gap-4 ${
        isVibrant
          ? 'pop-card border-2 border-purple-200/90 shadow-lg shadow-purple-500/10'
          : 'bg-japandi-surface border-japandi-border shadow-japandi-sm'
      }`}>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Calendar className={`w-4 h-4 ${isVibrant ? 'text-purple-600' : 'text-japandi-pine'}`} />
            <h3 className={`font-bold text-sm ${isVibrant ? 'text-indigo-950 font-black' : 'text-japandi-text'}`}>
              {t('home.upcomingTitle')}
            </h3>
          </div>
          <Link
            href="/schedule"
            className={`text-xs font-bold flex items-center gap-1 ${isVibrant ? 'text-pink-600 hover:text-pink-700 font-black' : 'text-japandi-pine hover:underline'}`}
          >
            <span>{t('home.seeAllRenewals')}</span>
            <ChevronRight className="w-3.5 h-3.5" />
          </Link>
        </div>

        {subscriptions.length === 0 ? (
          <div className="py-8 text-center text-xs text-japandi-muted flex flex-col items-center gap-2">
            <span>{t('home.emptyStateSubtitle')}</span>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            {subscriptions.slice(0, 3).map((sub, idx) => (
              <div
                key={sub.id}
                className={`p-3.5 rounded-japandi-xl border flex items-center justify-between shadow-2xs transition-all ${
                  isVibrant
                    ? idx === 0
                      ? 'bg-rose-50/70 border-rose-200'
                      : idx === 1
                      ? 'bg-cyan-50/70 border-cyan-200'
                      : 'bg-purple-50/70 border-purple-200'
                    : 'bg-japandi-elevated border-japandi-border'
                }`}
              >
                <div className="flex items-center gap-3 min-w-0">
                  <SubscriptionLogo name={sub.name} logoUrl={sub.logoUrl} category={sub.category} size={44} />
                  <div className="min-w-0">
                    <div className="flex items-center gap-1.5">
                      <h4 className={`font-bold text-xs truncate ${isVibrant ? 'text-indigo-950 font-black' : 'text-japandi-text'}`}>{sub.name}</h4>
                      {isVibrant && (
                        <span className={`text-[8px] font-black px-1.5 py-0.2 rounded border ${
                          idx === 0 ? 'bg-rose-100 text-rose-700 border-rose-300' : idx === 1 ? 'bg-emerald-100 text-emerald-700 border-emerald-300' : 'bg-purple-100 text-purple-700 border-purple-300'
                        }`}>
                          {idx === 0 ? '🔴 Élevé' : idx === 1 ? '🟢 Rentabilisé' : '⚡ Pro'}
                        </span>
                      )}
                    </div>
                    <span className={`text-[10px] ${isVibrant ? 'text-purple-600 font-medium' : 'text-japandi-muted'}`}>
                      {t(`categories.${sub.category}` as any) || sub.category}
                    </span>
                  </div>
                </div>
                <span className={`font-extrabold text-xs ${isVibrant ? 'text-pink-600 font-black' : 'text-japandi-terracotta'} ${isAmountBlurred ? 'privacy-blur' : ''}`}>
                  {format(sub.amount)}
                </span>
              </div>
            ))}
          </div>
        )}
      </div>


      {/* Goal Setting Dialog */}
      <GoalDialog
        isOpen={isGoalModalOpen}
        onClose={() => setIsGoalModalOpen(false)}
        currentCost={totalMonthly}
      />

      {/* 1-Click Loi Chatel Cancellation Modal */}
      <CancellationArenaModal
        isOpen={isCancellationModalOpen}
        onClose={() => setIsCancellationModalOpen(false)}
      />

      {/* Invoice Scanner Modal */}
      <ScanInvoiceModal
        isOpen={isScanInvoiceModalOpen}
        onClose={() => setIsScanInvoiceModalOpen(false)}
      />
    </div>
  );
}

