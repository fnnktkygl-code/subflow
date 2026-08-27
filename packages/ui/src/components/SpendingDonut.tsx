'use client';

import React from 'react';
import { SubscriptionCategory, Subscription, formatCurrency } from '@subflow/core';
import { X } from 'lucide-react';

export interface SpendingDonutProps {
  categories: Record<string, { total: number; percentage: number; count: number; subscriptions?: Subscription[] }>;
  totalMonthlyAmount: number;
  currencySymbol?: string;
  selectedCategory?: SubscriptionCategory | string | null;
  onSelectCategory?: (category: SubscriptionCategory | null) => void;
  categorySubscriptions?: Subscription[];
  isAmountBlurred?: boolean;
  themeMode?: string;
}

export const VIBRANT_CATEGORY_COLORS: Record<string, string> = {
  Entertainment: '#FF2A6D', // Neon Punch Pink
  Productivity: '#8B5CF6', // Vivid Electric Violet
  Utilities: '#F59E0B', // Cyber Amber
  'Health & Fitness': '#10B981', // Bright Emerald Mint
  'Food & Dining': '#F97316', // Tangy Orange
  Shopping: '#06B6D4', // Electric Cyan
  General: '#EC4899' // Pop Berry
};

export const BARBIE_CATEGORY_COLORS: Record<string, string> = {
  Entertainment: '#EC4899', // Hot Pink
  Productivity: '#8B5CF6', // Purple Pop
  Utilities: '#F43F5E', // Rose Red
  'Health & Fitness': '#FB7185', // Strawberry
  'Food & Dining': '#F472B6', // Light Bubblegum
  Shopping: '#DB2777', // Deep Fuchsia
  General: '#BE123C' // Ruby Pink
};

export const JAPANDI_CATEGORY_COLORS: Record<string, string> = {
  Entertainment: '#B87D56', // Terracotta Clay
  Productivity: '#3B4D3C', // Kuro-Matsu Pine
  Utilities: '#C4823F', // Yuzu Amber
  'Health & Fitness': '#477A56', // Matcha Green
  'Food & Dining': '#C49A6C', // Hinoki Warm Ochre
  Shopping: '#8C7355', // Sandalwood
  General: '#8C867A' // Tatami Ash
};

export function getCategoryHexColor(cat: string, themeMode?: string): string {
  if (themeMode === 'vibrant') {
    return VIBRANT_CATEGORY_COLORS[cat] || '#8B5CF6';
  }
  if (themeMode === 'barbie') {
    return BARBIE_CATEGORY_COLORS[cat] || '#EC4899';
  }
  return JAPANDI_CATEGORY_COLORS[cat] || '#8C867A';
}


function renderCategorySvg(cat: string) {
  const norm = cat.toLowerCase().trim();
  if (norm.includes('entertain') || norm.includes('stream') || norm.includes('music')) {
    return (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-3.5 h-3.5">
        <rect x="2" y="2" width="20" height="20" rx="2.18" ry="2.18" />
        <line x1="7" y1="2" x2="7" y2="22" />
        <line x1="17" y1="2" x2="17" y2="22" />
        <line x1="2" y1="12" x2="22" y2="12" />
        <line x1="2" y1="7" x2="7" y2="7" />
        <line x1="17" y1="17" x2="22" y2="17" />
      </svg>
    );
  }
  if (norm.includes('product') || norm.includes('work') || norm.includes('dev') || norm.includes('ai')) {
    return (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-3.5 h-3.5">
        <rect x="2" y="3" width="20" height="14" rx="2" ry="2" />
        <line x1="8" y1="21" x2="16" y2="21" />
        <line x1="12" y1="17" x2="12" y2="21" />
      </svg>
    );
  }
  if (norm.includes('util') || norm.includes('cloud') || norm.includes('mobile') || norm.includes('telecom')) {
    return (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-3.5 h-3.5">
        <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" />
      </svg>
    );
  }
  if (norm.includes('health') || norm.includes('fit') || norm.includes('gym') || norm.includes('sport')) {
    return (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-3.5 h-3.5">
        <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
      </svg>
    );
  }
  if (norm.includes('food') || norm.includes('din') || norm.includes('eat') || norm.includes('deliver')) {
    return (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-3.5 h-3.5">
        <path d="M18 8h1a4 4 0 0 1 0 8h-1" />
        <path d="M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8z" />
      </svg>
    );
  }
  if (norm.includes('shop') || norm.includes('store') || norm.includes('cloth')) {
    return (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-3.5 h-3.5">
        <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z" />
        <line x1="3" y1="6" x2="21" y2="6" />
      </svg>
    );
  }
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-3.5 h-3.5">
      <polygon points="12 2 2 7 12 12 22 7 12 2" />
      <polyline points="2 17 12 22 22 17" />
      <polyline points="2 12 12 17 22 12" />
    </svg>
  );
}

export const SpendingDonut: React.FC<SpendingDonutProps> = ({
  categories,
  totalMonthlyAmount,
  currencySymbol = '€',
  selectedCategory,
  onSelectCategory,
  categorySubscriptions = [],
  isAmountBlurred = false,
  themeMode
}) => {

  const entries = Object.entries(categories);
  const sorted = entries.sort((a, b) => b[1].total - a[1].total);

  let cumulativeAngle = 0;
  const radius = 72;
  const circumference = 2 * Math.PI * radius;

  const selectedData = selectedCategory && categories[selectedCategory] ? categories[selectedCategory] : null;

  return (
    <div className="flex flex-col gap-4 w-full">
      {/* Reset Chip (matches Flutter screenshot 1) */}
      {selectedCategory && (
        <div className="flex items-center justify-start animate-in fade-in duration-150">
          <button
            type="button"
            onClick={() => onSelectCategory?.(null)}
            className="flex items-center gap-1.5 px-2.5 py-1 rounded-japandi-full bg-japandi-sand/80 border border-japandi-border text-xs font-bold text-japandi-text hover:bg-japandi-sand transition-colors shadow-xs"
          >
            <span>Reset</span>
            <X className="w-3.5 h-3.5" />
          </button>
        </div>
      )}

      {/* Donut Chart Container */}
      <div className="relative w-56 h-56 mx-auto flex items-center justify-center">
        <svg className="w-full h-full transform -rotate-90" viewBox="0 0 200 200">
          <circle
            cx="100"
            cy="100"
            r={radius}
            fill="transparent"
            stroke="rgba(0,0,0,0.04)"
            strokeWidth="24"
          />

          {sorted.map(([cat, data]) => {
            const strokeDasharray = `${(data.percentage / 100) * circumference} ${circumference}`;
            const strokeDashoffset = -cumulativeAngle;
            cumulativeAngle += (data.percentage / 100) * circumference;

            const isSelected = selectedCategory === cat;
            const isDimmed = selectedCategory && !isSelected;
            const catColor = getCategoryHexColor(cat, themeMode);

            return (
              <circle
                key={cat}
                cx="100"
                cy="100"
                r={radius}
                fill="transparent"
                stroke={catColor}
                strokeWidth={isSelected ? '28' : '24'}
                strokeDasharray={strokeDasharray}
                strokeDashoffset={strokeDashoffset}
                className="transition-all duration-300 cursor-pointer"
                style={{ opacity: isDimmed ? 0.25 : 1 }}
                onClick={() => onSelectCategory?.(isSelected ? null : (cat as SubscriptionCategory))}
              />
            );
          })}
        </svg>

        {/* Center Content: Either Selected Category Card or Total */}
        {selectedCategory && selectedData ? (
          /* Selected Category Center Card matching Flutter screenshot 1 */
          <div className="absolute z-10 w-32 py-2.5 px-2 rounded-japandi-lg bg-japandi-surface border border-japandi-border shadow-japandi-md flex flex-col items-center justify-center text-center animate-in zoom-in-95 duration-150 select-none pointer-events-none">
            <div className="flex items-center gap-1.5 mb-0.5">
              <div
                className="w-5 h-5 rounded-japandi-sm flex items-center justify-center p-0.5 shadow-2xs"
                style={{
                  backgroundColor: `${getCategoryHexColor(selectedCategory, themeMode)}25`,
                  color: getCategoryHexColor(selectedCategory, themeMode)
                }}
              >
                {renderCategorySvg(selectedCategory)}
              </div>
              <span className="text-[11px] font-bold text-japandi-text truncate max-w-[75px]">
                {selectedCategory}
              </span>
            </div>


            <span className={`text-base font-extrabold text-japandi-text tracking-tight ${isAmountBlurred ? 'privacy-blur' : ''}`}>
              {currencySymbol}{selectedData.total.toFixed(2)}
            </span>
            <span className="text-[10px] font-medium text-japandi-muted">
              {selectedData.percentage.toFixed(1)}% of total
            </span>
          </div>
        ) : (
          /* Default Center Total */
          <div className="absolute flex flex-col items-center justify-center text-center select-none pointer-events-none">
            <span className="text-[10px] uppercase font-bold text-japandi-muted tracking-wider">
              TOTAL / MONTH
            </span>
            <span className={`text-2xl font-extrabold text-japandi-text tracking-tight ${isAmountBlurred ? 'privacy-blur' : ''}`}>
              {currencySymbol}{totalMonthlyAmount.toFixed(2)}
            </span>
          </div>
        )}
      </div>
    </div>
  );
};
