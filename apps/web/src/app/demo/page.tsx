'use client';

import React, { useEffect, useState, useRef, useCallback } from 'react';
import Dashboard from '../app/page';
import Subscriptions from '../subs/page';
import Schedule from '../schedule/page';
import { useSubscriptionStore } from '../../store/useSubscriptionStore';
import { AddSubscriptionModal } from '../../components/AddSubscriptionModal';
import { CancellationArenaModal } from '../../components/CancellationArenaModal';
import { Plus, RotateCcw, Play, Pause, Smartphone, Sparkles, SlidersHorizontal, Calendar, Zap, ShieldCheck } from 'lucide-react';
import type { Subscription } from '@subflow/core';

interface AutomodeScene {
  id: string;
  title: string;
  shortLabel: string;
  badge: string;
  tab: 'overview' | 'subs' | 'schedule';
  action?: () => void;
}

export default function DemoPage() {
  const [ready, setReady] = useState(false);
  const [tab, setTab] = useState<'overview' | 'subs' | 'schedule'>('overview');
  const [adding, setAdding] = useState(false);
  const [isCancellationOpen, setIsCancellationOpen] = useState(false);
  const [isEmbed, setIsEmbed] = useState(false);
  const [isAutomodeEnabled, setIsAutomodeEnabled] = useState(false);
  const [currentSceneIndex, setCurrentSceneIndex] = useState(0);
  const [isPlaying, setIsPlaying] = useState(true);
  const [isManualControl, setIsManualControl] = useState(false);

  const timerRef = useRef<NodeJS.Timeout | null>(null);

  // Setup seed subscriptions with official SVG logos and native SVGs
  useEffect(() => {
    const search = typeof window !== 'undefined' ? new URLSearchParams(window.location.search) : null;
    const embedParam = search?.get('embed') === '1' || search?.get('embed') === 'true';
    const automodeParam = search?.get('automode') === '1' || search?.get('automode') === 'true';

    setIsEmbed(embedParam);
    setIsAutomodeEnabled(automodeParam);

    const today = new Date();
    const date = (offset: number) => {
      const d = new Date(today);
      d.setDate(d.getDate() + offset);
      return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
    };

    const subscriptions: Subscription[] = [
      {
        id: 'demo-netflix',
        name: 'Netflix',
        amount: 13.49,
        cycle: 'Monthly',
        category: 'Entertainment',
        startDate: date(2),
        logoUrl: '/logos/netflix.svg'
      },
      {
        id: 'demo-spotify',
        name: 'Spotify',
        amount: 11.99,
        cycle: 'Monthly',
        category: 'Entertainment',
        startDate: date(5),
        logoUrl: '/logos/spotify.svg'
      },
      {
        id: 'demo-canal',
        name: 'Canal+',
        amount: 22.99,
        cycle: 'Monthly',
        category: 'Entertainment',
        startDate: date(10),
        logoUrl: '/logos/canal_plus.svg'
      },
      {
        id: 'demo-mobile',
        name: 'Forfait mobile',
        amount: 9.99,
        cycle: 'Monthly',
        category: 'Utilities',
        startDate: date(8),
        logoUrl: 'svg:smartphone'
      },
      {
        id: 'demo-sport',
        name: 'Salle de sport',
        amount: 29.90,
        cycle: 'Monthly',
        category: 'Health & Fitness',
        startDate: date(12),
        logoUrl: 'svg:dumbbell'
      },
      {
        id: 'demo-cloud',
        name: 'Stockage cloud',
        amount: 24,
        cycle: 'Yearly',
        category: 'Productivity',
        startDate: date(20),
        logoUrl: 'svg:cloud'
      }
    ].map((sub) => ({ ...sub, status: 'active', currency: 'EUR', currencySymbol: '€' } as Subscription));

    useSubscriptionStore.setState({
      subscriptions,
      profile: {
        name: 'Camille',
        currency: 'EUR',
        currencySymbol: '€',
        countryCode: 'FR',
        monthlyIncome: 0,
        isIncomeConfigured: false,
        spendingGoal: 80,
        themeMode: 'light',
        language: 'fr'
      },
      googleAccount: null,
      storageMode: 'local',
      hasCompletedOnboarding: true,
      isSelectionMode: false,
      excludedIds: []
    });

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

  // Automode scenes definition with actual store driver actions
  const SCENES: AutomodeScene[] = [
    {
      id: 'overview',
      title: 'Vue d\'ensemble & Budget',
      shortLabel: '01. Dashboard',
      badge: 'Vos prélèvements sous contrôle · 67,37 €/mois',
      tab: 'overview',
      action: () => {
        const store = useSubscriptionStore.getState();
        if (store.isSelectionMode) store.toggleSelectionMode();
        setAdding(false);
        setIsCancellationOpen(false);
      }
    },
    {
      id: 'whatif',
      title: 'Mode Simulation What-If',
      shortLabel: '02. Économies',
      badge: '-43,39 € / mois économisés en direct !',
      tab: 'overview',
      action: () => {
        const store = useSubscriptionStore.getState();
        if (!store.isSelectionMode) store.toggleSelectionMode();
        if (!store.excludedIds.includes('demo-netflix')) store.toggleExcludedId('demo-netflix');
        if (!store.excludedIds.includes('demo-sport')) store.toggleExcludedId('demo-sport');
        setAdding(false);
        setIsCancellationOpen(false);
      }
    },
    {
      id: 'schedule',
      title: 'Calendrier des Échéances',
      shortLabel: '03. Calendrier',
      badge: 'Zéro surprise en fin de mois · Calendrier prévisionnel',
      tab: 'schedule',
      action: () => {
        setAdding(false);
        setIsCancellationOpen(false);
      }
    },
    {
      id: 'add',
      title: 'Ajout & Vrais Logos de Marque',
      shortLabel: '04. Ajout & Logos',
      badge: 'Catalogue 350+ presets · Vrais logos vectoriels',
      tab: 'overview',
      action: () => {
        setIsCancellationOpen(false);
        setAdding(true);
      }
    },
    {
      id: 'loichatel',
      title: 'Assistant Loi Châtel',
      shortLabel: '05. Loi Châtel',
      badge: 'Résiliation en 3 clics · Modèle officiel certifié',
      tab: 'overview',
      action: () => {
        setAdding(false);
        setIsCancellationOpen(true);
      }
    }
  ];

  const applyScene = useCallback((index: number) => {
    const scene = SCENES[index];
    if (!scene) return;
    setTab(scene.tab);
    scene.action?.();
    setCurrentSceneIndex(index);

    // Notify parent window of scene update
    if (typeof window !== 'undefined' && window.parent) {
      window.parent.postMessage(
        {
          type: 'SUBFLOW_DEMO_SCENE_CHANGE',
          sceneIndex: index,
          badge: scene.badge,
          shortLabel: scene.shortLabel
        },
        '*'
      );
    }
  }, []);

  // Automode ticker
  useEffect(() => {
    if (!isAutomodeEnabled || !isPlaying || isManualControl) {
      if (timerRef.current) clearInterval(timerRef.current);
      return;
    }

    applyScene(currentSceneIndex);

    timerRef.current = setInterval(() => {
      setCurrentSceneIndex((prev) => {
        const next = (prev + 1) % SCENES.length;
        applyScene(next);
        return next;
      });
    }, 6000);

    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, [isAutomodeEnabled, isPlaying, isManualControl, currentSceneIndex, applyScene]);

  // Listen to postMessage from parent Hero component
  useEffect(() => {
    const handleMessage = (e: MessageEvent) => {
      if (!e.data || typeof e.data !== 'object') return;
      if (e.data.type === 'GOTO_SCENE' && typeof e.data.scene === 'number') {
        setIsManualControl(false);
        setIsPlaying(true);
        applyScene(e.data.scene);
      } else if (e.data.type === 'TOGGLE_PLAY') {
        setIsPlaying((p) => !p);
      } else if (e.data.type === 'TOGGLE_INTERACTIVE') {
        setIsManualControl((prev) => !prev);
      }
    };

    window.addEventListener('message', handleMessage);
    return () => window.removeEventListener('message', handleMessage);
  }, [applyScene]);

  if (!ready) {
    return (
      <div className="p-8 flex items-center justify-center min-h-[300px]" role="status">
        <div className="w-8 h-8 rounded-full border-2 border-[#1B3B2F] border-t-transparent animate-spin" />
      </div>
    );
  }

  const currentScene = SCENES[currentSceneIndex] ?? SCENES[0]!;

  return (
    <div className={`demo-app min-h-screen bg-[#FAF7F2] text-[#203E32] ${isEmbed ? 'p-0 text-sm' : ''}`}>
      {/* Top Banner (Desktop only) */}
      {!isEmbed && (
        <div className="demo-notice">
          <span>DÉMONSTRATION · APPLICATION RÉELLE (DONNÉES ISOLÉES)</span>
          <button
            onClick={() => window.location.reload()}
            aria-label="Réinitialiser la démonstration"
            className="p-1 hover:bg-[#D5DDCB] rounded-sm transition-all"
          >
            <RotateCcw size={14} />
          </button>
        </div>
      )}

      {/* Embedded Automode Pill Banner inside Phone */}
      {isEmbed && isAutomodeEnabled && (
        <div className="sticky top-0 z-40 bg-[#FAF7F2]/95 backdrop-blur-xs border-b border-[#E8E4DC] px-3 py-1.5 flex items-center justify-between text-[11px] shadow-2xs">
          <div className="flex items-center gap-1.5 min-w-0">
            <span
              className={`w-2 h-2 rounded-full flex-shrink-0 ${
                isManualControl ? 'bg-amber-500' : isPlaying ? 'bg-emerald-500 animate-pulse' : 'bg-gray-400'
              }`}
            />
            <span className="font-bold text-[#1B3B2F] truncate text-[10px]">
              {isManualControl ? '🖐️ Mode direct actif' : `✨ ${currentScene?.shortLabel ?? ''}`}
            </span>
          </div>

          <div className="flex items-center gap-1">
            <button
              type="button"
              onClick={() => setIsPlaying((p) => !p)}
              className="p-1 rounded-full bg-white border border-[#E8E4DC] text-[#1B3B2F] hover:bg-[#F3EFE6] transition-all"
              title={isPlaying ? 'Mettre en pause' : 'Reprendre'}
            >
              {isPlaying ? <Pause size={11} /> : <Play size={11} className="fill-current" />}
            </button>

            <button
              type="button"
              onClick={() => {
                const next = !isManualControl;
                setIsManualControl(next);
                if (next) {
                  setIsPlaying(false);
                } else {
                  setIsPlaying(true);
                }
              }}
              className={`px-2 py-0.5 rounded-full text-[10px] font-bold transition-all ${
                isManualControl
                  ? 'bg-emerald-600 text-white shadow-xs'
                  : 'bg-[#1B3B2F] text-[#F5EFE6] hover:bg-[#2A5443]'
              }`}
            >
              {isManualControl ? 'Reprendre l\'Auto' : 'Prendre la main'}
            </button>
          </div>
        </div>
      )}

      {/* Main Header inside Application */}
      <header className={`demo-app-header ${isEmbed ? 'py-2 px-3.5 border-b border-[#E8E4DC]' : ''}`}>
        <span className="landing-brand text-base sm:text-lg font-bold">
          <span className="brand-mark w-7 h-7 text-2xl">∿</span>SubFlow.
        </span>

        <div className="flex items-center gap-2">
          <button
            onClick={() => setAdding(true)}
            className="demo-add text-xs py-1.5 px-3 rounded-lg flex items-center gap-1.5 shadow-xs font-semibold"
          >
            <Plus size={15} />
            <span>Ajouter</span>
          </button>
        </div>
      </header>

      {/* Navigation Tabs (Overview, Subs, Schedule) */}
      <nav className={`demo-tabs ${isEmbed ? 'px-3 py-1.5' : ''}`} aria-label="Navigation de la démonstration">
        {[
          ['overview', 'Vue d’ensemble'],
          ['subs', 'Prélèvements'],
          ['schedule', 'Calendrier']
        ].map(([key, label]) => (
          <button
            key={key}
            aria-pressed={tab === key}
            onClick={() => {
              setIsManualControl(true);
              setIsPlaying(false);
              setTab(key as any);
            }}
            className={isEmbed ? 'text-[11px] py-1 px-2.5 rounded-full' : ''}
          >
            {label}
          </button>
        ))}
      </nav>

      {/* Main Active Application View */}
      <div className={`demo-content ${isEmbed ? 'p-3' : ''}`}>
        {tab === 'overview' ? <Dashboard /> : tab === 'subs' ? <Subscriptions /> : <Schedule />}
      </div>

      {/* Real Modals of the Application */}
      <AddSubscriptionModal
        isOpen={adding}
        onClose={() => setAdding(false)}
        allowBankSync={false}
      />

      <CancellationArenaModal
        isOpen={isCancellationOpen}
        onClose={() => setIsCancellationOpen(false)}
      />
    </div>
  );
}
