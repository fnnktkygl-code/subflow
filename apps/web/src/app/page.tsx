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
import {
  SlidersHorizontal,
  Target,
  Calendar,
  PieChart,
  ArrowRight,
  ChevronRight,
  Check,
  Info
} from 'lucide-react';

export default function HomePage() {
  const {
    subscriptions,
    profile,
    isAmountBlurred,
    isSelectionMode,
    excludedIds,
    toggleSelectionMode
  } = useSubscriptionStore();
  const { t, format } = useTranslation();

  const [selectedCategory, setSelectedCategory] = useState<SubscriptionCategory | null>(null);
  const [isGoalModalOpen, setIsGoalModalOpen] = useState(false);

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

      {/* 2. Monthly Spending Card */}
      <div className="rounded-japandi-2xl bg-japandi-surface border border-japandi-border p-5 sm:p-6 shadow-japandi-sm flex flex-col gap-5">
        {/* Header: Title + yearly subtitle + tune button */}
        <div className="flex items-start justify-between">
          <div className="flex flex-col gap-0.5">
            <div className="flex items-center gap-2">
              <span className="text-lg">💰</span>
              <h3 className="font-semibold text-sm text-japandi-muted">{t('home.spendingTitle')}</h3>
            </div>
            <p className="text-xs text-japandi-muted ml-7">
              {t('home.annualized', { amount: format(totalYearly) })}
            </p>
          </div>
          <button
            type="button"
            onClick={() => setIsGoalModalOpen(true)}
            aria-label={t('home.monthlyTarget')}
            className="flex items-center gap-1 px-3 py-1.5 rounded-japandi-md bg-japandi-elevated border border-japandi-border hover:border-japandi-pine text-japandi-text text-xs font-semibold transition-all shadow-xs"
          >
            <SlidersHorizontal className="w-3.5 h-3.5 text-japandi-pine" />
            <span className="hidden sm:inline">{t('settings.configureBudget')}</span>
          </button>
        </div>

        {/* Big Hero Amount */}
        <div className="flex items-baseline gap-2">
          <span className={`text-4xl sm:text-5xl font-extrabold tracking-tight text-japandi-text ${isAmountBlurred ? 'blur-md select-none' : ''}`}>
            {format(totalMonthly)}
          </span>
          <span className="text-sm font-semibold text-japandi-muted">
            {t('cycles.perMonth')}
          </span>
        </div>

        {/* Spending Goal Progress Bar */}
        {spendingGoal > 0 && (
          <div className="flex flex-col gap-2 pt-2 border-t border-japandi-border">
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
              className="w-full h-2 rounded-japandi-full bg-japandi-elevated overflow-hidden"
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

        {/* What-If Simulator Action Trigger */}
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
              <span className="w-2 h-2 rounded-full bg-japandi-pine animate-pulse" />
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
        <div className="rounded-japandi-2xl bg-japandi-surface border border-japandi-border p-5 sm:p-6 shadow-japandi-sm flex flex-col gap-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <PieChart className="w-4 h-4 text-japandi-pine" />
              <h3 className="font-bold text-sm text-japandi-text">{t('home.categoriesTitle')}</h3>
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
                        <span className="font-semibold text-xs text-japandi-text truncate block">
                          {t(`categories.${catKey}` as any) || catKey}
                        </span>
                        <span className="text-[10px] text-japandi-muted">
                          {cat.count} service{cat.count > 1 ? 's' : ''} ({percentage.toFixed(0)}%)
                        </span>
                      </div>
                    </div>

                    <span className={`font-bold text-xs text-japandi-text ${isAmountBlurred ? 'blur-xs select-none' : ''}`}>
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
      <div className="rounded-japandi-2xl bg-japandi-surface border border-japandi-border p-5 sm:p-6 shadow-japandi-sm flex flex-col gap-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Calendar className="w-4 h-4 text-japandi-pine" />
            <h3 className="font-bold text-sm text-japandi-text">{t('home.upcomingTitle')}</h3>
          </div>
          <Link
            href="/schedule"
            className="text-xs font-bold text-japandi-pine hover:underline flex items-center gap-1"
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
                className="p-3.5 rounded-japandi-xl bg-japandi-elevated border border-japandi-border flex items-center justify-between shadow-2xs"
              >
                <div className="flex items-center gap-2.5 min-w-0">
                  <SubscriptionLogo name={sub.name} logoUrl={sub.logoUrl} category={sub.category} size={32} />
                  <div className="min-w-0">
                    <h4 className="font-bold text-xs text-japandi-text truncate">{sub.name}</h4>
                    <span className="text-[10px] text-japandi-muted">
                      {t(`categories.${sub.category}` as any) || sub.category}
                    </span>
                  </div>
                </div>
                <span className={`font-extrabold text-xs text-japandi-terracotta ${isAmountBlurred ? 'blur-xs select-none' : ''}`}>
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
    </div>
  );
}
