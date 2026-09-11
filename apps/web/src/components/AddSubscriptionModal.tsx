'use client';

import React, { useState, useEffect, useId } from 'react';
import {
  BillingCycle,
  SubscriptionCategory,
  Subscription,
  fetchLogo,
  getRegionalPresets,
  searchPresetCatalog,
  RegionalPreset
} from '@subflow/core';
import { SubscriptionLogo, CustomDropdown, DropdownOption } from '@subflow/ui';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useTranslation } from '../hooks/useTranslation';
import { useEscapeKey } from '../hooks/useEscapeKey';
import { CategoryIcon } from './CategoryIcon';
import { JapandiDatePicker } from './JapandiDatePicker';
import { CancellationAssistantModal } from './CancellationAssistantModal';
import { TrueLayerSyncModal, getTrueLayerAuthUrl } from './TrueLayerSyncModal';
import { SvgIconPickerModal } from './SvgIconPickerModal';
import { X, Sparkles, FileText, Building2, ExternalLink, Zap, Image as ImageIcon } from 'lucide-react';


interface AddSubscriptionModalProps {
  isOpen: boolean;
  onClose: () => void;
  defaultDate?: string;
  editSubscription?: Subscription | null;
}

const CATEGORIES: SubscriptionCategory[] = [
  'Entertainment',
  'Productivity',
  'Utilities',
  'Health & Fitness',
  'Food & Dining',
  'Shopping',
  'General'
];

const CYCLE_SEGMENTS: { labelKey: string; value: BillingCycle }[] = [
  { labelKey: 'cycles.Monthly', value: 'Monthly' },
  { labelKey: 'cycles.Yearly', value: 'Yearly' },
  { labelKey: 'cycles.Weekly', value: 'Weekly' }
];

function getTodayString(): string {
  const parts = new Date().toISOString().split('T');
  return parts[0] ?? '2026-08-27';
}

export const AddSubscriptionModal: React.FC<AddSubscriptionModalProps> = ({
  isOpen,
  onClose,
  defaultDate,
  editSubscription
}) => {
  const { addSubscription, updateSubscription, profile } = useSubscriptionStore();
  const { t, locale } = useTranslation();
  const titleId = useId();


  // Keyboard accessibility: Close on Escape key
  useEscapeKey(isOpen, onClose);

  const presets = React.useMemo(
    () => getRegionalPresets(profile.countryCode || 'FR').slice(0, 15),
    [profile.countryCode]
  );

  const [name, setName] = useState<string>('');
  const [amount, setAmount] = useState<string>('');
  const [category, setCategory] = useState<SubscriptionCategory>('Entertainment');
  const [cycle, setCycle] = useState<BillingCycle>('Monthly');
  const [startDate, setStartDate] = useState<string>(defaultDate ?? getTodayString());
  const [logoUrl, setLogoUrl] = useState<string>('');
  const [isCustomLogoExplicit, setIsCustomLogoExplicit] = useState<boolean>(false);
  const [selectedPreset, setSelectedPreset] = useState<string | null>(null);
  const [isCancellationModalOpen, setIsCancellationModalOpen] = useState(false);
  const [isTrueLayerOpen, setIsTrueLayerOpen] = useState(false);
  const [isIconPickerOpen, setIsIconPickerOpen] = useState(false);
  const [showSuggestions, setShowSuggestions] = useState(false);


  const matchingSuggestions = React.useMemo(() => {
    if (!name || name.trim().length < 2) return [];
    return searchPresetCatalog(name, profile.countryCode || 'FR').slice(0, 6);
  }, [name, profile.countryCode]);

  useEffect(() => {
    if (editSubscription) {
      setName(editSubscription.name);
      setAmount(editSubscription.amount.toString());
      setCategory(editSubscription.category as SubscriptionCategory);
      setCycle(editSubscription.cycle as BillingCycle);
      setStartDate(editSubscription.startDate || getTodayString());
      setLogoUrl(editSubscription.logoUrl || '');
      setIsCustomLogoExplicit(Boolean(editSubscription.logoUrl?.startsWith('svg:')));
    } else {
      setName('');
      setAmount('');
      setCategory('Entertainment');
      setCycle('Monthly');
      setStartDate(defaultDate ?? getTodayString());
      setLogoUrl('');
      setIsCustomLogoExplicit(false);
      setSelectedPreset(null);
    }
  }, [editSubscription, defaultDate, isOpen]);

  useEffect(() => {
    if (!editSubscription && !isCustomLogoExplicit && name.trim().length > 1) {
      const predicted = fetchLogo(name);
      setLogoUrl(predicted);
    }
  }, [name, editSubscription, isCustomLogoExplicit]);

  const handleApplyPreset = (preset: RegionalPreset) => {
    setName(preset.name);
    setAmount(preset.amount.toString());
    setCategory(preset.category as SubscriptionCategory);
    setCycle(preset.cycle as BillingCycle);
    setLogoUrl(preset.logoUrl || fetchLogo(preset.name));
    setSelectedPreset(preset.name);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const parsedAmount = parseFloat(amount.replace(',', '.'));
    if (!name.trim() || isNaN(parsedAmount) || parsedAmount <= 0) return;

    const finalLogo: string = logoUrl || fetchLogo(name);
    const finalStartDate: string = startDate || getTodayString();

    if (editSubscription) {
      updateSubscription(editSubscription.id, {
        name: name.trim(),
        amount: parsedAmount,
        category,
        cycle,
        startDate: finalStartDate,
        logoUrl: finalLogo
      });
    } else {
      addSubscription({
        name: name.trim(),
        amount: parsedAmount,
        category,
        cycle,
        startDate: finalStartDate,
        logoUrl: finalLogo,
        status: 'active',
        currency: profile.currency || 'EUR',
        currencySymbol: profile.currencySymbol || '€'
      });
    }
    onClose();
  };

  const categoryOptions: DropdownOption[] = CATEGORIES.map((cat) => ({
    value: cat,
    label: t(`categories.${cat}` as any) || cat,
    icon: <CategoryIcon category={cat} className="w-3.5 h-3.5" showBackground={true} />
  }));

  if (!isOpen) return null;

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in duration-200"
      onClick={onClose}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        className="w-full max-w-lg rounded-japandi-2xl bg-japandi-surface border border-japandi-border shadow-japandi-xl overflow-hidden flex flex-col max-h-[90vh]"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="p-5 flex items-center justify-between border-b border-japandi-border">
          <div className="flex items-center gap-3.5">
            {/* Interactive Logo Avatar */}
            <div
              role="button"
              tabIndex={0}
              onClick={() => setIsIconPickerOpen(true)}
              onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') setIsIconPickerOpen(true); }}
              className="relative group cursor-pointer"
              title="Cliquez pour changer le logo ou l'icône SVG"
            >
              <SubscriptionLogo
                name={name || 'Subscription'}
                logoUrl={logoUrl}
                category={category}
                size={44}
                showCategoryBadge={true}
              />
              <div className="absolute inset-0 rounded-japandi-xl bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center text-white">
                <ImageIcon className="w-4 h-4 drop-shadow-sm" />
              </div>
            </div>

            <div>
              <div className="flex items-center gap-2">
                <h3 id={titleId} className="font-bold text-lg text-japandi-text">
                  {editSubscription ? t('modal.editTitle') : t('modal.addTitle')}
                </h3>
              </div>
              <p className="text-xs text-japandi-muted">
                {editSubscription
                  ? t('subs.subtitle')
                  : t('modal.popularPresets')}
              </p>
            </div>
          </div>
          <button
            type="button"
            aria-label={t('common.close')}
            onClick={onClose}
            className="p-2 rounded-japandi-md text-japandi-muted hover:text-japandi-text hover:bg-japandi-sand/40 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content body */}
        <div className="p-5 overflow-y-auto flex-1 flex flex-col gap-5">
          {/* Quick Pick Presets & Bank Sync */}
          {!editSubscription && (
            <div className="flex flex-col gap-2.5">
              {/* Direct BoursoBank Connect & All Banks */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                <button
                  type="button"
                  onClick={() => {
                    const url = getTrueLayerAuthUrl('stet-boursorama');
                    if (typeof window !== 'undefined') window.location.href = url;
                  }}
                  className="flex items-center justify-between p-3 rounded-japandi-xl border text-xs font-bold transition-all shadow-xs bg-japandi-pine/10 border-japandi-pine/30 hover:bg-japandi-pine/20 text-japandi-pine group"
                >
                  <div className="flex items-center gap-2">
                    <Zap className="w-4 h-4 text-japandi-pine fill-japandi-pine" />
                    <span>BoursoBank Live</span>
                  </div>
                  <ExternalLink className="w-3.5 h-3.5 opacity-70 group-hover:opacity-100" />
                </button>

                <button
                  type="button"
                  onClick={() => setIsTrueLayerOpen(true)}
                  className="flex items-center justify-between p-3 rounded-japandi-xl border text-xs font-bold transition-all shadow-xs bg-japandi-elevated border-japandi-border hover:border-japandi-pine text-japandi-text"
                >
                  <div className="flex items-center gap-2">
                    <Building2 className="w-4 h-4 text-japandi-muted" />
                    <span>{locale === 'fr' ? 'Autres banques...' : 'Other banks...'}</span>
                  </div>
                  <span className="text-[10px] font-semibold text-japandi-muted">DSP2</span>
                </button>
              </div>



              <div className="flex gap-2 overflow-x-auto pb-1 scrollbar-thin">
                {presets.map((preset) => {
                  const isSel = selectedPreset === preset.name;
                  return (
                    <button
                      key={preset.name}
                      type="button"
                      onClick={() => handleApplyPreset(preset)}
                      className={`flex-shrink-0 px-3.5 py-1.5 rounded-japandi-full text-xs font-bold transition-all ${
                        isSel
                          ? 'bg-japandi-pine text-white shadow-japandi-sm'
                          : 'bg-japandi-elevated border border-japandi-border text-japandi-text hover:border-japandi-pine'
                      }`}
                    >
                      {preset.name}
                    </button>
                  );
                })}
              </div>

            </div>

          )}

          {/* Form */}
          <form id="sub-form" onSubmit={handleSubmit} className="flex flex-col gap-4">
            {/* Dedicated Logo & Icon Customization Banner */}
            <div className="flex items-center justify-between p-3 rounded-japandi-xl border border-japandi-border bg-japandi-elevated/60">
              <div className="flex items-center gap-3">
                <div
                  role="button"
                  tabIndex={0}
                  onClick={() => setIsIconPickerOpen(true)}
                  className="cursor-pointer hover:scale-105 transition-transform"
                  title="Cliquez pour changer le logo ou l'icône"
                >
                  <SubscriptionLogo name={name || 'Service'} logoUrl={logoUrl} category={category} size={36} />
                </div>
                <div className="flex flex-col">
                  <span className="text-xs font-bold text-japandi-text">
                    {logoUrl?.startsWith('svg:') ? 'Icône SVG personnalisée' : 'Logo du service'}
                  </span>
                  <span className="text-[11px] text-japandi-muted">
                    {logoUrl?.startsWith('svg:')
                      ? 'Icône vectorielle native sélectionnée'
                      : logoUrl
                      ? 'Logo détecté automatiquement'
                      : 'Icône par défaut de la catégorie'}
                  </span>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setIsIconPickerOpen(true)}
                className="px-3 py-1.5 rounded-japandi-md border border-japandi-pine/30 bg-japandi-pine/10 hover:bg-japandi-pine/20 text-japandi-pine text-xs font-bold flex items-center gap-1.5 transition-all shadow-2xs"
              >
                <ImageIcon className="w-3.5 h-3.5" />
                <span>Modifier le logo</span>
              </button>
            </div>

            {/* Subscription Name */}
            <div className="relative">
              <label className="block text-xs font-semibold text-japandi-muted uppercase tracking-wider mb-1.5">
                {t('modal.nameLabel')}
              </label>
              <div className="relative">
                <input
                  type="text"
                  required
                  placeholder={t('modal.namePlaceholder')}
                  value={name}
                  onChange={(e) => {
                    setName(e.target.value);
                    setShowSuggestions(true);
                  }}
                  onFocus={() => setShowSuggestions(true)}
                  className="w-full px-3.5 py-2.5 rounded-japandi-md bg-japandi-elevated border border-japandi-border text-japandi-text text-sm focus:outline-none focus:ring-2 focus:ring-japandi-pine transition-all"
                />
              </div>


              {/* Suggestions Dropdown from 350+ Catalog */}
              {!editSubscription && showSuggestions && matchingSuggestions.length > 0 && name.trim().length >= 2 && (
                <div className="absolute z-20 top-full left-0 right-0 mt-1 rounded-japandi-xl bg-japandi-surface border border-japandi-border shadow-japandi-md overflow-hidden divide-y divide-japandi-border">
                  {matchingSuggestions.map((item) => (
                    <div
                      key={item.id}
                      onClick={() => {
                        setName(item.name);
                        setAmount(item.defaultAmount.toString());
                        setCategory(item.category as SubscriptionCategory);
                        setCycle(item.defaultCycle as BillingCycle);
                        setLogoUrl(fetchLogo(item.name, item.domain));
                        setShowSuggestions(false);
                      }}
                      className="p-2.5 hover:bg-japandi-sand/50 transition-colors cursor-pointer flex items-center justify-between"
                    >
                      <div className="flex items-center gap-2">
                        <SubscriptionLogo name={item.name} domain={item.domain} category={item.category} size={24} />
                        <div>
                          <span className="font-bold text-xs text-japandi-text">{item.name}</span>
                          <span className="text-[10px] text-japandi-muted ml-2">{item.category}</span>
                        </div>
                      </div>
                      <span className="text-xs font-extrabold text-japandi-terracotta">
                        {item.currencySymbol}{item.defaultAmount.toFixed(2)}
                      </span>

                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Amount & Billing Cycle */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-semibold text-japandi-muted uppercase tracking-wider mb-1.5">
                  {t('modal.amountLabel')}
                </label>
                <div className="relative">
                  <span className="absolute left-3.5 top-2.5 text-japandi-muted text-sm font-medium">
                    {profile.currencySymbol || '€'}
                  </span>
                  <input
                    type="text"
                    required
                    inputMode="decimal"
                    placeholder="12.99"
                    value={amount}
                    onChange={(e) => setAmount(e.target.value)}
                    className="w-full pl-8 pr-3.5 py-2.5 rounded-japandi-md bg-japandi-elevated border border-japandi-border text-japandi-text text-sm focus:outline-none focus:ring-2 focus:ring-japandi-pine transition-all font-semibold"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-japandi-muted uppercase tracking-wider mb-1.5">
                  {t('modal.cycleLabel')}
                </label>
                <div className="flex rounded-japandi-md bg-japandi-elevated border border-japandi-border p-1 gap-1">
                  {CYCLE_SEGMENTS.map((seg) => (
                    <button
                      key={seg.value}
                      type="button"
                      onClick={() => setCycle(seg.value)}
                      className={`flex-1 py-2 px-1 text-[11px] sm:text-xs font-bold rounded-japandi-sm transition-all whitespace-nowrap ${
                        cycle === seg.value
                          ? 'bg-japandi-pine text-white shadow-xs'
                          : 'text-japandi-muted hover:text-japandi-text'
                      }`}
                    >
                      {t(seg.labelKey as any)}
                    </button>
                  ))}
                </div>
              </div>
            </div>


            {/* Category Dropdown */}
            <CustomDropdown
              label={t('modal.categoryLabel')}
              options={categoryOptions}
              value={category}
              onChange={(val) => setCategory(val as SubscriptionCategory)}
            />

            {/* Calendar First Payment Date */}
            <JapandiDatePicker
              label={t('modal.startDateLabel')}
              value={startDate}
              onChange={setStartDate}
            />

            {/* Edit Mode 1-Click Cancellation Assistant */}
            {editSubscription && (
              <div className="pt-2">
                <button
                  type="button"
                  onClick={() => setIsCancellationModalOpen(true)}
                  className="w-full py-2.5 px-3 rounded-japandi-xl border border-japandi-pine/30 bg-japandi-pine/5 hover:bg-japandi-pine/10 text-japandi-pine text-xs font-bold flex items-center justify-center gap-2 transition-colors"
                >
                  <FileText className="w-4 h-4" />
                  <span>{t('modal.cancellationAssistantBtn')}</span>
                </button>
              </div>
            )}
          </form>
        </div>

        {/* Footer */}
        <div className="p-4 bg-japandi-elevated border-t border-japandi-border flex items-center justify-end gap-3">
          <button
            type="button"
            onClick={onClose}
            className="px-4 py-2.5 rounded-japandi-md border border-japandi-border text-japandi-muted hover:text-japandi-text text-sm font-semibold transition-colors"
          >
            {t('common.cancel')}
          </button>
          <button
            type="submit"
            form="sub-form"
            className="px-6 py-2.5 rounded-japandi-md bg-japandi-pine hover:bg-japandi-pine/90 text-white text-sm font-bold shadow-japandi-sm transition-all"
          >
            {editSubscription ? t('modal.submitEdit') : t('modal.submitAdd')}
          </button>
        </div>


      </div>

      {/* Linked Cancellation Assistant Modal */}
      {isCancellationModalOpen && editSubscription && (
        <CancellationAssistantModal
          isOpen={isCancellationModalOpen}
          onClose={() => setIsCancellationModalOpen(false)}
          subscriptionName={editSubscription.name}
        />
      )}

      {/* TrueLayer Bank Sync Modal */}
      {isTrueLayerOpen && (
        <TrueLayerSyncModal
          isOpen={isTrueLayerOpen}
          onClose={() => {
            setIsTrueLayerOpen(false);
            onClose();
          }}
        />
      )}

      {/* SVG Icon Picker Modal */}
      {isIconPickerOpen && (
        <SvgIconPickerModal
          isOpen={isIconPickerOpen}
          onClose={() => setIsIconPickerOpen(false)}
          selectedIconId={logoUrl?.startsWith('svg:') ? logoUrl.replace(/^svg:/, '') : undefined}
          subscriptionCategory={category}
          onSelectIcon={(iconId) => {
            setLogoUrl(`svg:${iconId}`);
          }}
        />
      )}
    </div>
  );
};


