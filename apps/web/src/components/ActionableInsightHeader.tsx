'use client';

import React, { useMemo } from 'react';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useTranslation } from '../hooks/useTranslation';
import { calculateUpcomingOccurrences, calculateTotalMonthlyCost } from '@subflow/core';
import { Pencil, Check, Bell, Clock, AlertTriangle, CheckCircle2, Activity } from 'lucide-react';

export const ActionableInsightHeader: React.FC = () => {
  const { profile, updateProfile, subscriptions, isAmountBlurred } = useSubscriptionStore();
  const { t, format, locale } = useTranslation();

  const [isEditingName, setIsEditingName] = React.useState(false);
  const [nameInput, setNameInput] = React.useState(profile.name || 'Richard');

  const totalMonthly = useMemo(() => calculateTotalMonthlyCost(subscriptions), [subscriptions]);
  const spendingGoal = profile.spendingGoal ?? 0;

  // 1. Time-based respectful greeting localized
  const greetingTime = useMemo(() => {
    const hour = new Date().getHours();
    if (locale === 'fr') {
      if (hour >= 5 && hour < 18) return 'Bonjour';
      return 'Bonsoir';
    }
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 18) return 'Good afternoon';
    return 'Good evening';
  }, [locale]);

  const displayName = profile.name && profile.name.trim() !== '' ? profile.name.trim() : null;
  const greetingTitle = displayName ? `${greetingTime}, ${displayName}` : greetingTime;

  const handleSaveInlineName = (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    const finalName = nameInput.trim() || 'Richard';
    updateProfile({ name: finalName });
    setNameInput(finalName);
    setIsEditingName(false);
  };

  const displayAmount = (amt: number) => isAmountBlurred ? '•••• €' : format(amt);

  // 2. Compute the most critical financial insight
  const insight = useMemo(() => {
    const now = new Date(2026, 7, 27); // August 27, 2026
    const occurrences = calculateUpcomingOccurrences(subscriptions, now, 60);
    const sortedUpcoming = occurrences.filter((occ) => occ.daysRemaining >= 0);

    // Case A: Imminent renewal (today or within 3 days)
    if (sortedUpcoming.length > 0 && sortedUpcoming[0]) {
      const nextOcc = sortedUpcoming[0];
      if (nextOcc.daysRemaining === 0) {
        return {
          type: 'imminent',
          text: locale === 'fr'
            ? `Prélèvement aujourd'hui : ${nextOcc.subscription.name} (${displayAmount(nextOcc.subscription.amount)})`
            : `Due today: ${nextOcc.subscription.name} (${displayAmount(nextOcc.subscription.amount)})`,
          colorClass: 'text-japandi-terracotta border-japandi-terracotta/30 bg-japandi-terracotta/10',
          icon: <Bell className="w-4 h-4 flex-shrink-0 text-japandi-terracotta" />
        };
      }
      if (nextOcc.daysRemaining <= 3) {
        return {
          type: 'imminent',
          text: locale === 'fr'
            ? `Prochain prélèvement : ${nextOcc.subscription.name} dans ${nextOcc.daysRemaining} jour${nextOcc.daysRemaining > 1 ? 's' : ''}`
            : `Next renewal: ${nextOcc.subscription.name} in ${nextOcc.daysRemaining} day${nextOcc.daysRemaining > 1 ? 's' : ''}`,
          colorClass: 'text-japandi-terracotta border-japandi-terracotta/30 bg-japandi-sand/90',
          icon: <Clock className="w-4 h-4 flex-shrink-0 text-japandi-terracotta" />
        };
      }
    }

    // Case B: Budget exceeded
    if (spendingGoal > 0 && totalMonthly > spendingGoal) {
      const overAmount = totalMonthly - spendingGoal;
      return {
        type: 'warning',
        text: locale === 'fr'
          ? `Budget dépassé : +${displayAmount(overAmount)} au-dessus de l'objectif`
          : `Over target: +${displayAmount(overAmount)} exceeding monthly goal`,
        colorClass: 'text-japandi-akane border-japandi-akane/30 bg-japandi-akane/10',
        icon: <AlertTriangle className="w-4 h-4 flex-shrink-0 text-japandi-akane" />
      };
    }

    // Case C: Budget on track
    if (spendingGoal > 0 && totalMonthly <= spendingGoal) {
      const buffer = spendingGoal - totalMonthly;
      return {
        type: 'healthy',
        text: locale === 'fr'
          ? `Objectif respecté : ${displayAmount(buffer)} restant sur le budget cible`
          : `On track: ${displayAmount(buffer)} remaining under monthly target`,
        colorClass: 'text-japandi-pine border-japandi-pine/30 bg-japandi-pine/10',
        icon: <CheckCircle2 className="w-4 h-4 flex-shrink-0 text-japandi-pine" />
      };
    }

    // Case D: General healthy summary
    return {
      type: 'neutral',
      text: locale === 'fr'
        ? `Gestion active de ${subscriptions.length} abonnement${subscriptions.length > 1 ? 's' : ''}`
        : `Active tracking of ${subscriptions.length} subscription${subscriptions.length > 1 ? 's' : ''}`,
      colorClass: 'text-japandi-pine border-japandi-border bg-japandi-elevated',
      icon: <Activity className="w-4 h-4 flex-shrink-0 text-japandi-pine" />
    };
  }, [subscriptions, totalMonthly, spendingGoal, locale, isAmountBlurred]);



  return (
    <div className="flex flex-col gap-2 pt-2 select-none">
      {isEditingName ? (
        <form onSubmit={handleSaveInlineName} className="flex items-center gap-2">
          <span className="text-2xl sm:text-3xl font-extrabold text-japandi-text">{greetingTime},</span>
          <input
            type="text"
            autoFocus
            value={nameInput}
            onChange={(e) => setNameInput(e.target.value)}
            onBlur={() => handleSaveInlineName()}
            className="px-2.5 py-1 rounded-japandi-md bg-japandi-surface border border-japandi-pine text-japandi-text text-2xl font-extrabold focus:outline-none w-44 shadow-japandi-xs"
            maxLength={25}
          />
          <button
            type="submit"
            className="p-1.5 rounded-japandi-md bg-japandi-pine text-white hover:bg-japandi-pine/90 transition-colors shadow-2xs"
            aria-label="Enregistrer"
          >
            <Check className="w-4 h-4 stroke-[3]" />
          </button>
        </form>
      ) : (
        <div className="flex items-center gap-2 group">
          <h1
            onClick={() => setIsEditingName(true)}
            className="text-3xl sm:text-4xl font-extrabold tracking-tight text-japandi-text font-sans cursor-pointer hover:text-japandi-pine transition-colors"
            style={{ lineHeight: 1.15, letterSpacing: '-0.6px' }}
            title="Cliquer pour modifier votre prénom"
          >
            {greetingTitle}
          </h1>
          <button
            type="button"
            onClick={() => setIsEditingName(true)}
            aria-label="Modifier mon prénom"
            className="opacity-0 group-hover:opacity-100 p-1.5 rounded-japandi-md text-japandi-muted hover:text-japandi-pine hover:bg-japandi-elevated transition-all"
          >
            <Pencil className="w-3.5 h-3.5" />
          </button>
        </div>
      )}

      {/* Dynamic Actionable Insight Pill */}
      <div className="flex items-center">
        <div
          className={`inline-flex items-center gap-2 px-3.5 py-1.5 rounded-japandi-full border text-xs sm:text-sm font-semibold transition-all shadow-2xs ${insight.colorClass}`}
        >
          {insight.icon}
          <span>{insight.text}</span>
        </div>
      </div>
    </div>
  );
};

