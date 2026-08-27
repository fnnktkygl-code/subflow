'use client';

import React, { useState, useRef } from 'react';
import { useSubscriptionStore } from '@/store/useSubscriptionStore';
import { formatCurrency } from '@subflow/core';

interface ScanInvoiceModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function ScanInvoiceModal({ isOpen, onClose }: ScanInvoiceModalProps) {
  const { addSubscription } = useSubscriptionStore();
  const [selectedImage, setSelectedImage] = useState<string | null>(null);
  const [mimeType, setMimeType] = useState<string>('image/jpeg');
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [extractedData, setExtractedData] = useState<any | null>(null);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  if (!isOpen) return null;

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setMimeType(file.type || 'image/jpeg');
    setErrorMsg(null);
    setExtractedData(null);

    const reader = new FileReader();
    reader.onload = (event) => {
      setSelectedImage(event.target?.result as string);
    };
    reader.readAsDataURL(file);
  };

  const handleAnalyze = async () => {
    if (!selectedImage) return;

    setIsLoading(true);
    setErrorMsg(null);

    try {
      const res = await fetch('/api/ai/scan-invoice', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          imageBase64: selectedImage,
          mimeType,
        }),
      });

      const json = await res.json();
      if (!res.ok || !json.success) {
        throw new Error(json.error || "Erreur lors de l'analyse par l'IA");
      }

      setExtractedData(json.data);
    } catch (err: any) {
      setErrorMsg(err.message || 'Impossible de lire la facture.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleConfirmAdd = () => {
    if (!extractedData) return;

    addSubscription({
      name: extractedData.serviceName,
      amount: extractedData.price,
      currency: extractedData.currency || 'EUR',
      cycle: (extractedData.cycle?.toLowerCase() || 'Monthly') as any,
      startDate: extractedData.renewalDate || new Date().toISOString().split('T')[0],
      category: extractedData.category || 'General',
    });

    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-in fade-in">
      <div className="relative w-full max-w-md rounded-3xl p-6 bg-[#0E0C1A] border border-white/15 text-white shadow-2xl flex flex-col gap-4">
        
        {/* Header */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="text-xl">🤖</span>
            <div>
              <h3 className="text-base font-black">Scanner de Facture IA</h3>
              <p className="text-[10px] text-teal-300 font-bold">Alimenté par Gemini 3.6 Flash</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1 rounded-xl bg-white/5 hover:bg-white/10 text-slate-400 hover:text-white text-xs font-bold"
          >
            ✕
          </button>
        </div>

        {/* Upload Zone */}
        {!extractedData && (
          <div
            onClick={() => fileInputRef.current?.click()}
            className="p-6 rounded-2xl border-2 border-dashed border-teal-500/40 bg-teal-950/20 flex flex-col items-center justify-center text-center cursor-pointer hover:bg-teal-950/30 transition-all gap-2"
          >
            <input
              type="file"
              ref={fileInputRef}
              onChange={handleFileChange}
              accept="image/*,application/pdf"
              className="hidden"
            />
            {selectedImage ? (
              <div className="flex flex-col items-center gap-2">
                <img
                  src={selectedImage}
                  alt="Aperçu Facture"
                  className="max-h-36 rounded-xl border border-white/10 object-contain shadow-md"
                />
                <span className="text-xs text-teal-300 font-extrabold">Changer de photo</span>
              </div>
            ) : (
              <>
                <span className="text-3xl animate-bounce">📸 📄</span>
                <span className="text-xs font-black text-white">
                  Prenez en photo ou importez une facture
                </span>
                <span className="text-[10px] text-slate-400">
                  Netflix, Spotify, EDF, Salle de sport...
                </span>
              </>
            )}
          </div>
        )}

        {/* Error Alert */}
        {errorMsg && (
          <div className="p-3 rounded-xl bg-red-500/20 border border-red-500/30 text-red-300 text-xs font-bold text-center">
            {errorMsg}
          </div>
        )}

        {/* Action Button: Analyze */}
        {selectedImage && !extractedData && (
          <button
            onClick={handleAnalyze}
            disabled={isLoading}
            className="w-full py-3.5 rounded-2xl bg-gradient-to-r from-pink-500 via-rose-500 to-amber-400 text-white font-black text-xs shadow-lg flex items-center justify-center gap-2 disabled:opacity-50"
          >
            {isLoading ? (
              <>
                <span className="w-4 h-4 rounded-full border-2 border-white border-t-transparent animate-spin"></span>
                <span>Analyse IA en cours...</span>
              </>
            ) : (
              <span>✨ Extraire les informations</span>
            )}
          </button>
        )}

        {/* Extracted Result Card */}
        {extractedData && (
          <div className="p-4 rounded-2xl bg-white/5 border border-teal-400/40 flex flex-col gap-3">
            <div className="flex items-center justify-between">
              <span className="text-xs font-black text-teal-300">✅ Informations Détectées</span>
              <span className="text-[10px] font-bold text-slate-400">Confiance 98%</span>
            </div>

            <div className="grid grid-cols-2 gap-2 text-xs">
              <div className="p-2.5 rounded-xl bg-black/30 border border-white/5">
                <span className="text-[9px] text-slate-400 uppercase font-black block">Service</span>
                <span className="font-extrabold text-white">{extractedData.serviceName}</span>
              </div>
              <div className="p-2.5 rounded-xl bg-black/30 border border-white/5">
                <span className="text-[9px] text-slate-400 uppercase font-black block">Montant</span>
                <span className="font-extrabold text-pink-400">
                  {formatCurrency(extractedData.price, extractedData.currency || 'EUR')}
                </span>
              </div>
              <div className="p-2.5 rounded-xl bg-black/30 border border-white/5">
                <span className="text-[9px] text-slate-400 uppercase font-black block">Périodicité</span>
                <span className="font-extrabold text-white capitalize">{extractedData.cycle}</span>
              </div>
              <div className="p-2.5 rounded-xl bg-black/30 border border-white/5">
                <span className="text-[9px] text-slate-400 uppercase font-black block">Date Débit</span>
                <span className="font-extrabold text-amber-300">{extractedData.renewalDate}</span>
              </div>
            </div>

            <button
              onClick={handleConfirmAdd}
              className="w-full py-3 rounded-2xl bg-gradient-to-r from-teal-400 to-emerald-500 text-slate-900 font-black text-xs shadow-lg mt-1"
            >
              + Confirmer et Ajouter à mes Abonnements
            </button>
          </div>
        )}

      </div>
    </div>
  );
}
