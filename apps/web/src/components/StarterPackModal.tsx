'use client';

import React, { useState, useMemo, useId } from 'react';
import { COMPLETE_SUBSCRIPTION_CATALOG, searchPresetCatalog, CatalogService } from '@subflow/core';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useTranslation } from '../hooks/useTranslation';
import { useEscapeKey } from '../hooks/useEscapeKey';
import { SubscriptionLogo } from '@subflow/ui';
import { Sparkles, Check, Search, X, Rocket, Filter } from 'lucide-react';
import confetti from 'canvas-confetti';

interface StarterPackModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const StarterPackModal: React.FC<StarterPackModalProps> = ({ isOpen, onClose }) => {
  const { addSubscription, profile } = useSubscriptionStore();
  const { t, format } = useTranslation();
  const titleId = useId();

  // Keyboard accessibility: Escape key listener
  useEscapeKey(isOpen, onClose);

  const [searchQuery, setSearchQuery] = useState('');
  const [activeCategory, setActiveCategory] = useState('All');

  const CATEGORIES = [
    { id: 'All', label: `${t('common.all')} (350+)` },
    { id: 'Entertainment', label: t('categories.Entertainment') },
    { id: 'Productivity', label: t('categories.Productivity') },
    { id: 'Utilities', label: t('categories.Utilities') },
    { id: 'Health & Fitness', label: t('categories.Health & Fitness') },
    { id: 'Shopping', label: t('categories.Shopping') },
    { id: 'Food & Dining', label: t('categories.Food & Dining') }
  ];

  const [selectedIds, setSelectedIds] = useState<string[]>([
    'netflix',
    'spotify',
    'chatgpt-plus',
    'pass-navigo-mensuel'
  ]);

  const filteredCatalog = useMemo(() => {
    return searchPresetCatalog(searchQuery, profile.countryCode || 'FR', activeCategory);
  }, [searchQuery, profile.countryCode, activeCategory]);

  if (!isOpen) return null;

  const toggleSelect = (id: string) => {
    setSelectedIds((prev) =>
      prev.includes(id) ? prev.filter((i) => i !== id) : [...prev, id]
    );
  };

  const selectedServices = COMPLETE_SUBSCRIPTION_CATALOG.filter((item) =>
    selectedIds.includes(item.id)
  );

  const totalMonthly = selectedServices.reduce((sum, item) => {
    if (item.defaultCycle === 'Yearly') return sum + item.defaultAmount / 12;
    if (item.defaultCycle === 'Weekly') return sum + (item.defaultAmount * 52) / 12;
    return sum + item.defaultAmount;
  }, 0);

  const handleApplyStarterPack = () => {
    const today = new Date().toISOString().split('T')[0]!;

    selectedServices.forEach((service) => {
      addSubscription({
        name: service.name,
        amount: service.defaultAmount,
        category: service.category,
        cycle: service.defaultCycle,
        startDate: today,
        currency: service.currency,
        currencySymbol: service.currencySymbol,
        status: 'active'
      });
    });

    try {
      confetti({
        particleCount: 80,
        spread: 60,
        origin: { y: 0.6 }
      });
    } catch (_) {}

    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in duration-150">
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        className="w-full max-w-2xl rounded-japandi-2xl bg-japandi-surface border border-japandi-border p-6 shadow-japandi-xl flex flex-col gap-4 max-h-[92vh] overflow-hidden select-none"
      >
        {/* Header */}
        <div className="flex items-center justify-between pb-3 border-b border-japandi-border flex-shrink-0">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-japandi-full bg-japandi-pine/10 flex items-center justify-center text-japandi-pine">
              <Rocket className="w-4 h-4" />
            </div>
            <div>
              <h3 id={titleId} className="font-extrabold text-base text-japandi-text">
                {t('starterPack.title')}
              </h3>
              <p className="text-xs text-japandi-muted">
                {t('starterPack.subtitle')}
              </p>
            </div>
          </div>

          <button
            type="button"
            aria-label={t('common.close')}
            onClick={onClose}
            className="p-1.5 rounded-japandi-md text-japandi-muted hover:text-japandi-text hover:bg-japandi-sand transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Search Bar */}
        <div className="relative flex-shrink-0">
          <Search className="w-4 h-4 text-japandi-muted absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            aria-label={t('starterPack.searchPlaceholder')}
            placeholder={t('starterPack.searchPlaceholder')}
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2.5 rounded-japandi-xl bg-japandi-elevated border border-japandi-border text-japandi-text text-xs focus:outline-none focus:ring-1 focus:ring-japandi-pine placeholder:text-japandi-subtle"
          />
        </div>

        {/* Category Pills */}
        <div className="flex gap-1.5 overflow-x-auto pb-1 scrollbar-thin flex-shrink-0">
          {CATEGORIES.map((cat) => (
            <button
              key={cat.id}
              type="button"
              onClick={() => setActiveCategory(cat.id)}
              className={`px-3 py-1.5 rounded-japandi-full text-xs font-bold transition-all whitespace-nowrap ${
                activeCategory === cat.id
                  ? 'bg-japandi-pine text-white shadow-xs'
                  : 'bg-japandi-elevated border border-japandi-border text-japandi-muted hover:text-japandi-text'
              }`}
            >
              {cat.label}
            </button>
          ))}
        </div>

        {/* Grid of Subscriptions */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5 overflow-y-auto pr-1 flex-1 min-h-0">
          {filteredCatalog.length === 0 ? (
            <div className="col-span-full py-12 text-center text-xs text-japandi-muted">
              {t('subs.emptyDesc')}
            </div>
          ) : (
            filteredCatalog.map((item) => {
              const isSelected = selectedIds.includes(item.id);

              return (
                <div
                  key={item.id}
                  onClick={() => toggleSelect(item.id)}
                  className={`p-3 rounded-japandi-xl border transition-all cursor-pointer flex items-center justify-between shadow-2xs ${
                    isSelected
                      ? 'bg-japandi-sand/60 border-japandi-pine ring-1 ring-japandi-pine'
                      : 'bg-japandi-elevated border border-japandi-border hover:border-japandi-border-strong'
                  }`}
                >
                  <div className="flex items-center gap-2.5 min-w-0">
                    <SubscriptionLogo
                      name={item.name}
                      category={item.category}
                      size={36}
                    />
                    <div className="min-w-0">
                      <h4 className="font-bold text-xs text-japandi-text truncate">
                        {item.name}
                      </h4>
                      <span className="text-[10px] text-japandi-muted">
                        {t(`categories.${item.category}` as any) || item.category} • {t(`cycles.${item.defaultCycle}` as any) || item.defaultCycle}
                      </span>
                    </div>
                  </div>

                  <div className="flex items-center gap-2.5 flex-shrink-0">
                    <span className="font-extrabold text-xs text-japandi-terracotta">
                      {item.currencySymbol}{item.defaultAmount.toFixed(2)}
                    </span>
                    <div
                      className={`w-5 h-5 rounded-md border flex items-center justify-center transition-colors ${
                        isSelected
                          ? 'bg-japandi-pine border-japandi-pine text-white'
                          : 'border-japandi-border bg-japandi-surface'
                      }`}
                    >
                      {isSelected && <Check className="w-3.5 h-3.5 stroke-[3]" />}
                    </div>
                  </div>
                </div>
              );
            })
          )}
        </div>

        {/* Bottom Total & 1-Click Action */}
        <div className="pt-3 border-t border-japandi-border flex flex-col sm:flex-row items-center justify-between gap-3 flex-shrink-0">
          <div className="flex flex-col">
            <span className="text-xs font-bold text-japandi-text">
              {t('starterPack.selectedCount', { count: selectedIds.length })}
            </span>
            <span className="text-xs text-japandi-muted">
              {t('starterPack.estimatedTotal')} <strong className="text-japandi-terracotta">{format(totalMonthly)} / {t('cycles.Monthly').toLowerCase()}</strong>
            </span>
          </div>

          <button
            type="button"
            onClick={handleApplyStarterPack}
            disabled={selectedIds.length === 0}
            className="w-full sm:w-auto px-5 py-2.5 rounded-japandi-md bg-japandi-pine hover:bg-japandi-pine/90 text-white font-bold text-xs flex items-center justify-center gap-2 shadow-japandi-sm transition-all disabled:opacity-50"
          >
            <Sparkles className="w-3.5 h-3.5" />
            <span>{t('starterPack.addButton', { count: selectedIds.length })}</span>
          </button>
        </div>
      </div>
    </div>
  );
};
