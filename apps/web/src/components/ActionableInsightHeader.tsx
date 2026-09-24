'use client';

import React, { useEffect, useMemo, useRef } from 'react';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useTranslation } from '../hooks/useTranslation';
import { calculateUpcomingOccurrences, calculateTotalMonthlyCost, pick } from '@subflow/core';
import { Pencil, Check, Bell, Clock, AlertTriangle, CheckCircle2, Activity } from 'lucide-react';

import { Tooltip } from '@subflow/ui';
import { UkoCompanion } from './uko/UkoCompanion';
import { ukoBus, type UkoState } from './uko/ukoBus';

export const ActionableInsightHeader: React.FC = () => {

  const { profile, updateProfile, subscriptions, isAmountBlurred } = useSubscriptionStore();
  const { t, format, locale } = useTranslation();

  const [isEditingName, setIsEditingName] = React.useState(false);
  const [nameInput, setNameInput] = React.useState(profile.name && profile.name !== 'Bienvenue' ? profile.name : '');

  const totalMonthly = useMemo(() => calculateTotalMonthlyCost(subscriptions), [subscriptions]);
  const spendingGoal = profile.spendingGoal ?? 0;

  // 1. Time-based respectful greeting localized
  const greetingTime = useMemo(() => {
    const hour = new Date().getHours();
    if (locale === 'fr') {
      if (hour >= 5 && hour < 18) return 'Bonjour';
      return 'Bonsoir';
    }
    if (locale === 'es') {
      if (hour >= 5 && hour < 12) return 'Buenos días';
      if (hour >= 12 && hour < 20) return 'Buenas tardes';
      return 'Buenas noches';
    }
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 18) return 'Good afternoon';
    return 'Good evening';
  }, [locale]);

  // The store's default profile name ("Bienvenue") is a placeholder, not a first name.
  const rawName = profile.name ? profile.name.trim() : '';
  const displayName = rawName !== '' && rawName !== 'Bienvenue' ? rawName : null;
  const greetingTitle = displayName ? `${greetingTime}, ${displayName}` : greetingTime;

  const handleSaveInlineName = (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    const finalName = nameInput.trim() || 'Bienvenue';
    updateProfile({ name: finalName });
    setNameInput(finalName === 'Bienvenue' ? '' : finalName);
    setIsEditingName(false);
  };

  const displayAmount = (amt: number) => isAmountBlurred ? '•••• €' : format(amt);

  // 2. Compute the most critical financial insight based on current real-time date
  const insight = useMemo(() => {
    const now = new Date();
    const occurrences = calculateUpcomingOccurrences(subscriptions, now, 60);
    const sortedUpcoming = occurrences.filter((occ) => occ.daysRemaining >= 0);


    // Case A: Imminent renewal (today or within 7 days)
    if (sortedUpcoming.length > 0 && sortedUpcoming[0]) {
      const nextOcc = sortedUpcoming[0];
      const subName = nextOcc.subscription.name;
      const subAmount = displayAmount(nextOcc.subscription.amount);

      if (nextOcc.daysRemaining === 0) {
        return {
          type: 'imminent',
          text: pick(locale, { fr: `Vous avez un prélèvement aujourd'hui pour ${subName} (${subAmount})`, en: `You have a payment due today for ${subName} (${subAmount})`, es: `Hoy tienes un cargo de ${subName} (${subAmount})` }),
          colorClass: 'text-japandi-terracotta border-japandi-terracotta/30 bg-japandi-terracotta/10',
          icon: <Bell className="w-4 h-4 flex-shrink-0 text-japandi-terracotta" />
        };
      }
      if (nextOcc.daysRemaining === 1) {
        return {
          type: 'imminent',
          text: pick(locale, { fr: `Vous avez un prélèvement demain pour ${subName} (${subAmount})`, en: `You have a payment due tomorrow for ${subName} (${subAmount})`, es: `Mañana tienes un cargo de ${subName} (${subAmount})` }),
          colorClass: 'text-japandi-terracotta border-japandi-terracotta/30 bg-japandi-sand/90',
          icon: <Clock className="w-4 h-4 flex-shrink-0 text-japandi-terracotta" />
        };
      }
      if (nextOcc.daysRemaining <= 3) {
        return {
          type: 'imminent',
          text: pick(locale, { fr: `Vous avez un prélèvement dans ${nextOcc.daysRemaining} jours pour ${subName} (${subAmount})`, en: `You have a payment in ${nextOcc.daysRemaining} days for ${subName} (${subAmount})`, es: `Tienes un cargo dentro de ${nextOcc.daysRemaining} días: ${subName} (${subAmount})` }),
          colorClass: 'text-japandi-terracotta border-japandi-terracotta/30 bg-japandi-sand/90',
          icon: <Clock className="w-4 h-4 flex-shrink-0 text-japandi-terracotta" />
        };
      }
      if (nextOcc.daysRemaining <= 7) {
        return {
          type: 'imminent',
          text: pick(locale, { fr: `Votre prochain prélèvement sera ${subName} (${subAmount}) dans ${nextOcc.daysRemaining} jours`, en: `Your next payment is ${subName} (${subAmount}) in ${nextOcc.daysRemaining} days`, es: `Tu próximo cargo es ${subName} (${subAmount}) dentro de ${nextOcc.daysRemaining} días` }),
          colorClass: 'text-japandi-pine border-japandi-border bg-japandi-elevated',
          icon: <Clock className="w-4 h-4 flex-shrink-0 text-japandi-pine" />
        };
      }
    }

    // Case B: Budget exceeded
    if (spendingGoal > 0 && totalMonthly > spendingGoal) {
      const overAmount = totalMonthly - spendingGoal;
      return {
        type: 'warning',
        text: pick(locale, { fr: `Attention, votre budget est dépassé de ${displayAmount(overAmount)} ce mois-ci`, en: `Heads up, you are ${displayAmount(overAmount)} over your monthly budget`, es: `Atención: superas tu presupuesto mensual en ${displayAmount(overAmount)}` }),
        colorClass: 'text-japandi-akane border-japandi-akane/30 bg-japandi-akane/10',
        icon: <AlertTriangle className="w-4 h-4 flex-shrink-0 text-japandi-akane" />
      };
    }

    // Case C: Budget on track
    if (spendingGoal > 0 && totalMonthly <= spendingGoal) {
      const buffer = spendingGoal - totalMonthly;
      return {
        type: 'healthy',
        text: pick(locale, { fr: `Bravo, il vous reste ${displayAmount(buffer)} sur votre budget ce mois-ci`, en: `Great job, you have ${displayAmount(buffer)} left in your budget this month`, es: `¡Bien hecho! Te quedan ${displayAmount(buffer)} de presupuesto este mes` }),
        colorClass: 'text-japandi-pine border-japandi-pine/30 bg-japandi-pine/10',
        icon: <CheckCircle2 className="w-4 h-4 flex-shrink-0 text-japandi-pine" />
      };
    }

    // Case D: General healthy summary
    if (subscriptions.length === 0) {
      return {
        type: 'neutral',
        text: pick(locale, { fr: 'Ajoutez vos premiers abonnements pour commencer votre suivi', en: 'Add your first subscriptions to start tracking', es: 'Añade tus primeras suscripciones para empezar' }),
        colorClass: 'text-japandi-pine border-japandi-border bg-japandi-elevated',
        icon: <Activity className="w-4 h-4 flex-shrink-0 text-japandi-pine" />
      };
    }

    return {
      type: 'neutral',
      text: pick(locale, { fr: 'Tout est calme : aucun prélèvement prévu dans les prochains jours', en: 'All clear: no payments due in the next few days', es: 'Todo en orden: ningún cargo en los próximos días' }),
      colorClass: 'text-japandi-pine border-japandi-border bg-japandi-elevated',
      icon: <Activity className="w-4 h-4 flex-shrink-0 text-japandi-pine" />
    };
  }, [subscriptions, totalMonthly, spendingGoal, locale, isAmountBlurred]);




  // Uko expresses the insight when it appears (see UkoCompanion): nothing yet → shrug,
  // payment imminent → thinking, budget exceeded → worried, on track → celebration,
  // all calm → its animated idle. It naps only after a while without activity.
  const ukoMood: UkoState = useMemo(() => {
    if (subscriptions.length === 0) return 'empty';
    if (insight.type === 'warning') return 'error';
    if (insight.type === 'healthy') return 'success';
    if (insight.type === 'imminent') return 'thinking';
    return 'idle';
  }, [insight.type, subscriptions.length]);

  // A payment is coming: Uko looks at the notice while it thinks about it.
  const pillRef = useRef<HTMLDivElement | null>(null);
  useEffect(() => {
    if (ukoMood !== 'thinking') return;
    const t = window.setTimeout(() => ukoBus.look(pillRef.current, 5000), 700);
    return () => window.clearTimeout(t);
  }, [ukoMood, insight.text]);

  return (
    <div className="flex items-start justify-between gap-3 pt-2 select-none">
    <div className="flex flex-col gap-2 min-w-0">
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
            aria-label={pick(locale, { fr: 'Enregistrer', en: 'Save', es: 'Guardar' })}
          >
            <Check className="w-4 h-4 stroke-[3]" />
          </button>
        </form>
      ) : (
        <div className="flex items-center gap-2 group">
          <Tooltip content={pick(locale, { fr: 'Cliquer pour modifier votre prénom', en: 'Click to edit your name', es: 'Haz clic para editar tu nombre' })} side="right">
            <h1
              onClick={() => setIsEditingName(true)}
              className="text-3xl sm:text-4xl font-extrabold tracking-tight text-japandi-text font-sans cursor-pointer hover:text-japandi-pine transition-colors"
              style={{ lineHeight: 1.15, letterSpacing: '-0.6px' }}
            >
              {greetingTitle}
            </h1>
          </Tooltip>
          <Tooltip content={pick(locale, { fr: 'Modifier', en: 'Edit', es: 'Editar' })} side="top">
            <button
              type="button"
              onClick={() => setIsEditingName(true)}
              aria-label={pick(locale, { fr: 'Modifier mon prénom', en: 'Edit my name', es: 'Editar mi nombre' })}
              className="opacity-0 group-hover:opacity-100 p-1.5 rounded-japandi-md text-japandi-muted hover:text-japandi-pine hover:bg-japandi-elevated transition-all"
            >
              <Pencil className="w-3.5 h-3.5" />
            </button>
          </Tooltip>
        </div>
      )}


      {/* Dynamic Actionable Insight Pill */}
      <div className="flex items-center">
        <div
          ref={pillRef}
          data-uko-look="insight"
          className={`inline-flex items-center gap-2 px-3.5 py-1.5 rounded-japandi-full border text-xs sm:text-sm font-semibold transition-all shadow-2xs ${insight.colorClass}`}
        >
          {insight.icon}
          <span>{insight.text}</span>
        </div>
      </div>
    </div>
    <UkoCompanion
      mood={ukoMood}
      className="shrink-0 w-[84px] h-[122px] sm:w-[108px] sm:h-[156px] -mt-1 -mb-3"
      label={pick(locale, { fr: 'Uko, votre compagnon SubFlow', en: 'Uko, your SubFlow companion', es: 'Uko, tu compañero SubFlow' })}
    />
    </div>
  );
};

