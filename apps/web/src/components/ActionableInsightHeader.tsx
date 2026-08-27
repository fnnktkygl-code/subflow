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
          icon: <Bell className="w-4 h-4 text-japandi-terracotta flex-shrink-0" />
        };
      }
      if (nextOcc.daysRemaining <= 3) {
        return {
          type: 'imminent',
          text: locale === 'fr'
            ? `Prochain prélèvement : ${nextOcc.subscription.name} dans ${nextOcc.daysRemaining} jour${nextOcc.daysRemaining > 1 ? 's' : ''}`
            : `Next renewal: ${nextOcc.subscription.name} in ${nextOcc.daysRemaining} day${nextOcc.daysRemaining > 1 ? 's' : ''}`,
          colorClass: 'text-japandi-terracotta border-japandi-terracotta/30 bg-japandi-sand/90',
          icon: <Clock className="w-4 h-4 text-japandi-terracotta flex-shrink-0" />
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
        icon: <AlertTriangle className="w-4 h-4 text-japandi-akane flex-shrink-0" />
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
        icon: <CheckCircle2 className="w-4 h-4 text-japandi-pine flex-shrink-0" />
      };
    }

    // Case D: General healthy summary
    return {
      type: 'neutral',
      text: locale === 'fr'
        ? `Gestion active de ${subscriptions.length} abonnement${subscriptions.length > 1 ? 's' : ''}`
        : `Active tracking of ${subscriptions.length} subscription${subscriptions.length > 1 ? 's' : ''}`,
      colorClass: 'text-japandi-pine border-japandi-border bg-japandi-elevated',
      icon: <Activity className="w-4 h-4 text-japandi-pine flex-shrink-0" />
    };
  }, [subscriptions, totalMonthly, spendingGoal, locale, isAmountBlurred]);


  const [speechBubble, setSpeechBubble] = React.useState<string | null>(null);
  const isVibrant = profile.themeMode === 'vibrant';

  const pokeSparky = () => {
    const phrases = locale === 'fr' ? [
      "« Prêt à traquer les frais zombies ? 💸 »",
      "« Objectif en vue : continue comme ça ! 🚀 »",
      "« 18 jours de streak validés sous budget ! 👑 »",
      "« Chaque euro préservé est un pas vers ta liberté ! 🏖️ »"
    ] : [
      "« Ready to hunt down zombie fees? 💸 »",
      "« Financial freedom loading... keep it up! 🚀 »",
      "« 18-day streak under budget! 👑 »",
      "« Every euro saved is peace of mind! 🏖️ »"
    ];
    setSpeechBubble(phrases[Math.floor(Math.random() * phrases.length)] ?? null);
  };

  return (
    <div className="flex flex-col gap-2 pt-2 select-none">
      {isVibrant ? (
        <>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div
                onClick={pokeSparky}
                className="w-12 h-12 rounded-2xl bg-gradient-to-tr from-pink-500 to-amber-400 p-0.5 shadow-md cursor-pointer hover:scale-105 active:scale-95 transition-all flex-shrink-0"
                title="Clique pour motiver Sparky !"
              >
                <div className="w-full h-full bg-[#151226] rounded-[14px] flex items-center justify-center overflow-hidden">
                  <svg viewBox="0 0 100 100" className="w-10 h-10">
                    <circle cx="50" cy="52" r="38" fill="#FF4D79" />
                    <circle cx="38" cy="46" r="7" fill="#110A1A" />
                    <circle cx="62" cy="46" r="7" fill="#110A1A" />
                    <circle cx="40" cy="44" r="2.8" fill="#FFFFFF" />
                    <circle cx="64" cy="44" r="2.8" fill="#FFFFFF" />
                    <circle cx="28" cy="56" r="5" fill="#FF8DA9" opacity="0.8" />
                    <circle cx="72" cy="56" r="5" fill="#FF8DA9" opacity="0.8" />
                    <path d="M42,58 Q50,70 58,58 Z" fill="#110A1A" />
                    <rect x="47" y="58" width="6" height="4" rx="1" fill="#FFFFFF" />
                    <path d="M50,10 L52,18 L59,20 L53,24 L55,31 L50,26 L45,31 L47,24 L41,20 L48,18 Z" fill="#FFD166" />
                  </svg>
                </div>
              </div>

              <div>
                {isEditingName ? (
                  <form onSubmit={handleSaveInlineName} className="flex items-center gap-2">
                    <span className="text-xl font-bold text-white">{greetingTime},</span>
                    <input
                      type="text"
                      autoFocus
                      value={nameInput}
                      onChange={(e) => setNameInput(e.target.value)}
                      onBlur={() => handleSaveInlineName()}
                      className="px-2 py-0.5 rounded-lg bg-white/10 border border-teal-400 text-white text-xl font-extrabold focus:outline-none w-36"
                      maxLength={25}
                    />
                    <button
                      type="submit"
                      className="p-1 rounded-lg bg-teal-400 text-black hover:scale-105 transition-transform"
                      aria-label="Enregistrer"
                    >
                      <Check className="w-4 h-4 stroke-[3]" />
                    </button>
                  </form>
                ) : (
                  <div className="flex items-center gap-2 group">
                    <h1
                      onClick={() => setIsEditingName(true)}
                      className="text-2xl sm:text-3xl font-extrabold tracking-tight text-white font-sans cursor-pointer hover:text-teal-300 transition-colors"
                      style={{ lineHeight: 1.15, letterSpacing: '-0.6px' }}
                      title="Cliquer pour modifier votre prénom"
                    >
                      {greetingTitle}
                    </h1>
                    <button
                      type="button"
                      onClick={() => setIsEditingName(true)}
                      aria-label="Modifier mon prénom"
                      className="opacity-0 group-hover:opacity-100 p-1 rounded-md text-slate-400 hover:text-teal-300 hover:bg-white/10 transition-all"
                    >
                      <Pencil className="w-3.5 h-3.5" />
                    </button>
                  </div>
                )}
                <div className="flex items-center gap-1.5 mt-0.5">
                  <span className="text-[10px] font-extrabold text-amber-400">🔥 18j streak</span>
                  <span className="text-[10px] text-slate-400">• {subscriptions.length} abonnements</span>
                </div>
              </div>
            </div>
          </div>

          {speechBubble && (
            <div className="px-3.5 py-2 rounded-xl bg-amber-500/10 border border-amber-500/20 text-xs font-bold text-amber-300 animate-in fade-in">
              {speechBubble}
            </div>
          )}

          <div className="flex items-center mt-1">
            <div
              className={`inline-flex items-center gap-2 px-3.5 py-1.5 rounded-japandi-full border text-xs sm:text-sm font-semibold transition-all shadow-2xs ${insight.colorClass}`}
            >
              {insight.icon}
              <span>{insight.text}</span>
            </div>
          </div>
        </>
      ) : (
        <>
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

          <div className="flex items-center">
            <div
              className={`inline-flex items-center gap-2 px-3.5 py-1.5 rounded-japandi-full border text-xs sm:text-sm font-semibold transition-all shadow-2xs ${insight.colorClass}`}
            >
              {insight.icon}
              <span>{insight.text}</span>
            </div>
          </div>
        </>
      )}
    </div>
  );
};
