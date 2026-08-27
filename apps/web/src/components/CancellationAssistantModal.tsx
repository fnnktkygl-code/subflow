'use client';

import React, { useState, useId } from 'react';
import { Subscription } from '@subflow/core';
import { getCancellationGuide, generateCancellationLetter } from '@subflow/core';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useTranslation } from '../hooks/useTranslation';
import { useEscapeKey } from '../hooks/useEscapeKey';
import { SubscriptionLogo } from '@subflow/ui';
import { ExternalLink, FileText, Copy, Check, X, ShieldAlert, Sparkles, Send } from 'lucide-react';

interface CancellationAssistantModalProps {
  subscriptionName?: string;
  subscription?: Subscription | null;
  isOpen: boolean;
  onClose: () => void;
}

export const CancellationAssistantModal: React.FC<CancellationAssistantModalProps> = ({
  subscription,
  subscriptionName,
  isOpen,
  onClose
}) => {
  const { profile } = useSubscriptionStore();
  const { t } = useTranslation();
  const titleId = useId();
  const targetName = subscription?.name || subscriptionName || 'Abonnement';

  // Keyboard accessibility: Escape key listener
  useEscapeKey(isOpen, onClose);

  const [activeTab, setActiveTab] = useState<'direct' | 'letter'>('direct');
  const [reason, setReason] = useState<'sans_engagement' | 'echeance_chatel' | 'hausse_tarif' | 'motif_legitime'>('sans_engagement');
  const [contractNumber, setContractNumber] = useState('');
  const [copied, setCopied] = useState(false);

  if (!isOpen) return null;

  const guide = getCancellationGuide(targetName);
  const letter = generateCancellationLetter({
    senderName: profile.name || 'Prénom Nom',
    senderAddress: 'Adresse postale',
    senderCity: 'Code Postal Ville',
    serviceName: targetName,
    recipientEntity: guide?.legalEntityName || targetName,
    recipientAddress: guide?.postalAddress || 'Service Résiliation',
    reason,
    contractNumber: contractNumber || undefined
  });

  const handleCopy = () => {
    navigator.clipboard.writeText(letter);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-in fade-in duration-150">
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        className="w-full max-w-lg rounded-japandi-2xl bg-japandi-surface border border-japandi-border p-6 shadow-japandi-xl flex flex-col gap-5 max-h-[90vh] overflow-y-auto select-none"
      >
        {/* Header */}
        <div className="flex items-center justify-between pb-3 border-b border-japandi-border">
          <div className="flex items-center gap-3">
            <SubscriptionLogo
              name={targetName}
              logoUrl={subscription?.logoUrl}
              category={subscription?.category || 'Entertainment'}
              size={40}
            />
            <div>
              <h3 id={titleId} className="font-extrabold text-base text-japandi-text">
                {t('cancellation.title')} : {targetName}
              </h3>
              <p className="text-xs text-japandi-muted">
                {t('cancellation.subtitle')}
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

        {/* Tab Switcher */}
        <div
          role="tablist"
          aria-label={t('cancellation.title')}
          className="grid grid-cols-2 p-1 rounded-japandi-lg bg-japandi-elevated border border-japandi-border text-xs font-bold"
        >
          <button
            type="button"
            role="tab"
            aria-selected={activeTab === 'direct'}
            aria-controls="panel-direct"
            onClick={() => setActiveTab('direct')}
            className={`py-2 rounded-japandi-md transition-all flex items-center justify-center gap-2 ${
              activeTab === 'direct'
                ? 'bg-japandi-surface text-japandi-pine shadow-japandi-xs'
                : 'text-japandi-muted hover:text-japandi-text'
            }`}
          >
            <ExternalLink className="w-3.5 h-3.5" />
            <span>{t('cancellation.directLinkTitle')}</span>
          </button>
          <button
            type="button"
            role="tab"
            aria-selected={activeTab === 'letter'}
            aria-controls="panel-letter"
            onClick={() => setActiveTab('letter')}
            className={`py-2 rounded-japandi-md transition-all flex items-center justify-center gap-2 ${
              activeTab === 'letter'
                ? 'bg-japandi-surface text-japandi-pine shadow-japandi-xs'
                : 'text-japandi-muted hover:text-japandi-text'
            }`}
          >
            <FileText className="w-3.5 h-3.5" />
            <span>{t('cancellation.legalLetterTitle')}</span>
          </button>
        </div>

        {/* Tab Content: Direct Link */}
        {activeTab === 'direct' && (
          <div id="panel-direct" role="tabpanel" className="flex flex-col gap-4 animate-in fade-in duration-150">
            <div className="p-4 rounded-japandi-xl bg-japandi-sand/30 border border-japandi-border flex flex-col gap-2">
              <span className="text-xs font-bold text-japandi-text flex items-center gap-1.5">
                <Sparkles className="w-3.5 h-3.5 text-japandi-terracotta" />
                {t('cancellation.directLinkDesc')}
              </span>
              <p className="text-xs text-japandi-muted leading-relaxed">
                {guide?.tips || t('cancellation.threeClicksNotice')}
              </p>
            </div>

            <a
              href={guide?.directCancelUrl || `https://www.google.com/search?q=résilier+${encodeURIComponent(targetName)}`}
              target="_blank"
              rel="noopener noreferrer"
              className="w-full py-3 px-4 rounded-japandi-xl bg-japandi-pine hover:bg-japandi-pine/90 text-white font-bold text-xs flex items-center justify-center gap-2 shadow-japandi-sm transition-all"
            >
              <span>{t('cancellation.openOfficialPage')}</span>
              <ExternalLink className="w-4 h-4" />
            </a>

            {guide?.noticePeriodDays !== undefined && guide.noticePeriodDays > 0 && (
              <div className="flex items-center gap-2 text-xs text-japandi-muted px-1">
                <ShieldAlert className="w-4 h-4 text-japandi-terracotta" />
                <span>{t('cancellation.noticePeriod', { days: guide.noticePeriodDays })}</span>
              </div>
            )}
          </div>
        )}

        {/* Tab Content: Legal Letter Generator */}
        {activeTab === 'letter' && (
          <div id="panel-letter" role="tabpanel" className="flex flex-col gap-4 animate-in fade-in duration-150">
            <div className="flex flex-col gap-1.5">
              <label className="text-xs font-bold text-japandi-text">
                {t('cancellation.motive')}
              </label>
              <select
                value={reason}
                onChange={(e) => setReason(e.target.value as any)}
                className="w-full px-3 py-2 text-xs font-semibold rounded-japandi-md bg-japandi-elevated border border-japandi-border text-japandi-text focus:outline-none focus:ring-1 focus:ring-japandi-pine"
              >
                <option value="sans_engagement">{t('cancellation.motiveSansEngagement')}</option>
                <option value="echeance_chatel">{t('cancellation.motiveLoiChatel')}</option>
                <option value="hausse_tarif">{t('cancellation.motiveHausseTarif')}</option>
                <option value="motif_legitime">{t('cancellation.motiveLegitime')}</option>
              </select>
            </div>

            <div className="flex flex-col gap-1.5">
              <label className="text-xs font-bold text-japandi-text">
                {t('cancellation.contractNumber')}
              </label>
              <input
                type="text"
                placeholder="ex: AB-984210"
                value={contractNumber}
                onChange={(e) => setContractNumber(e.target.value)}
                className="w-full px-3 py-2 text-xs rounded-japandi-md bg-japandi-elevated border border-japandi-border text-japandi-text placeholder:text-japandi-subtle focus:outline-none focus:ring-1 focus:ring-japandi-pine"
              />
            </div>

            {/* Letter Preview Box */}
            <div className="flex flex-col gap-1.5">
              <div className="flex items-center justify-between">
                <label className="text-xs font-bold text-japandi-text">
                  {t('cancellation.generatedLetter')}
                </label>
                <button
                  type="button"
                  onClick={handleCopy}
                  className="text-xs font-bold text-japandi-pine hover:underline flex items-center gap-1"
                >
                  {copied ? (
                    <>
                      <Check className="w-3.5 h-3.5 text-japandi-pine" />
                      <span>{t('common.copied')}</span>
                    </>
                  ) : (
                    <>
                      <Copy className="w-3.5 h-3.5" />
                      <span>{t('common.copy')}</span>
                    </>
                  )}
                </button>
              </div>

              <textarea
                readOnly
                value={letter}
                rows={7}
                className="w-full p-3 text-xs font-mono rounded-japandi-xl bg-japandi-elevated border border-japandi-border text-japandi-text/90 resize-none focus:outline-none scrollbar-thin"
              />
            </div>

            <button
              type="button"
              onClick={handleCopy}
              className="w-full py-2.5 px-4 rounded-japandi-xl bg-japandi-elevated border border-japandi-border hover:border-japandi-pine text-japandi-text font-bold text-xs flex items-center justify-center gap-2 transition-all shadow-2xs"
            >
              <Copy className="w-3.5 h-3.5 text-japandi-pine" />
              <span>{t('cancellation.copyLetter')}</span>
            </button>
          </div>
        )}

        {/* Footer info */}
        <div className="pt-3 border-t border-japandi-border flex items-center justify-between text-[11px] text-japandi-muted">
          <span>{guide?.legalEntityName || targetName}</span>
          <span className="font-semibold text-japandi-pine">100% Gratuit & Conforme</span>
        </div>
      </div>
    </div>
  );
};
