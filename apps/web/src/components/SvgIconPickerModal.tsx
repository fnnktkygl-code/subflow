'use client';

import React, { useState } from 'react';
import { NATIVE_SVG_ICONS, NativeSvgIcon } from '@subflow/core';
import { useEscapeKey } from '../hooks/useEscapeKey';
import { X, Search, Check } from 'lucide-react';

interface SvgIconPickerModalProps {
  isOpen: boolean;
  onClose: () => void;
  selectedIconId?: string;
  onSelectIcon: (iconId: string) => void;
  subscriptionCategory?: string;
}

const CATEGORY_TABS: { label: string; value: string }[] = [
  { label: 'Tous', value: 'all' },
  { label: 'Streaming & Média', value: 'Entertainment' },
  { label: 'IA & Tech', value: 'Productivity' },
  { label: 'Télécoms & Énergie', value: 'Utilities' },
  { label: 'Santé & Sport', value: 'Health & Fitness' },
  { label: 'Alimentation & Repas', value: 'Food & Dining' },
  { label: 'Shopping & Mode', value: 'Shopping' },
  { label: 'Transport & Mobilité', value: 'Transport' },
  { label: 'Banque & Général', value: 'General' }
];

export const SvgIconPickerModal: React.FC<SvgIconPickerModalProps> = ({
  isOpen,
  onClose,
  selectedIconId,
  onSelectIcon,
  subscriptionCategory
}) => {
  const [activeTab, setActiveTab] = useState<string>(subscriptionCategory || 'all');
  const [searchQuery, setSearchQuery] = useState<string>('');

  useEscapeKey(isOpen, onClose);

  if (!isOpen) return null;

  const filteredIcons = NATIVE_SVG_ICONS.filter((icon) => {
    const matchesTab = activeTab === 'all' || icon.category === activeTab;
    const matchesQuery =
      !searchQuery.trim() ||
      icon.name.toLowerCase().includes(searchQuery.toLowerCase().trim()) ||
      icon.category.toLowerCase().includes(searchQuery.toLowerCase().trim());
    return matchesTab && matchesQuery;
  });

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in duration-200"
      onClick={onClose}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="icon-picker-title"
        className="w-full max-w-lg rounded-japandi-2xl bg-japandi-surface border border-japandi-border shadow-japandi-xl overflow-hidden flex flex-col max-h-[85vh] animate-in zoom-in-95 duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="p-4 sm:p-5 flex items-center justify-between border-b border-japandi-border bg-japandi-elevated">
          <div>
            <h3 id="icon-picker-title" className="font-bold text-base sm:text-lg text-japandi-text">
              Choisir une icône SVG native
            </h3>
            <p className="text-xs text-japandi-muted">
              Icônes vectorielles nettes et élégantes selon les standards Japandi
            </p>
          </div>
          <button
            type="button"
            onClick={onClose}
            aria-label="Fermer"
            className="p-2 rounded-japandi-md text-japandi-muted hover:text-japandi-text hover:bg-japandi-sand/40 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Search bar & Category filters */}
        <div className="p-4 border-b border-japandi-border flex flex-col gap-3 bg-japandi-surface">
          {/* Search input */}
          <div className="relative">
            <Search className="w-4 h-4 text-japandi-muted absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              placeholder="Rechercher une icône (ex: film, vélo, sport, café, banque)..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-9 pr-3 py-2 rounded-japandi-md bg-japandi-elevated border border-japandi-border text-japandi-text text-xs focus:outline-none focus:ring-2 focus:ring-japandi-pine transition-all"
            />
          </div>

          {/* Filter tabs */}
          <div className="flex gap-1.5 overflow-x-auto pb-1 scrollbar-thin">
            {CATEGORY_TABS.map((tab) => {
              const isSelected = activeTab === tab.value;
              return (
                <button
                  key={tab.value}
                  type="button"
                  onClick={() => setActiveTab(tab.value)}
                  className={`flex-shrink-0 px-2.5 py-1 text-[11px] font-semibold rounded-japandi-full transition-all ${
                    isSelected
                      ? 'bg-japandi-pine text-white shadow-xs'
                      : 'bg-japandi-elevated border border-japandi-border text-japandi-muted hover:text-japandi-text'
                  }`}
                >
                  {tab.label}
                </button>
              );
            })}
          </div>
        </div>

        {/* Icons Grid */}
        <div className="p-4 sm:p-5 overflow-y-auto flex-1 grid grid-cols-3 sm:grid-cols-4 gap-2.5 max-h-[380px]">
          {filteredIcons.map((icon: NativeSvgIcon) => {
            const isSelected = selectedIconId === icon.id;
            return (
              <button
                key={icon.id}
                type="button"
                onClick={() => {
                  onSelectIcon(icon.id);
                  onClose();
                }}
                className={`relative flex flex-col items-center justify-center p-3 rounded-japandi-xl border text-center transition-all group ${
                  isSelected
                    ? 'border-japandi-pine bg-japandi-pine/10 text-japandi-pine ring-2 ring-japandi-pine/30 shadow-xs'
                    : 'border-japandi-border bg-japandi-elevated hover:border-japandi-pine/60 hover:bg-japandi-sand/30 text-japandi-text'
                }`}
              >
                {/* SVG Icon Display */}
                <div
                  className={`w-9 h-9 rounded-japandi-lg flex items-center justify-center mb-1.5 transition-transform group-hover:scale-110 ${
                    isSelected ? 'bg-japandi-pine text-white shadow-xs' : 'bg-japandi-sand/50 text-japandi-text'
                  }`}
                >
                  <svg
                    viewBox={icon.viewBox || '0 0 24 24'}
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    className="w-5 h-5"
                    dangerouslySetInnerHTML={{ __html: icon.svg }}
                  />
                </div>

                {/* Icon Name */}
                <span className="text-[11px] font-semibold line-clamp-1 group-hover:text-japandi-pine transition-colors">
                  {icon.name}
                </span>

                {/* Selection Check indicator */}
                {isSelected && (
                  <div className="absolute top-1.5 right-1.5 w-4 h-4 rounded-full bg-japandi-pine text-white flex items-center justify-center">
                    <Check className="w-2.5 h-2.5" />
                  </div>
                )}
              </button>
            );
          })}

          {filteredIcons.length === 0 && (
            <div className="col-span-full py-8 text-center text-japandi-muted text-xs">
              Aucune icône ne correspond à votre recherche.
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="p-3 sm:p-4 border-t border-japandi-border bg-japandi-elevated flex items-center justify-between text-xs text-japandi-muted">
          <span>{filteredIcons.length} icônes vectorielles disponibles</span>
          <button
            type="button"
            onClick={onClose}
            className="px-3.5 py-1.5 rounded-japandi-md border border-japandi-border text-japandi-text hover:bg-japandi-sand/30 font-semibold transition-colors"
          >
            Fermer
          </button>
        </div>
      </div>
    </div>
  );
};
