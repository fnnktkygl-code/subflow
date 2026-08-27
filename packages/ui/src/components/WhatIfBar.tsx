'use client';

import React, { useState } from 'react';
import { WhatIfSavings } from '@subflow/core';
import { X, Sparkles, MinusCircle, TrendingDown, PiggyBank, CheckCircle2, AlignJustify, ChevronUp, ChevronDown } from 'lucide-react';
import { Tooltip } from './Tooltip';


export interface WhatIfBarProps {
  savings: WhatIfSavings;
  currencySymbol?: string;
  onSelectAll?: () => void;
  onClearAll: () => void;
  onExit: () => void;
}

export const WhatIfBar: React.FC<WhatIfBarProps> = ({
  savings,
  currencySymbol = '€',
  onSelectAll,
  onClearAll,
  onExit
}) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const progressRatio = savings.totalCount > 0 ? Math.min(savings.excludedCount / savings.totalCount, 1) : 0;

  return (
    <div className="w-full max-w-xl mx-auto rounded-japandi-xl border border-japandi-border bg-japandi-surface/98 backdrop-blur-xl shadow-japandi-lg p-3 sm:p-4 flex flex-col gap-3 transition-all duration-300 select-none">
      {/* Collapsed Compact Mini-Bar */}
      {!isExpanded ? (
        <div className="flex items-center justify-between gap-2">
          {/* Left: Indicator & Quick Savings */}
          <button
            type="button"
            onClick={() => setIsExpanded(true)}
            className="flex items-center gap-2.5 text-left flex-1 min-w-0 hover:opacity-80 transition-opacity"
          >
            <div className="w-7 h-7 rounded-japandi-sm bg-japandi-sand/80 flex-shrink-0 flex items-center justify-center text-japandi-text shadow-2xs">
              <Sparkles className="w-4 h-4 text-japandi-pine" />
            </div>
            <div className="min-w-0">
              <div className="flex items-center gap-1.5 font-bold text-xs text-japandi-text truncate">
                <span>{savings.excludedCount}/{savings.totalCount} excluded</span>
                <span className="text-japandi-muted">•</span>
                <span className="text-japandi-terracotta">Saves {currencySymbol}{savings.monthlySavings.toFixed(0)}/mo</span>
              </div>
              <p className="text-[10px] text-japandi-muted font-medium">Tap cards to exclude</p>
            </div>
          </button>

          {/* Right: Expand & Exit buttons */}
          <div className="flex items-center gap-1.5 flex-shrink-0">
            <button
              type="button"
              onClick={() => setIsExpanded(true)}
              className="flex items-center gap-1 px-2.5 py-1.5 rounded-japandi-md bg-japandi-elevated border border-japandi-border text-[11px] font-bold text-japandi-text hover:bg-japandi-sand transition-colors"
            >
              <span>Details</span>
              <ChevronUp className="w-3.5 h-3.5 text-japandi-muted" />
            </button>

            <Tooltip content="Quitter le mode Simulation" side="top">
              <button
                type="button"
                onClick={onExit}
                className="p-1.5 rounded-japandi-md text-japandi-muted hover:text-japandi-text hover:bg-japandi-sand transition-colors"
                aria-label="Exit What If Mode"
              >
                <X className="w-4 h-4" />
              </button>
            </Tooltip>
          </div>
        </div>
      ) : (
        /* Expanded Full Drawer */
        <div className="flex flex-col gap-3 animate-in fade-in duration-200">
          {/* Header */}
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2.5">
              <div className="w-7 h-7 rounded-japandi-sm bg-japandi-sand/80 flex items-center justify-center text-japandi-text">
                <Sparkles className="w-4 h-4 text-japandi-pine" />
              </div>
              <div>
                <h4 className="font-bold text-sm text-japandi-text tracking-tight">What If Mode</h4>
                <p className="text-[11px] text-japandi-muted">Tap cards to exclude</p>
              </div>
            </div>

            <div className="flex items-center gap-1">
              <Tooltip content="Réduire" side="top">
                <button
                  type="button"
                  onClick={() => setIsExpanded(false)}
                  className="p-1.5 rounded-japandi-sm text-japandi-muted hover:text-japandi-text hover:bg-japandi-sand/40 transition-colors"
                  aria-label="Collapse details"
                >
                  <ChevronDown className="w-4 h-4" />
                </button>
              </Tooltip>
              <Tooltip content="Quitter le mode Simulation" side="top">
                <button
                  type="button"
                  onClick={onExit}
                  className="p-1.5 rounded-japandi-sm text-japandi-muted hover:text-japandi-text hover:bg-japandi-sand/40 transition-colors"
                  aria-label="Exit What If Mode"
                >
                  <X className="w-4 h-4" />
                </button>
              </Tooltip>
            </div>
          </div>


          {/* Center Metric Box */}
          <div className="p-3.5 rounded-japandi-lg bg-japandi-elevated border border-japandi-border flex flex-col gap-2.5">
            <div className="grid grid-cols-3 divide-x divide-japandi-border/60">
              {/* Excluded */}
              <div className="flex flex-col items-center justify-center text-center px-1">
                <div className="text-japandi-akane mb-1">
                  <MinusCircle className="w-4 h-4" />
                </div>
                <span className="font-extrabold text-base text-japandi-akane tracking-tight">
                  {savings.excludedCount} / {savings.totalCount}
                </span>
                <span className="text-[9px] font-bold uppercase tracking-wider text-japandi-muted mt-0.5">
                  EXCLUDED
                </span>
              </div>

              {/* Monthly Savings */}
              <div className="flex flex-col items-center justify-center text-center px-1">
                <div className="text-japandi-slate mb-1">
                  <TrendingDown className="w-4 h-4" />
                </div>
                <span className="font-extrabold text-base text-japandi-slate tracking-tight">
                  {currencySymbol}{savings.monthlySavings.toFixed(0)}
                </span>
                <span className="text-[9px] font-bold uppercase tracking-wider text-japandi-muted mt-0.5">
                  MONTHLY SAVINGS
                </span>
              </div>

              {/* Yearly Savings */}
              <div className="flex flex-col items-center justify-center text-center px-1">
                <div className="text-japandi-terracotta mb-1">
                  <PiggyBank className="w-4 h-4" />
                </div>
                <span className="font-extrabold text-base text-japandi-terracotta tracking-tight">
                  {currencySymbol}{savings.yearlySavings.toFixed(0)}
                </span>
                <span className="text-[9px] font-bold uppercase tracking-wider text-japandi-muted mt-0.5">
                  YEARLY SAVINGS
                </span>
              </div>
            </div>

            {/* Red / Terracotta Progress bar */}
            <div className="w-full h-1.5 rounded-full bg-japandi-sand overflow-hidden">
              <div
                className="h-full bg-japandi-akane rounded-full transition-all duration-300"
                style={{ width: `${progressRatio * 100}%` }}
              />
            </div>
          </div>

          {/* Action Buttons: Select All & Clear All */}
          <div className="grid grid-cols-2 gap-2.5">
            <button
              type="button"
              onClick={onSelectAll}
              className="py-2.5 px-3 rounded-japandi-md bg-japandi-elevated border border-japandi-border text-japandi-text font-bold text-xs hover:border-japandi-border-strong transition-all flex items-center justify-center gap-2 shadow-xs"
            >
              <CheckCircle2 className="w-3.5 h-3.5 text-japandi-pine" />
              <span>Select All</span>
            </button>

            <button
              type="button"
              onClick={onClearAll}
              className="py-2.5 px-3 rounded-japandi-md bg-japandi-elevated border border-japandi-border text-japandi-text font-bold text-xs hover:border-japandi-border-strong transition-all flex items-center justify-center gap-2 shadow-xs"
            >
              <AlignJustify className="w-3.5 h-3.5 text-japandi-muted" />
              <span>Clear All</span>
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
