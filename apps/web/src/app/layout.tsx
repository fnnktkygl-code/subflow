'use client';
import { usePathname } from 'next/navigation';
import React, { useState, useEffect } from 'react';

import './globals.css';
import { StorageNotice } from '../components/StorageNotice';
import { TopAppBar } from '../components/TopAppBar';
import { BottomDock } from '../components/BottomDock';
import { AddSubscriptionModal } from '../components/AddSubscriptionModal';

import { TooltipProvider } from '@subflow/ui';
import { useSubscriptionStore } from '../store/useSubscriptionStore';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const publicPage = pathname === '/' || pathname === '/demo';
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [mounted, setMounted] = useState(false);
  const { hasCompletedOnboarding, googleAccount, subscriptions } = useSubscriptionStore();

  useEffect(() => {
    setMounted(true);
  }, []);

  const isNewUserOnboarding = mounted && !hasCompletedOnboarding && !googleAccount && subscriptions.length === 0;

  return (
    <html lang="fr" className="h-full">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="google-site-verification" content="YKWehFN_AmBugQ2uUXgrVGdvtjmLQcr57gVJ59AeqyM" />

        <title>SubFlow — Vos prélèvements, en toute clarté</title>
        <meta name="description" content="Suivez vos abonnements et prélèvements, anticipez les échéances et simulez vos économies. Commencez gratuitement, sans compte bancaire." />

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
          {pathname !== '/demo' && <footer className="w-full border-t border-japandi-border/60 py-6 text-center text-xs text-japandi-muted bg-japandi-canvas/40 mt-auto">
            <div className="max-w-[1120px] mx-auto px-4 flex flex-col sm:flex-row items-center justify-between gap-3">
              <span>© {new Date().getFullYear()} SubFlow — Gestion sereine des abonnements</span>
              <div className="flex items-center gap-4">
                <a href="/privacy" className="hover:text-japandi-pine hover:underline">
                  Politique de confidentialité
                </a>
                <span>•</span>
                <a href="/terms" className="hover:text-japandi-pine hover:underline">
                  Conditions d'utilisation
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
        </TooltipProvider>
      </body>
    </html>
  );
}




