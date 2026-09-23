'use client';
import React, { useEffect, useState } from 'react';
import Dashboard from '../app/page';
import Subscriptions from '../subs/page';
import Schedule from '../schedule/page';
import { useSubscriptionStore } from '../../store/useSubscriptionStore';
import { AddSubscriptionModal } from '../../components/AddSubscriptionModal';
import { Plus, RotateCcw } from 'lucide-react';
import type { Subscription } from '@subflow/core';

export default function DemoPage() {
  const [ready, setReady] = useState(false);
  const [tab, setTab] = useState('overview');
  const [adding, setAdding] = useState(false);
  useEffect(() => {
    // The /demo document uses non-persistent storage; never seeds the user's account.
    const today = new Date();
    const date = (offset: number) => { const d = new Date(today); d.setDate(d.getDate() + offset); return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`; };
    const subscriptions: Subscription[] = [
      { id: 'demo-netflix', name: 'Netflix', amount: 13.49, cycle: 'Monthly', category: 'Entertainment', startDate: date(2), logoUrl: '/logos/netflix.svg' },
      { id: 'demo-spotify', name: 'Spotify', amount: 11.99, cycle: 'Monthly', category: 'Entertainment', startDate: date(5), logoUrl: '/logos/spotify.svg' },
      { id: 'demo-mobile', name: 'Forfait mobile', amount: 9.99, cycle: 'Monthly', category: 'Utilities', startDate: date(8), logoUrl: 'svg:smartphone' },
      { id: 'demo-sport', name: 'Salle de sport', amount: 29.90, cycle: 'Monthly', category: 'Health & Fitness', startDate: date(12) },
      { id: 'demo-cloud', name: 'Stockage cloud', amount: 24, cycle: 'Yearly', category: 'Productivity', startDate: date(20) }
    ].map(sub => ({ ...sub, status: 'active', currency: 'EUR', currencySymbol: '€' }));
    useSubscriptionStore.setState({ subscriptions, profile: { name: 'Camille', currency: 'EUR', currencySymbol: '€', countryCode: 'FR', monthlyIncome: 0, isIncomeConfigured: false, spendingGoal: 80, themeMode: 'light', language: 'fr' }, googleAccount: null, storageMode: 'local', hasCompletedOnboarding: true });
    const navigate = (event: MouseEvent) => {
      const link = (event.target as HTMLElement).closest('a');
      if (!link) return;
      event.preventDefault();
      if (link.pathname === '/schedule') setTab('schedule');
      if (link.pathname === '/subs') setTab('subs');
      if (link.pathname === '/app') setTab('overview');
    };
    document.addEventListener('click', navigate);
    setReady(true);
    return () => document.removeEventListener('click', navigate);
  }, []);
  if (!ready) return <p className="p-8" role="status">Préparation de la démonstration…</p>;
  return <div className="demo-app">
    <div className="demo-notice"><span>DÉMONSTRATION · DONNÉES FICTIVES</span><button onClick={() => window.location.reload()} aria-label="Réinitialiser la démonstration"><RotateCcw size={14}/></button></div>
    <header className="demo-app-header"><span className="landing-brand"><span className="brand-mark">∿</span>SubFlow.</span><button onClick={() => setAdding(true)} className="demo-add"><Plus size={17}/>Ajouter</button></header>
    <nav className="demo-tabs" aria-label="Navigation de la démonstration">{[['overview','Vue d’ensemble'],['subs','Prélèvements'],['schedule','Calendrier']].map(([key, label]) => <button key={key} aria-pressed={tab === key} onClick={() => setTab(key!)}>{label}</button>)}</nav>
    <div className="demo-content">{tab === 'overview' ? <Dashboard/> : tab === 'subs' ? <Subscriptions/> : <Schedule/>}</div>
    <AddSubscriptionModal isOpen={adding} onClose={() => setAdding(false)} allowBankSync={false}/>
  </div>;
}
