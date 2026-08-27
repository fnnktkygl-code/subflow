'use client';

import React, { useState } from 'react';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useTranslation } from '../hooks/useTranslation';
import { useEscapeKey } from '../hooks/useEscapeKey';
import { X, ExternalLink, ShieldCheck, Copy, Check } from 'lucide-react';

interface CancellationArenaModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const CancellationArenaModal: React.FC<CancellationArenaModalProps> = ({ isOpen, onClose }) => {
  useEscapeKey(isOpen, onClose);
  const { subscriptions, profile } = useSubscriptionStore();
  const { format, locale } = useTranslation();

  const [selectedSubId, setSelectedSubId] = useState<string>(subscriptions[0]?.id || '');
  const [copiedLetter, setCopiedLetter] = useState(false);

  if (!isOpen) return null;

  const currentSub = subscriptions.find((s) => s.id === selectedSubId) || subscriptions[0];

  const getCancellationUrl = (name: string) => {
    const lower = name.toLowerCase();
    if (lower.includes('netflix')) return 'https://www.netflix.com/youraccount';
    if (lower.includes('spotify')) return 'https://www.spotify.com/account/subscription/';
    if (lower.includes('amazon') || lower.includes('prime')) return 'https://www.amazon.fr/mc/pipelines/cancellation';
    if (lower.includes('disney')) return 'https://www.disneyplus.com/account';
    if (lower.includes('chatgpt') || lower.includes('openai')) return 'https://chat.openai.com/#settings/Subscription';
    if (lower.includes('canal')) return 'https://client.canalplus.com/abonnements/';
    if (lower.includes('apple')) return 'https://support.apple.com/HT202039';
    if (lower.includes('youtube')) return 'https://www.youtube.com/paid_memberships';
    return `https://www.google.com/search?q=resilier+abonnement+${encodeURIComponent(name)}`;
  };

  const getLetterTemplate = () => {
    const today = new Date().toLocaleDateString(locale === 'fr' ? 'fr-FR' : 'en-US');
    const userName = profile.name || 'Titulaire du compte';
    const subName = currentSub?.name || 'Abonnement';
    const amount = currentSub ? format(currentSub.amount) : '';

    return `Objet : Demande de résiliation de contrat et révocation de prélèvement - Loi Chatel / Code de la Consommation

Date : ${today}
Émetteur : ${userName}
Destinataire : Service Client / Résiliation - ${subName}

Madame, Monsieur,

Par la présente, je vous informe de ma décision de résilier mon contrat d'abonnement au service ${subName} (montant : ${amount} / ${currentSub?.cycle || 'mensuel'}), conformément aux dispositions de l'article L. 215-1 du Code de la Consommation (Loi Chatel) et aux conditions générales d'utilisation.

Je vous demande de bien vouloir cesser tout prélèvement bancaire sur mes coordonnées bancaires à compter de la réception de cette notification.

Je vous remercie de me confirmer par écrit la bonne prise en compte de ma résiliation et la date effective d'interruption du service.

Veuillez agréer, Madame, Monsieur, l'expression de mes salutations distinguées.

${userName}`;
  };

  const handleCopyLetter = () => {
    navigator.clipboard.writeText(getLetterTemplate());
    setCopiedLetter(true);
    setTimeout(() => setCopiedLetter(false), 2500);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/75 backdrop-blur-md animate-in fade-in duration-200">
      <div
        role="dialog"
        aria-modal="true"
        className="w-full max-w-lg rounded-3xl bg-[#0D0B18] border border-pink-500/30 p-6 shadow-[0_20px_60px_rgba(255,46,99,0.35)] flex flex-col gap-5 text-white max-h-[90vh] overflow-y-auto"
      >
        {/* Header */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-10 h-10 rounded-2xl bg-gradient-to-tr from-pink-500 to-amber-500 p-0.5 flex items-center justify-center shadow-md">
              <div className="w-full h-full bg-[#161226] rounded-[14px] flex items-center justify-center text-lg">
                🥊
              </div>
            </div>
            <div>
              <h2 className="text-base font-black tracking-tight text-white">
                {locale === 'fr' ? 'Arène de Résiliation 1-Clic' : '1-Click Cancellation Arena'}
              </h2>
              <span className="text-[10px] font-bold text-pink-400 uppercase tracking-wider">
                Loi Chatel • Art. L. 215-1
              </span>
            </div>
          </div>

          <button
            type="button"
            onClick={onClose}
            aria-label="Fermer"
            className="p-2 rounded-xl bg-white/5 hover:bg-white/10 text-slate-400 hover:text-white transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Subscription Picker */}
        <div className="flex flex-col gap-2">
          <label className="text-xs font-black uppercase tracking-wider text-slate-400">
            {locale === 'fr' ? 'Sélectionnez le service à trancher :' : 'Select service to cancel:'}
          </label>
          <div className="flex gap-2 overflow-x-auto pb-1 scrollbar-none">
            {subscriptions.map((sub) => (
              <button
                key={sub.id}
                type="button"
                onClick={() => setSelectedSubId(sub.id)}
                className={`px-3 py-2 rounded-xl text-xs font-bold whitespace-nowrap transition-all flex items-center gap-2 border ${
                  (currentSub?.id === sub.id)
                    ? 'bg-gradient-to-r from-pink-500 to-rose-600 border-pink-400 text-white shadow-md'
                    : 'bg-white/5 border-white/10 text-slate-300 hover:bg-white/10'
                }`}
              >
                <span>{sub.name}</span>
                <span className="text-[10px] opacity-80">{format(sub.amount)}</span>
              </button>
            ))}
          </div>
        </div>

        {currentSub && (
          <>
            {/* Target Details Card */}
            <div className="p-4 rounded-2xl bg-gradient-to-b from-red-950/40 to-black/60 border border-red-500/30 flex flex-col gap-3">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="font-extrabold text-sm text-white">{currentSub.name}</h3>
                  <p className="text-xs font-bold text-pink-400 mt-0.5">
                    {format(currentSub.amount)} / {currentSub.cycle} • {format(currentSub.amount * (currentSub.cycle === 'yearly' ? 1 : 12))} / an
                  </p>
                </div>
                <span className="px-2.5 py-1 rounded-full bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 text-[10px] font-black">
                  ⭐ 3-Clics Direct
                </span>
              </div>

              {/* Direct Portal CTA */}
              <a
                href={getCancellationUrl(currentSub.name)}
                target="_blank"
                rel="noopener noreferrer"
                className="btn-3d-coral w-full py-3 rounded-xl font-black text-xs text-white flex items-center justify-center gap-2 text-center"
              >
                <span>🔗 Ouvrir la page de résiliation officielle</span>
                <ExternalLink className="w-4 h-4" />
              </a>
            </div>

            {/* Generated Registered Letter */}
            <div className="p-4 rounded-2xl bg-white/5 border border-white/10 flex flex-col gap-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <ShieldCheck className="w-4 h-4 text-teal-300" />
                  <h4 className="font-black text-xs text-white">
                    {locale === 'fr' ? 'Lettre Juridique Prête à l’Emploi' : 'Legal Cancellation Notice'}
                  </h4>
                </div>
                <button
                  type="button"
                  onClick={handleCopyLetter}
                  className="px-3 py-1.5 rounded-xl bg-white/10 hover:bg-white/20 text-xs font-bold text-teal-300 flex items-center gap-1.5 transition-all"
                >
                  {copiedLetter ? <Check className="w-3.5 h-3.5" /> : <Copy className="w-3.5 h-3.5 text-teal-300" />}
                  <span>{copiedLetter ? 'Copié !' : 'Copier le texte'}</span>
                </button>
              </div>

              <div className="p-3 rounded-xl bg-black/50 border border-white/5 text-[11px] font-mono text-slate-300 whitespace-pre-wrap max-h-36 overflow-y-auto leading-relaxed">
                {getLetterTemplate()}
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
};
