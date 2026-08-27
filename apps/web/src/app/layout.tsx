'use client';

import React, { useState } from 'react';
import './globals.css';
import { TopAppBar } from '../components/TopAppBar';
import { BottomDock } from '../components/BottomDock';
import { AddSubscriptionModal } from '../components/AddSubscriptionModal';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);

  return (
    <html lang="en" className="h-full">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
        <title>SubFlow — Mindful Subscription Management</title>
      </head>
      <body className="h-full bg-japandi-bg text-japandi-text font-sans antialiased selection:bg-japandi-pine selection:text-white flex flex-col min-h-screen">
        <TopAppBar />
        <main className="flex-1 w-full max-w-[1120px] mx-auto px-4 sm:px-6 pt-4 pb-32">
          {children}
        </main>
        <BottomDock onOpenAddModal={() => setIsAddModalOpen(true)} />
        <AddSubscriptionModal
          isOpen={isAddModalOpen}
          onClose={() => setIsAddModalOpen(false)}
        />
      </body>
    </html>
  );
}
