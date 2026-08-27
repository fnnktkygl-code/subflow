'use client';

import React from 'react';
import { Subscription, formatCurrency } from '@subflow/core';
import { JapandiBadge } from './JapandiBadge';
import { SubscriptionLogo } from './SubscriptionLogo';
import { Tooltip } from './Tooltip';
import { Edit2, Trash2 } from 'lucide-react';


export interface SubscriptionRowProps {
  subscription: Subscription;
  isBlurred?: boolean;
  currencySymbol?: string;
  isSelectionMode?: boolean;
  isSelected?: boolean;
  onSelect?: (id: string) => void;
  onClick?: (subscription: Subscription) => void;
  onEdit?: (subscription: Subscription) => void;
  onDelete?: (subscription: Subscription) => void;
}

export const SubscriptionRow: React.FC<SubscriptionRowProps> = ({
  subscription,
  isBlurred = false,
  currencySymbol = '€',
  isSelectionMode = false,
  isSelected = false,
  onSelect,
  onClick,
  onEdit,
  onDelete
}) => {
  return (
    <div
      onClick={() => {
        if (isSelectionMode && onSelect) {
          onSelect(subscription.id);
        } else if (onClick) {
          onClick(subscription);
        }
      }}
      className={`group relative flex items-center justify-between p-3.5 sm:p-4 rounded-japandi-md bg-japandi-surface border transition-all duration-200 cursor-pointer ${
        isSelected
          ? 'border-japandi-terracotta bg-japandi-sand/30 shadow-japandi-sm'
          : 'border-japandi-border hover:border-japandi-border-strong hover:shadow-japandi-sm'
      }`}
    >
      <div className="flex items-center gap-3 sm:gap-3.5 min-w-0">
        {isSelectionMode && (
          <div
            className={`w-5 h-5 rounded-japandi-sm border flex items-center justify-center transition-colors ${
              isSelected
                ? 'bg-japandi-terracotta border-japandi-terracotta text-white'
                : 'border-japandi-border bg-japandi-elevated'
            }`}
          >
            {isSelected && (
              <svg className="w-3.5 h-3.5" viewBox="0 0 20 20" fill="currentColor">
                <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
              </svg>
            )}
          </div>
        )}

        <SubscriptionLogo
          name={subscription.name}
          logoUrl={subscription.logoUrl}
          category={subscription.category}
          size={42}
          showCategoryBadge={true}
        />

        <div className="min-w-0">
          <div className="flex items-center gap-2">
            <h4
              className={`font-semibold text-sm truncate text-japandi-text group-hover:text-japandi-pine transition-colors ${
                isSelected ? 'line-through opacity-60' : ''
              }`}
            >
              {subscription.name}
            </h4>
            <JapandiBadge variant="neutral" size="sm">
              {subscription.cycle}
            </JapandiBadge>
          </div>
          <p className="text-xs text-japandi-muted mt-0.5 truncate">
            {subscription.category} • renewal on {new Date(subscription.startDate).getDate()}
          </p>
        </div>
      </div>

      <div className="flex items-center gap-3 flex-shrink-0">
        <div className="text-right">
          <p
            className={`font-bold text-sm text-japandi-text transition-all ${
              isBlurred ? 'blur-sm select-none' : ''
            } ${isSelected ? 'line-through text-japandi-terracotta' : ''}`}
          >
            -{formatCurrency(subscription.amount, currencySymbol)}
          </p>
          <span className="text-[11px] text-japandi-subtle">
            per {subscription.cycle.toLowerCase() === 'yearly' ? 'year' : 'month'}
          </span>
        </div>

        {/* Action buttons (Edit & Delete) */}
        {!isSelectionMode && (
          <div className="hidden group-hover:flex items-center gap-1 ml-2 transition-opacity animate-in fade-in duration-150">
            {onEdit && (
              <Tooltip content="Modifier" side="top">
                <button
                  type="button"
                  onClick={(e) => {
                    e.stopPropagation();
                    onEdit(subscription);
                  }}
                  className="p-1.5 rounded-japandi-sm text-japandi-muted hover:text-japandi-text hover:bg-japandi-sand/50 transition-colors"
                  aria-label="Modifier l'abonnement"
                >
                  <Edit2 className="w-3.5 h-3.5" />
                </button>
              </Tooltip>
            )}
            {onDelete && (
              <Tooltip content="Supprimer" side="top">
                <button
                  type="button"
                  onClick={(e) => {
                    e.stopPropagation();
                    onDelete(subscription);
                  }}
                  className="p-1.5 rounded-japandi-sm text-japandi-muted hover:text-japandi-terracotta hover:bg-japandi-terracotta/10 transition-colors"
                  aria-label="Supprimer l'abonnement"
                >
                  <Trash2 className="w-3.5 h-3.5" />
                </button>
              </Tooltip>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

