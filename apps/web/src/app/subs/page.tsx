'use client';

import React, { useState, useMemo, useId } from 'react';
import { useSubscriptionStore } from '../../store/useSubscriptionStore';
import { useTranslation } from '../../hooks/useTranslation';
import { useEscapeKey } from '../../hooks/useEscapeKey';
import { SubscriptionLogo } from '@subflow/ui';
import { Subscription, calculateTotalMonthlyCost, calculateTotalYearlyCost } from '@subflow/core';
import {
  ClipboardList,
  Calendar,
  TrendingUp,
  Bell,
  Sparkles,
  Trash2,
  History,
  Check,
  CheckSquare,
  Square,
  Plus,
  AlertCircle
} from 'lucide-react';
import { AddSubscriptionModal } from '../../components/AddSubscriptionModal';

interface GroupedOccurrence {
  subscription: Subscription;
  dateStr: string;
  formattedDate: string;
  isToday: boolean;
}

export default function SubsPage() {
  const {
    subscriptions,
    profile,
    isAmountBlurred,
    toggleAmountBlur,
    isSelectionMode,
    excludedIds,
    toggleSelectionMode,
    toggleExcludedId,
    deleteSubscription
  } = useSubscriptionStore();
  const { t, format, locale } = useTranslation();

  const [editingSub, setEditingSub] = useState<Subscription | null>(null);
  const [deletingSub, setDeletingSub] = useState<Subscription | null>(null);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);

  const activeExcluded = isSelectionMode ? new Set(excludedIds) : new Set<string>();
  const totalMonthly = calculateTotalMonthlyCost(subscriptions, activeExcluded);
  const totalYearly = calculateTotalYearlyCost(subscriptions, activeExcluded);
  const remainingSubsCount = subscriptions.length - activeExcluded.size;

  const handleConfirmDelete = () => {
    if (deletingSub) {
      deleteSubscription(deletingSub.id);
      setDeletingSub(null);
    }
  };

  // Group subscriptions into sections: "Paid Earlier This Month", "Due Today", "September 2026" / future months
  const groupedSections = useMemo(() => {
    const today = new Date();
    const todayDay = today.getDate();
    const todayMonth = today.getMonth();
    const todayYear = today.getFullYear();

    const past: GroupedOccurrence[] = [];
    const dueToday: GroupedOccurrence[] = [];
    const futureByMonth: Record<string, GroupedOccurrence[]> = {};

    subscriptions.forEach((sub) => {
      const subDate = new Date(sub.startDate);
      const subDay = subDate.getDate();

      const dateObj = new Date(todayYear, todayMonth, subDay);
      const formattedDate = dateObj.toLocaleDateString(locale === 'fr' ? 'fr-FR' : 'en-US', {
        weekday: 'short',
        day: 'numeric',
        month: 'short'
      });

      // 1. Check if paid earlier this month (day < todayDay in current month)
      if (subDay < todayDay) {
        past.push({
          subscription: sub,
          dateStr: sub.startDate,
          formattedDate,
          isToday: false
        });
      }

      // 2. Check if due today (day == todayDay)
      if (subDay === todayDay) {
        dueToday.push({
          subscription: sub,
          dateStr: sub.startDate,
          formattedDate,
          isToday: true
        });
      }

      // 3. Next month occurrence
      const nextMonthIndex = (todayMonth + 1) % 12;
      const nextMonthYear = todayMonth === 11 ? todayYear + 1 : todayYear;
      const nextDate = new Date(nextMonthYear, nextMonthIndex, subDay);
      const nextMonthLabel = nextDate.toLocaleDateString(locale === 'fr' ? 'fr-FR' : 'en-US', {
        month: 'long',
        year: 'numeric'
      });
      const nextFormattedDate = nextDate.toLocaleDateString(locale === 'fr' ? 'fr-FR' : 'en-US', {
        weekday: 'short',
        day: 'numeric',
        month: 'short'
      });

      if (!futureByMonth[nextMonthLabel]) {
        futureByMonth[nextMonthLabel] = [];
      }
      futureByMonth[nextMonthLabel].push({
        subscription: sub,
        dateStr: `${nextMonthYear}-${String(nextMonthIndex + 1).padStart(2, '0')}-${String(subDay).padStart(2, '0')}`,
        formattedDate: nextFormattedDate,
        isToday: false
      });
    });

    return { past, dueToday, futureByMonth };
  }, [subscriptions, locale]);

  const longPressTimers = React.useRef<Record<string, NodeJS.Timeout>>({});

  const handleCardLongPress = (subId: string) => {
    if (!isSelectionMode) {
      toggleSelectionMode();
    }
    toggleExcludedId(subId);
  };

  const startLongPress = (subId: string) => {
    longPressTimers.current[subId] = setTimeout(() => {
      handleCardLongPress(subId);
    }, 450);
  };

  const cancelLongPress = (subId: string) => {
    if (longPressTimers.current[subId]) {
      clearTimeout(longPressTimers.current[subId]);
      delete longPressTimers.current[subId];
    }
  };

  return (
    <div className={`flex flex-col gap-6 animate-in fade-in duration-300 max-w-4xl mx-auto ${isSelectionMode ? 'pb-80' : 'pb-16'}`}>
      {/* 1. Top Header with What-If Mode Toggle */}
      <div className="flex items-center justify-between px-1">
        <h1 className="text-2xl font-extrabold tracking-tight hidden sm:block text-japandi-text">
          {t('subs.title')}
        </h1>

        <div className="flex items-center gap-2 w-full sm:w-auto justify-between sm:justify-end">
          <button
            type="button"
            onClick={toggleSelectionMode}
            aria-expanded={isSelectionMode}
            className={`flex items-center gap-2 px-3.5 py-2 rounded-japandi-xl border text-xs font-bold transition-all shadow-xs ${
              isSelectionMode
                ? 'bg-japandi-pine text-white border-japandi-pine'
                : 'bg-japandi-surface border-japandi-border hover:border-japandi-pine text-japandi-text'
            }`}
          >
            <Sparkles className="w-3.5 h-3.5" />
            <span>{isSelectionMode ? t('whatIf.exitMode') : t('home.whatIfTitle')}</span>
          </button>

          <button
            type="button"
            onClick={() => setIsAddModalOpen(true)}
            className="flex items-center gap-1.5 px-3.5 py-2 rounded-japandi-xl text-xs font-bold transition-all bg-japandi-pine text-white hover:bg-japandi-pine/90 shadow-japandi-xs"
          >
            <Plus className="w-4 h-4" />
            <span>{t('subs.addSubscription')}</span>
          </button>
        </div>
      </div>

      {/* 2. Spending Summary Hero */}
      <div
        onClick={toggleAmountBlur}
        onContextMenu={(e) => { e.preventDefault(); toggleAmountBlur(); }}
        className="rounded-japandi-2xl p-5 sm:p-6 flex flex-col gap-3 cursor-pointer select-none transition-all bg-japandi-surface border border-japandi-border hover:border-japandi-pine/50 shadow-japandi-sm"
        title="Appui long ou clic pour masquer/afficher les montants"
      >
        <div className="flex items-center justify-between">
          <span className="text-xs uppercase tracking-wider text-japandi-muted font-semibold">
            {t('home.spendingTitle')}
          </span>
          <span className="text-xs font-bold px-2.5 py-1 rounded-full text-japandi-pine bg-japandi-pine/10">
            {t('home.activeCount', { count: remainingSubsCount })}
          </span>
        </div>

        <div className="flex items-baseline gap-2">
          <span className={`text-4xl sm:text-5xl font-extrabold text-japandi-text ${isAmountBlurred ? 'privacy-blur' : ''}`}>
            {format(totalMonthly)}
          </span>
          <span className="text-sm font-semibold text-japandi-muted">
            {t('cycles.perMonth')}
          </span>
        </div>

        <p className="text-xs text-japandi-muted">
          {t('home.annualized', { amount: isAmountBlurred ? '•••• €' : format(totalYearly) })}
        </p>
      </div>



      {/* 3. Empty State */}
      {subscriptions.length === 0 && (
        <div className="rounded-japandi-2xl bg-japandi-surface border border-japandi-border p-12 text-center flex flex-col items-center gap-4">
          <ClipboardList className="w-10 h-10 text-japandi-muted" />
          <div>
            <h3 className="font-bold text-base text-japandi-text">{t('home.emptyStateTitle')}</h3>
            <p className="text-xs text-japandi-muted max-w-sm mt-1">{t('home.emptyStateSubtitle')}</p>
          </div>
          <button
            type="button"
            onClick={() => setIsAddModalOpen(true)}
            className="px-4 py-2 rounded-japandi-md bg-japandi-pine text-white text-xs font-bold shadow-japandi-xs"
          >
            {t('subs.addSubscription')}
          </button>
        </div>
      )}

      {/* 4. Grouped Sections */}
      {subscriptions.length > 0 && (
        <div className="flex flex-col gap-6">
          {/* Section: Due Today */}
          {groupedSections.dueToday.length > 0 && (
            <div className="flex flex-col gap-3">
              <div className="flex items-center gap-2 px-1">
                <Bell className="w-4 h-4 text-japandi-terracotta" />
                <h3 className="text-xs font-extrabold uppercase tracking-wider text-japandi-terracotta">
                  {t('schedule.today')}
                </h3>
              </div>

              <div className="flex flex-col gap-2.5">
                {groupedSections.dueToday.map((occ) => renderSubCard(occ))}
              </div>
            </div>
          )}

          {/* Section: Future Months */}
          {Object.entries(groupedSections.futureByMonth).map(([monthTitle, items]) => (
            <div key={monthTitle} className="flex flex-col gap-3">
              <div className="flex items-center gap-2 px-1">
                <Calendar className="w-4 h-4 text-japandi-pine" />
                <h3 className="text-xs font-extrabold uppercase tracking-wider text-japandi-text">
                  {monthTitle}
                </h3>
              </div>

              <div className="flex flex-col gap-2.5">
                {items.map((occ) => renderSubCard(occ))}
              </div>
            </div>
          ))}

          {/* Section: Paid Earlier This Month */}
          {groupedSections.past.length > 0 && (
            <div className="flex flex-col gap-3">
              <div className="flex items-center gap-2 px-1">
                <History className="w-4 h-4 text-slate-400" />
                <h3 className="text-xs font-extrabold uppercase tracking-wider text-slate-400">
                  Prélèvements passés ce mois-ci
                </h3>
              </div>

              <div className="flex flex-col gap-2.5 opacity-80">
                {groupedSections.past.map((occ) => renderSubCard(occ))}
              </div>
            </div>
          )}
        </div>
      )}

      {/* Delete Confirmation Dialog */}
      {deletingSub && (
        <DeleteConfirmDialog
          subscription={deletingSub}
          onCancel={() => setDeletingSub(null)}
          onConfirm={handleConfirmDelete}
        />
      )}

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
    </div>
  );

  function renderSubCard(occurrence: GroupedOccurrence) {
    const { subscription: sub, formattedDate } = occurrence;
    const isExcluded = excludedIds.includes(sub.id);

    return (
      <div
        key={`${sub.id}-${formattedDate}`}
        onTouchStart={() => startLongPress(sub.id)}
        onTouchEnd={() => cancelLongPress(sub.id)}
        onMouseDown={() => startLongPress(sub.id)}
        onMouseUp={() => cancelLongPress(sub.id)}
        onClick={() => {
          if (isSelectionMode) {
            toggleExcludedId(sub.id);
          } else {
            setEditingSub(sub);
            setIsAddModalOpen(true);
          }
        }}
        className={`p-4 rounded-japandi-2xl border transition-all cursor-pointer flex items-center justify-between select-none shadow-2xs ${
          isSelectionMode && isExcluded
            ? 'bg-japandi-elevated/40 border-japandi-border opacity-50'
            : isSelectionMode
            ? 'bg-japandi-sand/60 border-japandi-pine'
            : 'bg-japandi-surface border-japandi-border hover:border-japandi-pine'
        }`}
      >
        <div className="flex items-center gap-3.5 min-w-0">
          {/* Checkbox in What-If Selection Mode */}
          {isSelectionMode && (
            <div className="flex-shrink-0">
              {isExcluded ? (
                <Square className="w-5 h-5 text-japandi-muted" />
              ) : (
                <CheckSquare className="w-5 h-5 text-japandi-pine" />
              )}
            </div>
          )}

          <SubscriptionLogo name={sub.name} logoUrl={sub.logoUrl} category={sub.category} size={48} />

          <div className="min-w-0">
            <h4 className={`font-bold text-sm truncate text-japandi-text ${isExcluded && isSelectionMode ? 'line-through' : ''}`}>
              {sub.name}
            </h4>
            <div className="flex items-center gap-2 text-xs text-japandi-muted">
              <span>{t(`categories.${sub.category}` as any) || sub.category}</span>
              <span>•</span>
              <span>{formattedDate}</span>
            </div>
          </div>
        </div>

        <div className="flex items-center gap-3 flex-shrink-0">
          <span className={`font-extrabold text-sm text-japandi-text ${isAmountBlurred ? 'privacy-blur' : ''} ${isExcluded && isSelectionMode ? 'line-through opacity-50' : ''}`}>
            {format(sub.amount)}
          </span>

          {!isSelectionMode && (
            <button
              type="button"
              aria-label={`${t('common.delete')} ${sub.name}`}
              onClick={(e) => {
                e.stopPropagation();
                setDeletingSub(sub);
              }}
              className="p-1.5 rounded-japandi-md transition-colors text-japandi-muted hover:text-japandi-terracotta hover:bg-japandi-terracotta/10"
            >
              <Trash2 className="w-4 h-4" />
            </button>
          )}
        </div>
      </div>
    );
  }


}

function DeleteConfirmDialog({
  subscription,
  onCancel,
  onConfirm
}: {
  subscription: Subscription;
  onCancel: () => void;
  onConfirm: () => void;
}) {
  const { t } = useTranslation();
  const titleId = useId();

  // Keyboard accessibility
  useEscapeKey(true, onCancel);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in duration-150">
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        className="w-full max-w-sm rounded-japandi-2xl bg-japandi-surface border border-japandi-border p-6 shadow-japandi-xl flex flex-col gap-4"
      >
        <div className="w-10 h-10 rounded-japandi-full bg-japandi-terracotta/10 text-japandi-terracotta flex items-center justify-center">
          <AlertCircle className="w-5 h-5" />
        </div>

        <div>
          <h3 id={titleId} className="font-extrabold text-base text-japandi-text">
            {t('subs.deleteConfirmTitle')}
          </h3>
          <p className="text-xs text-japandi-muted mt-1">
            {t('subs.deleteConfirmMessage', { name: subscription.name })}
          </p>
        </div>

        <div className="flex items-center justify-end gap-2.5 pt-2">
          <button
            type="button"
            onClick={onCancel}
            className="px-4 py-2 rounded-japandi-md border border-japandi-border text-xs font-bold text-japandi-muted hover:text-japandi-text transition-colors"
          >
            {t('common.cancel')}
          </button>
          <button
            type="button"
            onClick={onConfirm}
            className="px-4 py-2 rounded-japandi-md bg-japandi-terracotta text-white text-xs font-bold hover:bg-japandi-terracotta/90 transition-colors shadow-2xs"
          >
            {t('common.delete')}
          </button>
        </div>
      </div>
    </div>
  );
}
