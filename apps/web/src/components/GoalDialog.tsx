'use client';

import React, { useState, useEffect, useId } from 'react';
import { X, SlidersHorizontal, Sparkles, Check, AlertCircle } from 'lucide-react';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useTranslation } from '../hooks/useTranslation';
import { useEscapeKey } from '../hooks/useEscapeKey';

interface GoalDialogProps {
  isOpen: boolean;
  onClose: () => void;
  currentCost: number;
}

export const GoalDialog: React.FC<GoalDialogProps> = ({
  isOpen,
  onClose,
  currentCost
}) => {
  const { profile, setMonthlySpendLimit } = useSubscriptionStore();
  const { t } = useTranslation();
  const titleId = useId();

  // Keyboard accessibility: Escape key listener
  useEscapeKey(isOpen, onClose);

  const [goalInput, setGoalInput] = useState<string>('');

  useEffect(() => {
    if (isOpen) {
      if (profile.monthlySpendLimit && profile.monthlySpendLimit > 0) {
        setGoalInput(profile.monthlySpendLimit.toString());
      } else {
        const defaultVal = currentCost > 0 ? Math.round(currentCost) : 50;
        setGoalInput(defaultVal.toString());
      }
    }
  }, [isOpen, profile.monthlySpendLimit, currentCost]);

  if (!isOpen) return null;

  const symbol = profile.currencySymbol || '€';

  // Calculate smart presets based on current spending
  const presets: number[] = [];
  if (currentCost > 0) {
    presets.push(Math.round(currentCost * 0.8)); // -20%
    presets.push(Math.round(currentCost)); // Match current
    presets.push(Math.round(currentCost * 1.2)); // +20% buffer
  } else {
    presets.push(30, 50, 100);
  }

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    const val = parseFloat(goalInput.replace(',', '.').trim());
    if (!isNaN(val) && val >= 0) {
      setMonthlySpendLimit(val);
    }
    onClose();
  };

  const handleClear = () => {
    setMonthlySpendLimit(null);
    onClose();
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4 bg-black/50 backdrop-blur-sm animate-in fade-in duration-200"
      onClick={onClose}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        className="w-full max-w-md rounded-t-japandi-2xl sm:rounded-japandi-xl bg-japandi-surface border border-japandi-border shadow-japandi-lg overflow-hidden flex flex-col p-6 animate-in slide-in-from-bottom-4 duration-200 select-none"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Japandi Drag Handle */}
        <div className="w-10 h-1 bg-japandi-border rounded-full mx-auto mb-4 sm:hidden" />

        {/* Header */}
        <div className="flex items-center justify-between mb-2">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-japandi-md bg-japandi-pine/15 text-japandi-pine flex items-center justify-center">
              <SlidersHorizontal className="w-4 h-4" />
            </div>
            <h3 id={titleId} className="text-lg font-bold text-japandi-text tracking-tight">
              {t('home.monthlyTarget')}
            </h3>
          </div>
          <button
            type="button"
            aria-label={t('common.close')}
            onClick={onClose}
            className="p-1.5 rounded-japandi-md text-japandi-muted hover:text-japandi-text hover:bg-japandi-sand/40 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <p className="text-xs text-japandi-muted mb-6">
          {t('settings.monthlyTargetLimit')}
        </p>

        {/* Input Form */}
        <form onSubmit={handleSave} className="flex flex-col gap-6">
          {/* Main Numeric Input */}
          <div className="relative flex items-center justify-center bg-japandi-elevated border border-japandi-border rounded-japandi-xl p-4 focus-within:border-japandi-pine focus-within:ring-2 focus-within:ring-japandi-pine/20 transition-all">
            <span className="text-3xl font-bold text-japandi-pine/50 mr-2 select-none">
              {symbol}
            </span>
            <input
              type="text"
              autoFocus
              inputMode="decimal"
              aria-label={t('home.monthlyTarget')}
              value={goalInput}
              onChange={(e) => setGoalInput(e.target.value)}
              className="bg-transparent text-3xl font-extrabold text-japandi-pine text-center w-36 focus:outline-none tracking-tight"
              placeholder="50"
            />
            <span className="text-sm font-semibold text-japandi-muted ml-2 select-none">
              {t('cycles.perMonth')}
            </span>
          </div>

          {/* Quick Preset Chips */}
          <div className="flex items-center justify-center gap-2 flex-wrap">
            {presets.map((p, idx) => (
              <button
                key={`preset-${p}-${idx}`}
                type="button"
                onClick={() => setGoalInput(p.toString())}
                className="px-3.5 py-1.5 rounded-japandi-full bg-japandi-surface border border-japandi-border text-xs font-bold text-japandi-text hover:border-japandi-pine hover:bg-japandi-sand/40 transition-all shadow-xs"
              >
                {symbol}{p}{t('cycles.perMonth')}
              </button>
            ))}
          </div>

          {/* Action Buttons: Clear & Set Target */}
          <div className="flex items-center gap-3 mt-2">
            {profile.monthlySpendLimit && (
              <button
                type="button"
                onClick={handleClear}
                className="flex-1 py-3 px-4 rounded-japandi-md border border-japandi-terracotta/40 text-japandi-terracotta font-bold text-sm hover:bg-japandi-terracotta/10 transition-colors"
              >
                {t('common.cancel')}
              </button>
            )}
            <button
              type="submit"
              className="flex-[2] py-3.5 px-4 rounded-japandi-md bg-japandi-pine text-white font-bold text-sm hover:opacity-90 transition-all shadow-japandi-sm"
            >
              {t('common.save')}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
