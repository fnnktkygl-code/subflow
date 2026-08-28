'use client';

import React from 'react';
import Link from 'next/link';
import { ArrowLeft, FileText, CheckCircle2, Shield, Scale } from 'lucide-react';

export default function TermsPage() {
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
            <Scale className="w-6 h-6" />
          </div>
          <div>
            <h1 className="text-xl sm:text-2xl font-extrabold text-japandi-text">
              Conditions Générales d'Utilisation
            </h1>
            <p className="text-xs text-japandi-muted">
              Dernière mise à jour : 28 août 2026 • Application SubFlow
            </p>
          </div>
        </div>

        <section className="flex flex-col gap-2.5">
          <h2 className="text-base font-bold text-japandi-text flex items-center gap-2">
            <CheckCircle2 className="w-4 h-4 text-japandi-pine" />
            <span>1. Présentation du Service</span>
          </h2>
          <p className="text-xs text-japandi-muted leading-relaxed">
            SubFlow est un outil personnel d'optimisation financière et de suivi des dépenses récurrentes (abonnements, services, forfaits). L'application permet à l'utilisateur de centraliser, simuler des économies (mode What-If), et recevoir des rappels avant chaque échéance de prélèvement.
          </p>
        </section>

        <section className="flex flex-col gap-2.5">
          <h2 className="text-base font-bold text-japandi-text flex items-center gap-2">
            <Shield className="w-4 h-4 text-japandi-pine" />
            <span>2. Utilisation & Responsabilité</span>
          </h2>
          <p className="text-xs text-japandi-muted leading-relaxed">
            SubFlow est fourni à titre informatif et d'aide à la gestion personnelle. Les simulations d'économies et les prévisions d'échéances sont calculées sur la base des données saisies par l'utilisateur ou synchronisées via les banques partenaires. L'utilisateur demeure seul responsable de la gestion de ses contrats d'abonnements et de ses décisions financières.
          </p>
        </section>

        <section className="flex flex-col gap-2.5">
          <h2 className="text-base font-bold text-japandi-text flex items-center gap-2">
            <FileText className="w-4 h-4 text-japandi-pine" />
            <span>3. Propriété Intellectuelle & Données</span>
          </h2>
          <p className="text-xs text-japandi-muted leading-relaxed">
            L'ensemble des interfaces, codes, designs et marques SubFlow sont la propriété exclusive de leur créateur. Vos données personnelles, historiques et listes d'abonnements restent votre entière propriété et ne sont jamais exploitées commercialement.
          </p>
        </section>

        <section className="pt-4 border-t border-japandi-border flex flex-col gap-1 text-xs text-japandi-muted">
          <span className="font-bold text-japandi-text">Contact & Assistance :</span>
          <a href="mailto:contact.aadatech@gmail.com" className="text-japandi-pine hover:underline">
            contact.aadatech@gmail.com
          </a>
        </section>
      </div>
    </div>
  );
}
