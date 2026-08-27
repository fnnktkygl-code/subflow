'use client';

import React, { useState } from 'react';
import { Subscription, formatCurrency } from '@subflow/core';
import { SubscriptionLogo } from '@subflow/ui';
import { PlusCircle, Edit3, Trash2, X, AlertCircle, Calendar } from 'lucide-react';
import { useEscapeKey } from '../hooks/useEscapeKey';
import { useTranslation } from '../hooks/useTranslation';

interface CalendarActionsDrawerProps {
  isOpen: boolean;
  onClose: () => void;
  date: Date;
  subscriptionsForDay: Subscription[];
  onAdd: (dateStr: string) => void;
  onEdit: (subscription: Subscription) => void;
  onDelete: (subscriptionId: string) => void;
  currencySymbol?: string;
}

export const CalendarActionsDrawer: React.FC<CalendarActionsDrawerProps> = ({
  isOpen,
  onClose,
  date,
  subscriptionsForDay,
  onAdd,
  onEdit,
  onDelete,
  currencySymbol = '€'
}) => {
  useEscapeKey(isOpen, onClose);
  const { locale } = useTranslation();

  const [subSelectionMode, setSubSelectionMode] = useState<'edit' | 'delete' | null>(null);
  const [deletingSub, setDeletingSub] = useState<Subscription | null>(null);

  if (!isOpen) return null;

  const formattedDate = date.toLocaleDateString(locale === 'fr' ? 'fr-FR' : 'en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric',
    year: 'numeric'
  });

  const isoDateStr = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
  const hasSubscriptions = subscriptionsForDay.length > 0;

  const handleEditClick = () => {
    if (subscriptionsForDay.length === 1 && subscriptionsForDay[0]) {
      onEdit(subscriptionsForDay[0]);
      onClose();
    } else {
      setSubSelectionMode('edit');
    }
  };

  const handleDeleteClick = () => {
    if (subscriptionsForDay.length === 1 && subscriptionsForDay[0]) {
      setDeletingSub(subscriptionsForDay[0]);
    } else {
      setSubSelectionMode('delete');
    }
  };

  const confirmDelete = () => {
    if (deletingSub) {
      onDelete(deletingSub.id);
      setDeletingSub(null);
      onClose();
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4 bg-black/40 backdrop-blur-xs animate-in fade-in duration-200"
      onClick={onClose}
      role="dialog"
      aria-modal="true"
    >
      <div
        className="w-full sm:max-w-md bg-japandi-surface rounded-t-japandi-2xl sm:rounded-japandi-2xl border border-japandi-border shadow-japandi-xl p-6 flex flex-col gap-4 animate-in slide-in-from-bottom-6 duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Japandi Drag Handle */}
        <div className="w-12 h-1.5 rounded-japandi-full bg-japandi-border mx-auto -mt-2 mb-1 sm:hidden" />

        {/* Header */}
        <div className="flex items-start justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-9 h-9 rounded-japandi-lg bg-japandi-pine/10 text-japandi-pine flex items-center justify-center flex-shrink-0">
              <Calendar className="w-5 h-5" />
            </div>
            <div>
              <h3 className="font-bold text-base capitalize text-japandi-text">{formattedDate}</h3>
              <p className="text-xs font-semibold text-japandi-muted">
                {hasSubscriptions
                  ? (locale === 'fr'
                      ? `${subscriptionsForDay.length} abonnement${subscriptionsForDay.length > 1 ? 's' : ''} ce jour`
                      : `${subscriptionsForDay.length} scheduled subscription${subscriptionsForDay.length > 1 ? 's' : ''}`)
                  : (locale === 'fr' ? 'Aucun abonnement ce jour' : 'No scheduled subscriptions')}
              </p>
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            aria-label="Fermer"
            className="p-1.5 rounded-japandi-full text-japandi-muted hover:text-japandi-text hover:bg-japandi-sand transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Delete Confirmation Modal */}
        {deletingSub ? (
          <div className="p-4 rounded-japandi-xl bg-japandi-elevated border border-japandi-terracotta/30 flex flex-col gap-3">
            <div className="flex items-center gap-2 text-japandi-akane">
              <AlertCircle className="w-5 h-5 flex-shrink-0" />
              <h4 className="font-bold text-sm">
                {locale === 'fr' ? 'Confirmer la suppression' : 'Confirm Deletion'}
              </h4>
            </div>
            <p className="text-xs text-japandi-muted">
              {locale === 'fr'
                ? `Êtes-vous sûr de vouloir supprimer ${deletingSub.name} ?`
                : `Are you sure you want to delete ${deletingSub.name}?`}
            </p>
            <div className="flex items-center justify-end gap-2 mt-2">
              <button
                type="button"
                onClick={() => setDeletingSub(null)}
                className="px-4 py-2 rounded-japandi-md border border-japandi-border text-xs font-semibold text-japandi-text hover:bg-japandi-sand transition-colors"
              >
                {locale === 'fr' ? 'Annuler' : 'Cancel'}
              </button>
              <button
                type="button"
                onClick={confirmDelete}
                className="px-4 py-2 rounded-japandi-md bg-japandi-akane text-white text-xs font-bold hover:opacity-90 transition-opacity"
              >
                {locale === 'fr' ? 'Supprimer' : 'Delete'}
              </button>
            </div>
          </div>
        ) : subSelectionMode ? (
          /* Multi-Subscription Selection for Edit / Delete */
          <div className="flex flex-col gap-2.5">
            <div className="flex items-center justify-between">
              <h4 className="font-bold text-xs text-japandi-text uppercase tracking-wider">
                {locale === 'fr'
                  ? `Choisir l'abonnement à ${subSelectionMode === 'edit' ? 'modifier' : 'supprimer'}`
                  : `Select subscription to ${subSelectionMode}`}
              </h4>
              <button
                type="button"
                onClick={() => setSubSelectionMode(null)}
                className="text-xs text-japandi-pine font-bold hover:underline"
              >
                {locale === 'fr' ? 'Retour' : 'Back'}
              </button>
            </div>
            <div className="flex flex-col gap-2 max-h-48 overflow-y-auto">
              {subscriptionsForDay.map((sub) => (
                <button
                  key={sub.id}
                  type="button"
                  onClick={() => {
                    if (subSelectionMode === 'edit') {
                      onEdit(sub);
                      onClose();
                    } else {
                      setDeletingSub(sub);
                      setSubSelectionMode(null);
                    }
                  }}
                  className="flex items-center justify-between p-3 rounded-japandi-lg bg-japandi-elevated border border-japandi-border hover:border-japandi-pine transition-all text-left"
                >
                  <div className="flex items-center gap-2.5">
                    <SubscriptionLogo name={sub.name} logoUrl={sub.logoUrl} category={sub.category} size={28} />
                    <span className="font-bold text-xs text-japandi-text">{sub.name}</span>
                  </div>
                  <span className="font-bold text-xs text-japandi-terracotta">
                    -{formatCurrency(sub.amount, sub.currency || 'EUR', locale)}
                  </span>
                </button>
              ))}
            </div>
          </div>
        ) : (
          /* Main Action Buttons Matching Flutter Spec */
          <div className="flex flex-col gap-2.5">
            {/* 1. Add Subscription on this date */}
            <button
              type="button"
              onClick={() => {
                onAdd(isoDateStr);
                onClose();
              }}
              className="w-full flex items-center gap-3 p-3.5 rounded-japandi-xl bg-japandi-pine/10 border border-japandi-pine/30 hover:bg-japandi-pine/15 text-japandi-pine font-bold text-sm transition-all shadow-xs"
            >
              <PlusCircle className="w-5 h-5" />
              <span>{locale === 'fr' ? 'Ajouter un abonnement à cette date' : 'Add subscription on this date'}</span>
            </button>

            {/* If Day Has Subscriptions: Edit & Delete */}
            {hasSubscriptions && (
              <>
                <button
                  type="button"
                  onClick={handleEditClick}
                  className="w-full flex items-center gap-3 p-3.5 rounded-japandi-xl bg-japandi-elevated border border-japandi-border hover:border-japandi-border-strong text-japandi-text font-bold text-sm transition-all shadow-xs"
                >
                  <Edit3 className="w-5 h-5 text-japandi-terracotta" />
                  <span>{locale === 'fr' ? 'Modifier un abonnement' : 'Edit subscription'}</span>
                </button>

                <button
                  type="button"
                  onClick={handleDeleteClick}
                  className="w-full flex items-center gap-3 p-3.5 rounded-japandi-xl bg-japandi-akane/10 border border-japandi-akane/20 hover:bg-japandi-akane/15 text-japandi-akane font-bold text-sm transition-all shadow-xs"
                >
                  <Trash2 className="w-5 h-5" />
                  <span>{locale === 'fr' ? 'Supprimer un abonnement' : 'Delete subscription'}</span>
                </button>
              </>
            )}
          </div>
        )}
      </div>
    </div>
  );
};
