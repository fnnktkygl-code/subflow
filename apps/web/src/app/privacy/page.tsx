'use client';

import React from 'react';
import Link from 'next/link';
import { ArrowLeft, ShieldCheck, Lock, EyeOff, Database, FileText } from 'lucide-react';

export default function PrivacyPolicyPage() {
  return (
    <div className="min-h-screen max-w-3xl mx-auto px-4 py-8 animate-in fade-in duration-200">
      <div className="mb-6">
        <Link
          href="/"
          className="inline-flex items-center gap-1.5 text-xs font-bold text-japandi-pine hover:underline"
        >
          <ArrowLeft className="w-4 h-4" />
          <span>Retour à SubFlow</span>
        </Link>
      </div>

      <div className="rounded-japandi-2xl bg-japandi-surface border border-japandi-border p-6 sm:p-10 shadow-japandi-sm flex flex-col gap-6 text-japandi-text">
        <div className="flex items-center gap-3 pb-4 border-b border-japandi-border">
          <div className="w-12 h-12 rounded-japandi-xl bg-japandi-pine/10 text-japandi-pine flex items-center justify-center">
            <ShieldCheck className="w-6 h-6" />
          </div>
          <div>
            <h1 className="text-xl sm:text-2xl font-extrabold text-japandi-text">
              Politique de Confidentialité
            </h1>
            <p className="text-xs text-japandi-muted">
              Dernière mise à jour : 28 août 2026 • Application SubFlow
            </p>
          </div>
        </div>

        <section className="flex flex-col gap-2.5">
          <h2 className="text-base font-bold text-japandi-text flex items-center gap-2">
            <Lock className="w-4 h-4 text-japandi-pine" />
            <span>1. Engagement Fondamental & Philosophie Privée</span>
          </h2>
          <p className="text-xs text-japandi-muted leading-relaxed">
            SubFlow est une application de gestion d'abonnements et de santé financière conçue selon les principes du design épuré et du respect absolu de la vie privée. <strong>Nous ne vendons, ne louons et ne partageons aucune de vos données personnelles ou financières avec des tiers à des fins publicitaires ou de traçage.</strong>
          </p>
        </section>

        <section className="flex flex-col gap-2.5">
          <h2 className="text-base font-bold text-japandi-text flex items-center gap-2">
            <Database className="w-4 h-4 text-japandi-pine" />
            <span>2. Données Collectées & Stockage</span>
          </h2>
          <p className="text-xs text-japandi-muted leading-relaxed">
            SubFlow fonctionne selon deux modes de stockage choisis souverainement par l'utilisateur :
          </p>
          <ul className="list-disc list-inside text-xs text-japandi-muted space-y-1.5 pl-2">
            <li>
              <strong>Mode Local (Hors-ligne) :</strong> Vos abonnements, montants et préférences sont stockés exclusivement dans la mémoire locale de votre navigateur ou de votre appareil.
            </li>
            <li>
              <strong>Mode Cloud Google Drive (Optionnel) :</strong> Lorsque vous vous connectez avec votre compte Google, une sauvegarde chiffrée de vos abonnements est enregistrée dans le dossier privé et isolé <code>appDataFolder</code> de votre propre compte Google Drive. SubFlow n'a aucun accès à vos autres fichiers, photos ou documents personnels Google Drive.
            </li>
          </ul>
        </section>

        <section className="flex flex-col gap-2.5">
          <h2 className="text-base font-bold text-japandi-text flex items-center gap-2">
            <EyeOff className="w-4 h-4 text-japandi-pine" />
            <span>3. Connexion Bancaire Open Banking (TrueLayer)</span>
          </h2>
          <p className="text-xs text-japandi-muted leading-relaxed">
            La synchronisation bancaire en direct utilise l'infrastructure agréée Open Banking / DSP2 de TrueLayer (établissement de paiement régulé). Vos identifiants bancaires ne transitent jamais et ne sont jamais stockés sur les serveurs de SubFlow. Seules les métadonnées de transactions récurrentes autorisées sont lues pour identifier automatiquement vos abonnements.
          </p>
        </section>

        <section className="flex flex-col gap-2.5">
          <h2 className="text-base font-bold text-japandi-text flex items-center gap-2">
            <FileText className="w-4 h-4 text-japandi-pine" />
            <span>4. Vos Droits & Suppression des Données</span>
          </h2>
          <p className="text-xs text-japandi-muted leading-relaxed">
            Conformément au RGPD et aux réglementations sur la protection des données, vous disposez d'un contrôle total :
          </p>
          <ul className="list-disc list-inside text-xs text-japandi-muted space-y-1 pl-2">
            <li>Vous pouvez supprimer l'intégralité de vos données en un clic depuis l'onglet Réglages (« Supprimer toutes les données »).</li>
            <li>Vous pouvez déconnecter votre compte Google Drive ou révoquer l'accès à tout moment depuis les paramètres de votre compte Google.</li>
          </ul>
        </section>

        <section className="pt-4 border-t border-japandi-border flex flex-col gap-1 text-xs text-japandi-muted">
          <span className="font-bold text-japandi-text">Contact Développeur :</span>
          <a href="mailto:contact.aadatech@gmail.com" className="text-japandi-pine hover:underline">
            contact.aadatech@gmail.com
          </a>
        </section>
      </div>
    </div>
  );
}
