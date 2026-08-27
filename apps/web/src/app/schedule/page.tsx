'use client';

import React, { useState, useMemo, useRef } from 'react';
import { useSubscriptionStore } from '../../store/useSubscriptionStore';
import { useTranslation } from '../../hooks/useTranslation';
import { calculateTotalMonthlyCost, Subscription } from '@subflow/core';
import { SubscriptionLogo } from '@subflow/ui';
import { ChevronLeft, ChevronRight, Eye, EyeOff, Receipt, Plus, Sparkles } from 'lucide-react';
import { AddSubscriptionModal } from '../../components/AddSubscriptionModal';
import { CalendarActionsDrawer } from '../../components/CalendarActionsDrawer';

export default function SchedulePage() {
  const { subscriptions, profile, isAmountBlurred, toggleAmountBlur, deleteSubscription } = useSubscriptionStore();
  const { t, format, locale } = useTranslation();

  const [currentMonthDate, setCurrentMonthDate] = useState(() => new Date(2026, 7, 1)); // August 2026
  const [selectedDay, setSelectedDay] = useState<number>(27);

  // Modals & Drawers
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [addModalDefaultDate, setAddModalDefaultDate] = useState<string | null>(null);
  const [editingSub, setEditingSub] = useState<Subscription | null>(null);

  // Calendar Long Press Action Drawer State
  const [actionsDrawerDate, setActionsDrawerDate] = useState<Date | null>(null);
  const [isActionsDrawerOpen, setIsActionsDrawerOpen] = useState(false);

  const longPressTimerRef = useRef<NodeJS.Timeout | null>(null);
  const isLongPressTriggeredRef = useRef(false);

  const year = currentMonthDate.getFullYear();
  const month = currentMonthDate.getMonth();

  const monthLabel = useMemo(() => {
    return currentMonthDate.toLocaleString(locale === 'fr' ? 'fr-FR' : 'en-US', {
      month: 'long',
      year: 'numeric'
    });
  }, [currentMonthDate, locale]);

  const weekDayNames = useMemo(() => {
    return locale === 'fr'
      ? ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']
      : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  }, [locale]);

  const renewalsByDay = useMemo(() => {
    const map: Record<number, Subscription[]> = {};
    subscriptions.forEach((sub) => {
      const date = new Date(sub.startDate);
      const day = date.getDate();
      if (!map[day]) map[day] = [];
      map[day].push(sub);
    });
    return map;
  }, [subscriptions]);

  const daysInMonth = new Date(year, month + 1, 0).getDate();
  const firstDayIndex = (new Date(year, month, 1).getDay() + 6) % 7; // Monday = 0

  const totalMonthlyCost = useMemo(
    () => calculateTotalMonthlyCost(subscriptions),
    [subscriptions]
  );

  const selectedDaySubs = renewalsByDay[selectedDay] || [];

  const handlePrevMonth = () => {
    setCurrentMonthDate(new Date(year, month - 1, 1));
  };

  const handleNextMonth = () => {
    setCurrentMonthDate(new Date(year, month + 1, 1));
  };

  const handleOpenAddOnDay = (day: number) => {
    const formatted = `${year}-${String(month + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
    setAddModalDefaultDate(formatted);
    setIsAddModalOpen(true);
  };

  const handleDayTouchStart = (day: number) => {
    isLongPressTriggeredRef.current = false;
    longPressTimerRef.current = setTimeout(() => {
      isLongPressTriggeredRef.current = true;
      const targetDate = new Date(year, month, day);
      setActionsDrawerDate(targetDate);
      setIsActionsDrawerOpen(true);
    }, 600);
  };

  const handleDayTouchEnd = (day: number) => {
    if (longPressTimerRef.current) {
      clearTimeout(longPressTimerRef.current);
      longPressTimerRef.current = null;
    }
    if (!isLongPressTriggeredRef.current) {
      setSelectedDay(day);
    }
  };

  return (
    <div className="flex flex-col gap-6 animate-in fade-in duration-300 max-w-5xl mx-auto">
      {/* 1. Header with Monthly Overview */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold text-japandi-text tracking-tight">
            {t('schedule.title')}
          </h1>
          <p className="text-xs text-japandi-muted">
            {t('schedule.subtitle')}
          </p>
        </div>

        {/* Monthly Total Pill */}
        <div className="flex items-center gap-3 bg-japandi-surface border border-japandi-border rounded-japandi-xl p-3 shadow-japandi-sm self-start sm:self-auto">
          <div className="w-8 h-8 rounded-japandi-full bg-japandi-pine/10 flex items-center justify-center text-japandi-pine">
            <Receipt className="w-4 h-4" />
          </div>
          <div className="flex flex-col">
            <span className="text-[10px] uppercase font-semibold tracking-wider text-japandi-muted">
              {t('schedule.monthlyTotal')}
            </span>
            <span className={`text-base font-extrabold text-japandi-text ${isAmountBlurred ? 'blur-xs select-none' : ''}`}>
              {format(totalMonthlyCost)}
            </span>
          </div>
        </div>
      </div>

      {/* 2. Responsive 2-Column Layout for Desktop */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        {/* Left Column: Interactive Month Calendar */}
        <div className="lg:col-span-7 rounded-japandi-2xl bg-japandi-surface border border-japandi-border p-5 sm:p-6 shadow-japandi-sm flex flex-col gap-5">
          {/* Calendar Header: Month Name + Prev/Next Arrows */}
          <div className="flex items-center justify-between">
            <h2 className="text-base font-extrabold capitalize text-japandi-text">
              {monthLabel}
            </h2>
            <div className="flex items-center gap-1">
              <button
                type="button"
                aria-label="Previous month"
                onClick={handlePrevMonth}
                className="p-1.5 rounded-japandi-md text-japandi-muted hover:text-japandi-text hover:bg-japandi-elevated transition-colors"
              >
                <ChevronLeft className="w-4 h-4" />
              </button>
              <button
                type="button"
                aria-label="Next month"
                onClick={handleNextMonth}
                className="p-1.5 rounded-japandi-md text-japandi-muted hover:text-japandi-text hover:bg-japandi-elevated transition-colors"
              >
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>

          {/* Days of Week Header */}
          <div className="grid grid-cols-7 gap-1 text-center">
            {weekDayNames.map((d, i) => (
              <span key={i} className="text-[11px] font-bold text-japandi-muted uppercase tracking-wider py-1">
                {d}
              </span>
            ))}
          </div>

          {/* Days Grid with Soft Rounded Containers */}
          <div className="grid grid-cols-7 gap-1.5">
            {/* Empty Offset Days */}
            {Array.from({ length: firstDayIndex }).map((_, i) => (
              <div key={`empty-${i}`} className="h-14 sm:h-16 rounded-japandi-xl bg-transparent" />
            ))}

            {/* Actual Days in Month */}
            {Array.from({ length: daysInMonth }).map((_, i) => {
              const dayNum = i + 1;
              const isSelected = selectedDay === dayNum;
              const subsOnDay = renewalsByDay[dayNum] || [];
              const hasSubs = subsOnDay.length > 0;
              const isToday = dayNum === 27 && month === 7 && year === 2026;

              return (
                <div
                  key={`day-${dayNum}`}
                  role="button"
                  tabIndex={0}
                  aria-selected={isSelected}
                  aria-label={`${dayNum} ${monthLabel}, ${subsOnDay.length} subscriptions`}
                  onClick={() => setSelectedDay(dayNum)}
                  onTouchStart={() => handleDayTouchStart(dayNum)}
                  onTouchEnd={() => handleDayTouchEnd(dayNum)}
                  onContextMenu={(e) => {
                    e.preventDefault();
                    setActionsDrawerDate(new Date(year, month, dayNum));
                    setIsActionsDrawerOpen(true);
                  }}
                  className={`h-14 sm:h-16 rounded-japandi-xl border transition-all p-1.5 flex flex-col justify-between select-none cursor-pointer focus:outline-none focus:ring-2 focus:ring-japandi-pine ${
                    isSelected
                      ? 'bg-japandi-pine text-white border-japandi-pine shadow-japandi-sm'
                      : isToday
                      ? 'bg-japandi-sand/60 border-japandi-pine/40 text-japandi-text'
                      : 'bg-japandi-elevated border-japandi-border hover:border-japandi-border-strong text-japandi-text'
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <span className={`text-xs font-bold ${isSelected ? 'text-white' : 'text-japandi-text'}`}>
                      {dayNum}
                    </span>
                    {hasSubs && (
                      <span className={`w-2 h-2 rounded-full ${isSelected ? 'bg-white' : 'bg-japandi-terracotta animate-pulse'}`} />
                    )}
                  </div>

                  {/* Micro Logo Avatars on Day */}
                  {hasSubs && (
                    <div className="flex items-center -space-x-1 overflow-hidden">
                      {subsOnDay.slice(0, 2).map((s) => (
                        <div
                          key={s.id}
                          className="w-4 h-4 rounded-full border border-japandi-surface bg-white flex items-center justify-center overflow-hidden"
                        >
                          <SubscriptionLogo name={s.name} logoUrl={s.logoUrl} category={s.category} size={16} />
                        </div>
                      ))}
                      {subsOnDay.length > 2 && (
                        <span className={`text-[9px] font-extrabold pl-1.5 ${isSelected ? 'text-white' : 'text-japandi-muted'}`}>
                          +{subsOnDay.length - 2}
                        </span>
                      )}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {/* Right Column: Selected Day Detail List */}
        <div className="lg:col-span-5 rounded-japandi-2xl bg-japandi-surface border border-japandi-border p-5 sm:p-6 shadow-japandi-sm flex flex-col gap-4">
          <div className="flex items-center justify-between border-b border-japandi-border pb-3">
            <div>
              <h3 className="text-sm font-extrabold text-japandi-text">
                {t('schedule.renewalsOn', { date: `${selectedDay} ${monthLabel}` })}
              </h3>
              <span className="text-xs text-japandi-muted">
                {selectedDaySubs.length} service{selectedDaySubs.length > 1 ? 's' : ''}
              </span>
            </div>

            <button
              type="button"
              onClick={() => handleOpenAddOnDay(selectedDay)}
              className="p-1.5 rounded-japandi-md bg-japandi-pine text-white hover:bg-japandi-pine/90 transition-colors shadow-2xs"
              aria-label={t('modal.addTitle')}
            >
              <Plus className="w-4 h-4" />
            </button>
          </div>

          {/* Subscriptions List on Selected Day */}
          {selectedDaySubs.length === 0 ? (
            <div className="py-12 text-center text-xs text-japandi-muted flex flex-col items-center gap-3">
              <span>{t('schedule.noRenewalsOnDate')}</span>
              <button
                type="button"
                onClick={() => handleOpenAddOnDay(selectedDay)}
                className="text-xs font-bold text-japandi-pine hover:underline flex items-center gap-1"
              >
                <Plus className="w-3.5 h-3.5" />
                <span>{t('modal.addTitle')}</span>
              </button>
            </div>
          ) : (
            <div className="flex flex-col gap-2.5">
              {selectedDaySubs.map((sub) => (
                <div
                  key={sub.id}
                  onClick={() => {
                    setEditingSub(sub);
                    setIsAddModalOpen(true);
                  }}
                  className="p-3 rounded-japandi-xl bg-japandi-elevated border border-japandi-border hover:border-japandi-pine flex items-center justify-between cursor-pointer transition-all shadow-2xs"
                >
                  <div className="flex items-center gap-3 min-w-0">
                    <SubscriptionLogo name={sub.name} logoUrl={sub.logoUrl} category={sub.category} size={36} />
                    <div className="min-w-0">
                      <h4 className="font-bold text-xs text-japandi-text truncate">{sub.name}</h4>
                      <span className="text-[10px] text-japandi-muted">
                        {t(`categories.${sub.category}` as any) || sub.category} • {t(`cycles.${sub.cycle}` as any) || sub.cycle}
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
      </div>

      {/* Add / Edit Subscription Modal */}
      {isAddModalOpen && (
        <AddSubscriptionModal
          isOpen={isAddModalOpen}
          onClose={() => {
            setIsAddModalOpen(false);
            setEditingSub(null);
          }}
          defaultDate={addModalDefaultDate || undefined}
          editSubscription={editingSub}
        />
      )}

      {/* Context Actions Drawer for Long-Press / Right-Click */}
      {isActionsDrawerOpen && actionsDrawerDate && (
        <CalendarActionsDrawer
          isOpen={isActionsDrawerOpen}
          onClose={() => setIsActionsDrawerOpen(false)}
          date={actionsDrawerDate}
          subscriptionsForDay={renewalsByDay[actionsDrawerDate.getDate()] || []}
          onAdd={(dateStr) => {
            setIsActionsDrawerOpen(false);
            setAddModalDefaultDate(dateStr);
            setIsAddModalOpen(true);
          }}
          onEdit={(sub) => {
            setIsActionsDrawerOpen(false);
            setEditingSub(sub);
            setIsAddModalOpen(true);
          }}
          onDelete={(subId) => {
            deleteSubscription(subId);
            setIsActionsDrawerOpen(false);
          }}
          currencySymbol={profile.currencySymbol}
        />
      )}
    </div>
  );
}
