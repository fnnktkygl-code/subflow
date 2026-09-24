'use client';
import { pick } from '@subflow/core';
import { usePathname } from 'next/navigation';
import React, { useState, useEffect } from 'react';

import './globals.css';
import { StorageNotice } from '../components/StorageNotice';
import { TopAppBar } from '../components/TopAppBar';
import { BottomDock } from '../components/BottomDock';
import { AddSubscriptionModal } from '../components/AddSubscriptionModal';
import { UkoTraveler } from '../components/uko/UkoTraveler';

import { TooltipProvider } from '@subflow/ui';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { detectUserLanguage } from '@subflow/core';
import { useTranslation } from '../hooks/useTranslation';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  const { locale } = useTranslation();
  const pathname = usePathname();
  const publicPage = pathname === '/' || pathname === '/demo';
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [mounted, setMounted] = useState(false);
  const { hasCompletedOnboarding, googleAccount, subscriptions } = useSubscriptionStore();

  useEffect(() => {
    setMounted(true);
    // First visit: follow the browser language (fr, en or es) until the user picks one.
    const { profile, updateProfile } = useSubscriptionStore.getState();
    if (!profile.language) updateProfile({ language: detectUserLanguage() });
  }, []);

  const isNewUserOnboarding = mounted && !hasCompletedOnboarding && !googleAccount && subscriptions.length === 0;

  return (
    <html lang={locale} className="h-full">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
        <meta name="google-site-verification" content="YKWehFN_AmBugQ2uUXgrVGdvtjmLQcr57gVJ59AeqyM" />

        <title>{pick(locale, { fr: 'SubFlow — Vos prélèvements, en toute clarté', en: 'SubFlow — Your recurring payments, clearly', es: 'SubFlow — Tus cargos recurrentes, con claridad' })}</title>
        <link rel="icon" href="/favicon.png" type="image/png" />
        <meta name="description" content={pick(locale, { fr: 'Suivez vos abonnements et prélèvements, anticipez les échéances et simulez vos économies. Commencez gratuitement, sans compte bancaire.', en: 'Track your subscriptions and recurring payments, see what is coming and simulate your savings. Free to start, no bank account needed.', es: 'Sigue tus suscripciones y cargos recurrentes, anticipa los vencimientos y simula tu ahorro. Gratis para empezar, sin cuenta bancaria.' })} />

      </head>

      <body className="h-full bg-japandi-bg text-japandi-text font-sans antialiased selection:bg-japandi-pine selection:text-white flex flex-col min-h-screen">
        <TooltipProvider delayDuration={150}>
          {!publicPage && <TopAppBar />}
          {!publicPage && <StorageNotice />}
          <a href="#main-content" className="skip-link">Aller au contenu</a>
          <main id="main-content" className={publicPage ? "flex-1 w-full" : "flex-1 w-full max-w-[1120px] mx-auto px-4 sm:px-6 pt-4 pb-32"}>
            {children}
          </main>

          {/* Static Crawler & User Accessible Footer */}
          {pathname !== '/demo' && <footer className={`w-full border-t border-japandi-border/60 pt-6 text-center text-xs text-japandi-muted bg-japandi-canvas/40 mt-auto ${publicPage ? 'pb-6' : 'pb-[calc(7.5rem+env(safe-area-inset-bottom))] sm:pb-28'}`}>
            <div className="max-w-[1120px] mx-auto px-4 flex flex-col sm:flex-row items-center justify-between gap-3">
              <span>© {new Date().getFullYear()} SubFlow — {pick(locale, { fr: 'Gestion sereine des abonnements', en: 'Calm subscription management', es: 'Gestión tranquila de suscripciones' })}</span>
              <div className="flex items-center gap-4">
                <a href="/privacy" className="hover:text-japandi-pine hover:underline">
                  {pick(locale, { fr: 'Politique de confidentialité', en: 'Privacy policy', es: 'Política de privacidad' })}
                </a>
                <span>•</span>
                <a href="/terms" className="hover:text-japandi-pine hover:underline">
                  {pick(locale, { fr: 'Conditions d\'utilisation', en: 'Terms of use', es: 'Condiciones de uso' })}
                </a>
              </div>
            </div>
          </footer>}

          {mounted && !publicPage && (
            <BottomDock onOpenAddModal={() => setIsAddModalOpen(true)} />
          )}


          {!publicPage && <AddSubscriptionModal
            isOpen={isAddModalOpen}
            onClose={() => setIsAddModalOpen(false)}
          />}
          {mounted && !publicPage && <UkoTraveler />}
        </TooltipProvider>
      </body>
    </html>
  );
}




