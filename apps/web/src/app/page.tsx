'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useTranslation } from '../hooks/useTranslation';
import {
  calculateTotalMonthlyCost,
  calculateTotalYearlyCost,
  calculateCategoryBreakdown,
  normalizeMonthlyAmount,
  SubscriptionCategory,
  Subscription
} from '@subflow/core';
import { SpendingDonut, SubscriptionLogo, Tooltip } from '@subflow/ui';

import { CategoryIcon } from '../components/CategoryIcon';
import { GoalDialog } from '../components/GoalDialog';
import { ActionableInsightHeader } from '../components/ActionableInsightHeader';
import { CancellationArenaModal } from '../components/CancellationArenaModal';
import { AddSubscriptionModal } from '../components/AddSubscriptionModal';
import { GoogleDriveSyncCard } from '../components/GoogleDriveSyncCard';

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
  Flame,
  Zap,
  TrendingDown
} from 'lucide-react';


import { OnboardingWelcomeScreen } from '../components/OnboardingWelcomeScreen';

export default function HomePage() {
  const {
    subscriptions,
    profile,
    isAmountBlurred,
    toggleAmountBlur,
    isSelectionMode,
    excludedIds,
    toggleSelectionMode,
    hasCompletedOnboarding,
    googleAccount
  } = useSubscriptionStore();
  const { t, format, locale } = useTranslation();

  const [selectedCategory, setSelectedCategory] = useState<SubscriptionCategory | null>(null);
  const [editingSub, setEditingSub] = useState<Subscription | null>(null);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [isGoalModalOpen, setIsGoalModalOpen] = useState(false);
  const [isCancellationModalOpen, setIsCancellationModalOpen] = useState(false);
  const [mounted, setMounted] = useState(false);
  const longPressTimerRef = React.useRef<NodeJS.Timeout | null>(null);


  React.useEffect(() => {
    setMounted(true);
  }, []);

  // Hydration safety: render matching blank shell until client store hydrates
  if (!mounted) {
    return (
      <div className="min-h-[50vh] flex items-center justify-center">
        <div className="w-8 h-8 rounded-full border-2 border-japandi-pine border-t-transparent animate-spin" />
      </div>
    );
  }

  // Non-blocking: App is directly accessible to visitors and Google reviewers without signing in



  const activeExcluded = isSelectionMode ? new Set(excludedIds) : new Set<string>();
  const totalMonthly = calculateTotalMonthlyCost(subscriptions, activeExcluded);
  const totalYearly = calculateTotalYearlyCost(subscriptions, activeExcluded);
  const categoryBreakdown = calculateCategoryBreakdown(subscriptions, activeExcluded);

  const spendingGoal = profile.spendingGoal ?? 0;
  const goalProgress = spendingGoal > 0 ? Math.min(totalMonthly / spendingGoal, 1) : 0;
  const isUnderGoal = totalMonthly <= spendingGoal;
  const goalDiff = Math.abs(spendingGoal - totalMonthly);

  return (
    <div className="flex flex-col gap-6 animate-in fade-in duration-300 max-w-4xl mx-auto">



      {/* 1. Actionable Financial Insight Header */}
      <ActionableInsightHeader />

      {/* Cloud Drive Continuity Banner */}
      <GoogleDriveSyncCard variant="banner" />


      {/* 2. Spending Card with Goal & Long Press to Blur */}
      <div
        onContextMenu={(e) => { e.preventDefault(); toggleAmountBlur(); }}
        onTouchStart={() => {
          longPressTimerRef.current = setTimeout(toggleAmountBlur, 500);
        }}
        onTouchEnd={() => {
          if (longPressTimerRef.current) clearTimeout(longPressTimerRef.current);
        }}
        className="rounded-japandi-2xl p-5 sm:p-6 flex flex-col gap-4 relative overflow-hidden transition-all select-none bg-japandi-surface border border-japandi-border hover:border-japandi-pine/50 shadow-japandi-sm cursor-default"
      >

          {/* Subtle accent backdrop */}
          <div className="absolute top-0 right-0 w-32 h-32 bg-japandi-pine/5 rounded-full blur-2xl -mr-10 -mt-10 pointer-events-none" />

          {/* Header: Title + tune button */}
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="text-lg">💰</span>
              <h3 className="font-bold text-sm text-japandi-muted">
                {t('home.spendingTitle')}
              </h3>
            </div>
            <button
              type="button"
              onClick={(e) => { e.stopPropagation(); setIsGoalModalOpen(true); }}
              aria-label={t('home.monthlyTarget')}
              className="flex items-center gap-1 px-3 py-1.5 rounded-japandi-md text-xs font-semibold transition-all shadow-xs bg-japandi-elevated border border-japandi-border hover:border-japandi-pine text-japandi-text"
            >
              <SlidersHorizontal className="w-3.5 h-3.5 text-japandi-pine" />
              <span className="hidden sm:inline">{t('settings.configureBudget')}</span>
            </button>
          </div>

          {/* Big Hero Amount + Harmonious Annual Badge */}
          <div
            onClick={toggleAmountBlur}
            className="flex flex-wrap items-baseline gap-x-3 gap-y-2 cursor-pointer"
          >
            <span className={`text-4xl sm:text-5xl font-extrabold tracking-tight text-japandi-text ${isAmountBlurred ? 'privacy-blur' : ''}`}>
              {format(totalMonthly)}
            </span>
            <span className="text-sm font-bold text-japandi-muted">
              {t('cycles.perMonth')}
            </span>

            {/* Premium Pill Badge for Annualized Total */}
            <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold border transition-all ${
              isAmountBlurred
                ? 'bg-japandi-sand/30 border-japandi-border text-japandi-muted'
                : 'bg-japandi-pine/10 border-japandi-pine/20 text-japandi-pine dark:text-emerald-400 shadow-xs'
            }`}>
              <span className="text-[10px] opacity-75 font-normal uppercase tracking-wider">
                {locale === 'fr' ? 'Soit' : 'Equiv.'}
              </span>
              <span className={isAmountBlurred ? 'privacy-blur' : 'font-extrabold'}>
                {isAmountBlurred ? '•••• €' : format(totalYearly)}
              </span>
              <span className="text-[10px] opacity-75 font-normal">
                / {locale === 'fr' ? 'an' : 'yr'}
              </span>
            </span>
          </div>

          {/* Spending Goal Progress Bar */}
          {spendingGoal > 0 && (
            <div className="flex flex-col gap-2 pt-2 border-t border-japandi-border/40">
              <div className="flex items-center justify-between text-xs">
                <div className="flex items-center gap-1.5 text-japandi-muted">
                  <Target className="w-3.5 h-3.5 text-japandi-pine" />
                  <span>{t('home.targetBudget')} : {format(spendingGoal)}</span>
                </div>
                <span className={`font-bold ${isUnderGoal ? 'text-japandi-pine' : 'text-japandi-terracotta'}`}>
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
                className="w-full h-2.5 rounded-japandi-full overflow-hidden bg-japandi-elevated"
              >
                <div
                  className={`h-full rounded-japandi-full transition-all duration-500 ${
                    isUnderGoal ? 'bg-japandi-pine' : 'bg-japandi-terracotta'
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
                isSelectionMode
                  ? 'bg-japandi-sand/60 border-japandi-pine text-japandi-pine'
                  : 'bg-japandi-elevated border-japandi-border hover:border-japandi-pine text-japandi-text'
              }`}
            >
              <div className="flex items-center gap-2">
                <span className="w-2 h-2 rounded-full animate-pulse bg-japandi-pine" />
                <span>{isSelectionMode ? t('whatIf.modeActive') : t('home.whatIfTitle')}</span>
              </div>
              <span className="text-[11px] text-japandi-muted">
                {isSelectionMode ? t('whatIf.exitMode') : t('home.whatIfButton')} →
              </span>
            </button>
          </div>
        </div>

      {/* 3. Category Breakdown & Donut */}

      {subscriptions.length > 0 && (
        <div className="rounded-japandi-2xl border p-5 sm:p-6 flex flex-col gap-4 bg-japandi-surface border-japandi-border shadow-japandi-sm">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <PieChart className="w-4 h-4 text-japandi-pine" />
              <h3 className="font-bold text-sm text-japandi-text">
                {t('home.categoriesTitle')}
              </h3>
            </div>
            <span className="text-xs text-japandi-muted">
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
                      isSelected
                        ? 'bg-japandi-sand/60 border-japandi-pine'
                        : 'bg-japandi-elevated border-japandi-border hover:border-japandi-border-strong'
                    }`}
                  >
                    <div className="flex items-center gap-2.5 min-w-0">
                      <CategoryIcon category={catKey} className="w-3.5 h-3.5" showBackground={true} />
                      <div className="min-w-0">
                        <span className="font-semibold text-xs truncate block text-japandi-text">
                          {t(`categories.${catKey}` as any) || catKey}
                        </span>
                        <span className="text-[10px] text-japandi-muted">
                          {cat.count} service{cat.count > 1 ? 's' : ''} ({percentage.toFixed(0)}%)
                        </span>
                      </div>
                    </div>

                    <span className={`font-bold text-xs text-japandi-text ${isAmountBlurred ? 'privacy-blur' : ''}`}>
                      {format(cat.total)}
                    </span>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Category Subscriptions Breakdown Detail List (as in original app) */}
          {selectedCategory && categoryBreakdown[selectedCategory] && (() => {
            const activeCategoryData = categoryBreakdown[selectedCategory];
            if (!activeCategoryData) return null;

            return (
              <div className="flex flex-col gap-3 pt-4 border-t border-japandi-border animate-in fade-in-50 slide-in-from-top-2 duration-200">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <CategoryIcon category={selectedCategory} className="w-4 h-4" showBackground={true} />
                    <div>
                      <h4 className="font-extrabold text-xs text-japandi-text">
                        {t(`categories.${selectedCategory}` as any) || selectedCategory}
                      </h4>
                      <span className="text-[10px] text-japandi-muted">
                        {activeCategoryData.subscriptions.length} service{activeCategoryData.subscriptions.length > 1 ? 's' : ''} • {format(activeCategoryData.total)} / mois ({activeCategoryData.percentage.toFixed(0)}% du total)
                      </span>
                    </div>
                  </div>

                  <button
                    type="button"
                    onClick={() => setSelectedCategory(null)}
                    className="px-2.5 py-1 rounded-japandi-md bg-japandi-elevated hover:bg-japandi-sand/60 border border-japandi-border text-[11px] font-bold text-japandi-muted hover:text-japandi-text transition-all"
                  >
                    ✕ {locale === 'fr' ? 'Réinitialiser' : 'Show all'}
                  </button>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
                  {activeCategoryData.subscriptions.map((sub) => {
                    const monthlyEquivalent = normalizeMonthlyAmount(sub.amount, sub.cycle);
                    const subPercentage = activeCategoryData.total > 0
                      ? (monthlyEquivalent / activeCategoryData.total) * 100
                      : 0;

                    return (
                      <div
                        key={sub.id}
                        onClick={() => {
                          setEditingSub(sub);
                          setIsAddModalOpen(true);
                        }}
                        className="p-3.5 rounded-japandi-xl border border-japandi-border hover:border-japandi-pine bg-japandi-elevated hover:bg-japandi-sand/20 flex items-center justify-between cursor-pointer transition-all shadow-xs group"
                      >
                        <div className="flex items-center gap-3 min-w-0">
                          <SubscriptionLogo name={sub.name} logoUrl={sub.logoUrl} category={sub.category} size={40} />
                          <div className="min-w-0">
                            <h5 className="font-bold text-xs text-japandi-text group-hover:text-japandi-pine transition-colors truncate">
                              {sub.name}
                            </h5>
                            <div className="flex items-center gap-1.5 text-[10px] text-japandi-muted">
                              <span>{t(`cycles.${sub.cycle}` as any) || sub.cycle}</span>
                              <span>•</span>
                              <span>{format(sub.amount)}</span>
                            </div>
                          </div>
                        </div>

                        <div className="flex flex-col items-end flex-shrink-0">
                          <span className={`font-extrabold text-xs text-japandi-text ${isAmountBlurred ? 'privacy-blur' : ''}`}>
                            {format(monthlyEquivalent)} / mois
                          </span>
                          <span className="text-[10px] font-semibold text-japandi-pine">
                            {subPercentage.toFixed(0)}% du pôle
                          </span>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            );
          })()}

        </div>
      )}

      {/* 4. Upcoming Renewals Widget */}
      <div className="rounded-japandi-2xl border p-5 sm:p-6 flex flex-col gap-4 bg-japandi-surface border-japandi-border shadow-japandi-sm">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Calendar className="w-4 h-4 text-japandi-pine" />
            <h3 className="font-bold text-sm text-japandi-text">
              {t('home.upcomingTitle')}
            </h3>
          </div>
          <Link
            href="/schedule"
            className="text-xs font-bold flex items-center gap-1 text-japandi-pine hover:underline"
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
            {subscriptions.slice(0, 3).map((sub) => (
              <div
                key={sub.id}
                onClick={() => {
                  setEditingSub(sub);
                  setIsAddModalOpen(true);
                }}
                className="p-3.5 rounded-japandi-xl border flex items-center justify-between shadow-2xs transition-all bg-japandi-elevated border-japandi-border hover:border-japandi-pine cursor-pointer"
              >
                <div className="flex items-center gap-3 min-w-0">
                  <SubscriptionLogo name={sub.name} logoUrl={sub.logoUrl} category={sub.category} size={44} />
                  <div className="min-w-0">
                    <h4 className="font-bold text-xs truncate text-japandi-text">{sub.name}</h4>
                    <span className="text-[10px] text-japandi-muted">
                      {t(`categories.${sub.category}` as any) || sub.category}
                    </span>
                  </div>
                </div>
                <span className={`font-extrabold text-xs text-japandi-terracotta ${isAmountBlurred ? 'privacy-blur' : ''}`}>
                  {format(sub.amount)}
                </span>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Add / Edit Subscription Modal */}
      {isAddModalOpen && (
        <AddSubscriptionModal
          isOpen={isAddModalOpen}
          onClose={() => {
            setIsAddModalOpen(false);
            setEditingSub(null);
          }}
          editSubscription={editingSub}
        />
      )}

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
    </div>
  );
}



