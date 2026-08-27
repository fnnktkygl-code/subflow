'use client';

import React, { useMemo } from 'react';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { formatCurrency, calculateUpcomingOccurrences, calculateTotalMonthlyCost } from '@subflow/core';

export const ActionableInsightHeader: React.FC = () => {
  const { profile, subscriptions } = useSubscriptionStore();

  const totalMonthly = useMemo(() => calculateTotalMonthlyCost(subscriptions), [subscriptions]);
  const currencySymbol = profile.currencySymbol || '€';
  const spendingGoal = profile.spendingGoal ?? 0;

  // 1. Time-based respectful greeting
  const greetingTime = useMemo(() => {
    const hour = new Date().getHours();
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 18) return 'Good afternoon';
    return 'Good evening';
  }, []);

  const displayName = profile.name && profile.name.trim() !== '' ? profile.name.trim() : null;
  const greetingTitle = displayName ? `${greetingTime}, ${displayName}` : greetingTime;

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
          text: `Due today: ${nextOcc.subscription.name} (${formatCurrency(nextOcc.subscription.amount, currencySymbol)})`,
          colorClass: 'text-japandi-terracotta border-japandi-terracotta/30 bg-japandi-terracotta/10',
          icon: (
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-4 h-4 text-japandi-terracotta">
              <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" />
              <path d="M13.73 21a2 2 0 0 1-3.46 0" />
            </svg>
          )
        };
      }
      if (nextOcc.daysRemaining <= 3) {
        return {
          type: 'imminent',
          text: `Next renewal: ${nextOcc.subscription.name} in ${nextOcc.daysRemaining} day${nextOcc.daysRemaining > 1 ? 's' : ''}`,
          colorClass: 'text-japandi-terracotta border-japandi-terracotta/30 bg-japandi-sand/90',
          icon: (
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-4 h-4 text-japandi-terracotta">
              <circle cx="12" cy="12" r="10" />
              <polyline points="12 6 12 12 16 14" />
            </svg>
          )
        };
      }
    }

    // Case B: Budget exceeded
    if (spendingGoal > 0 && totalMonthly > spendingGoal) {
      const overAmount = totalMonthly - spendingGoal;
      return {
        type: 'warning',
        text: `Over target: +${formatCurrency(overAmount, currencySymbol)} exceeding monthly goal`,
        colorClass: 'text-japandi-akane border-japandi-akane/30 bg-japandi-akane/10',
        icon: (
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-4 h-4 text-japandi-akane">
            <path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z" />
            <line x1="12" y1="9" x2="12" y2="13" />
            <line x1="12" y1="17" x2="12.01" y2="17" />
          </svg>
        )
      };
    }

    // Case C: Budget on track
    if (spendingGoal > 0 && totalMonthly <= spendingGoal) {
      const buffer = spendingGoal - totalMonthly;
      return {
        type: 'healthy',
        text: `On track: ${formatCurrency(buffer, currencySymbol)} remaining under monthly target`,
        colorClass: 'text-japandi-pine border-japandi-pine/30 bg-japandi-pine/10',
        icon: (
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-4 h-4 text-japandi-pine">
            <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
            <polyline points="9 12 11 14 15 10" />
          </svg>
        )
      };
    }

    // Case D: General healthy summary
    return {
      type: 'summary',
      text: `${subscriptions.length} active subscriptions totaling ${formatCurrency(totalMonthly, currencySymbol)}/mo`,
      colorClass: 'text-japandi-muted border-japandi-border bg-japandi-sand/80',
      icon: (
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-4 h-4 text-japandi-muted">
          <path d="M22 12h-4l-3 9L9 3l-3 9H2" />
        </svg>
      )
    };
  }, [subscriptions, totalMonthly, spendingGoal, currencySymbol]);

  return (
    <div className="flex flex-col gap-2 pt-2 select-none">
      {/* Title */}
      <h1 className="text-3xl sm:text-4xl font-extrabold tracking-tight text-japandi-text font-sans" style={{ lineHeight: 1.15, letterSpacing: '-0.6px' }}>
        {greetingTitle}
      </h1>

      {/* Actionable Financial Insight Pill with Authentic Vector SVG */}
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
