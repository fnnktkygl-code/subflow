'use client';

import React, { useState, useEffect, useRef } from 'react';
import Link from 'next/link';
import {
  Play,
  Pause,
  RotateCcw,
  Sparkles,
  SlidersHorizontal,
  Calendar,
  Plus,
  FileText,
  Check,
  ArrowRight,
  TrendingDown,
  Shield,
  Zap,
  ExternalLink,
  Smartphone,
  MousePointerClick
} from 'lucide-react';

interface Scene {
  id: string;
  title: string;
  shortLabel: string;
  badge: string;
  badgeSub: string;
  badgeIcon: React.ReactNode;
}

const SCENES: Scene[] = [
  {
    id: 'overview',
    title: 'Vue d\'ensemble & Budget',
    shortLabel: '01. Dashboard',
    badge: 'Vos prélèvements sous contrôle',
    badgeSub: 'Coût mensuel consolidé · 68,40 €/mois',
    badgeIcon: <Zap className="w-3.5 h-3.5 text-amber-400 fill-amber-400" />
  },
  {
    id: 'whatif',
    title: 'Mode Simulation What-If',
    shortLabel: '02. Économies',
    badge: '-43,48 € / mois économisés !',
    badgeSub: 'Simulez en 2 clics sans résilier',
    badgeIcon: <TrendingDown className="w-3.5 h-3.5 text-emerald-400" />
  },
  {
    id: 'schedule',
    title: 'Calendrier des Échéances',
    shortLabel: '03. Calendrier',
    badge: 'Zéro surprise en fin de mois',
    badgeSub: 'Voyez exactement quand chaque débit arrive',
    badgeIcon: <Calendar className="w-3.5 h-3.5 text-sky-400" />
  },
  {
    id: 'add',
    title: 'Ajout & Logo Vectoriel',
    shortLabel: '04. Ajout & Logo',
    badge: 'Logo intégré & Icônes SVG',
    badgeSub: 'Détection instantanée et personnalisation',
    badgeIcon: <Sparkles className="w-3.5 h-3.5 text-purple-400" />
  },
  {
    id: 'cancellation',
    title: 'Résiliation Loi Chatel',
    shortLabel: '05. Loi Chatel',
    badge: 'Résiliation 1-clic pré-remplie',
    badgeSub: 'Modèle juridique certifié & lien direct',
    badgeIcon: <Shield className="w-3.5 h-3.5 text-emerald-400" />
  }
];

const SCENE_DURATION_MS = 5000;

export const HeroMobileAdSimulator: React.FC = () => {
  const [currentSceneIndex, setCurrentSceneIndex] = useState(0);
  const [isPlaying, setIsPlaying] = useState(true);
  const [progress, setProgress] = useState(0);
  const [isInteractiveMode, setIsInteractiveMode] = useState(false);

  // Interactive state (when visitor tests on their own or simulated actions trigger)
  const [activeTab, setActiveTab] = useState<'overview' | 'schedule' | 'subs'>('overview');
  const [whatIfActive, setWhatIfActive] = useState(false);
  const [excludedIds, setExcludedIds] = useState<string[]>([]);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [isCancelModalOpen, setIsCancelModalOpen] = useState(false);
  const [addNameInput, setAddNameInput] = useState('');
  const [tapPosition, setTapPosition] = useState<{ x: number; y: number; visible: boolean }>({ x: 0, y: 0, visible: false });

  const timerRef = useRef<NodeJS.Timeout | null>(null);
  const progressIntervalRef = useRef<NodeJS.Timeout | null>(null);

  const scene = SCENES[currentSceneIndex] ?? SCENES[0]!;

  // Trigger simulated actions per scene during Auto-Play Mode
  useEffect(() => {
    if (isInteractiveMode || !isPlaying) return;

    // Reset modals and state per scene entry
    if (currentSceneIndex === 0) {
      // Scene 1: Overview
      setActiveTab('overview');
      setWhatIfActive(false);
      setExcludedIds([]);
      setIsAddModalOpen(false);
      setIsCancelModalOpen(false);
      setAddNameInput('');
    } else if (currentSceneIndex === 1) {
      // Scene 2: What-If mode
      setActiveTab('overview');
      setIsAddModalOpen(false);
      setIsCancelModalOpen(false);

      // Simulate tapping "Mode Simulation" then excluding Netflix + Basic Fit
      const t1 = setTimeout(() => {
        setTapPosition({ x: 75, y: 35, visible: true });
        setWhatIfActive(true);
      }, 700);

      const t2 = setTimeout(() => {
        setTapPosition({ x: 50, y: 55, visible: true });
        setExcludedIds(['sub-netflix']);
      }, 1800);

      const t3 = setTimeout(() => {
        setTapPosition({ x: 50, y: 75, visible: true });
        setExcludedIds(['sub-netflix', 'sub-basicfit']);
      }, 2900);

      const tClear = setTimeout(() => {
        setTapPosition((p) => ({ ...p, visible: false }));
      }, 3600);

      return () => {
        clearTimeout(t1);
        clearTimeout(t2);
        clearTimeout(t3);
        clearTimeout(tClear);
      };
    } else if (currentSceneIndex === 2) {
      // Scene 3: Schedule
      setWhatIfActive(false);
      setIsAddModalOpen(false);
      setIsCancelModalOpen(false);
      const tNav = setTimeout(() => {
        setTapPosition({ x: 50, y: 92, visible: true });
        setActiveTab('schedule');
      }, 800);
      const tClear = setTimeout(() => {
        setTapPosition((p) => ({ ...p, visible: false }));
      }, 1600);
      return () => {
        clearTimeout(tNav);
        clearTimeout(tClear);
      };
    } else if (currentSceneIndex === 3) {
      // Scene 4: Add modal & logo detection
      setActiveTab('overview');
      setIsCancelModalOpen(false);
      const tOpen = setTimeout(() => {
        setTapPosition({ x: 86, y: 15, visible: true });
        setIsAddModalOpen(true);
      }, 600);
      const tType1 = setTimeout(() => {
        setAddNameInput('Salle');
      }, 1500);
      const tType2 = setTimeout(() => {
        setAddNameInput('Salle de sport');
      }, 2300);
      const tClear = setTimeout(() => {
        setTapPosition((p) => ({ ...p, visible: false }));
      }, 3100);
      return () => {
        clearTimeout(tOpen);
        clearTimeout(tType1);
        clearTimeout(tType2);
        clearTimeout(tClear);
      };
    } else if (currentSceneIndex === 4) {
      // Scene 5: Cancellation Assistant
      setActiveTab('overview');
      setIsAddModalOpen(false);
      const tOpenCancel = setTimeout(() => {
        setTapPosition({ x: 75, y: 68, visible: true });
        setIsCancelModalOpen(true);
      }, 1000);
      const tClear = setTimeout(() => {
        setTapPosition((p) => ({ ...p, visible: false }));
      }, 2000);
      return () => {
        clearTimeout(tOpenCancel);
        clearTimeout(tClear);
      };
    }
  }, [currentSceneIndex, isPlaying, isInteractiveMode]);

  // Story progress bar ticker
  useEffect(() => {
    if (isInteractiveMode || !isPlaying) return;

    const intervalStep = 50;
    const progressIncrement = (intervalStep / SCENE_DURATION_MS) * 100;

    progressIntervalRef.current = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 100) {
          setCurrentSceneIndex((idx) => (idx + 1) % SCENES.length);
          return 0;
        }
        return prev + progressIncrement;
      });
    }, intervalStep);

    return () => {
      if (progressIntervalRef.current) clearInterval(progressIntervalRef.current);
    };
  }, [isPlaying, isInteractiveMode, currentSceneIndex]);

  const handleJumpToScene = (index: number) => {
    setCurrentSceneIndex(index);
    setProgress(0);
    setIsPlaying(true);
    setIsInteractiveMode(false);
  };

  const handleTogglePlay = () => {
    setIsPlaying(!isPlaying);
  };

  const handleToggleInteractive = () => {
    const next = !isInteractiveMode;
    setIsInteractiveMode(next);
    if (next) {
      setIsPlaying(false);
      setTapPosition((p) => ({ ...p, visible: false }));
    } else {
      setIsPlaying(true);
      setProgress(0);
    }
  };

  // Dynamic amounts based on What-If exclusions
  const baseMonthly = 68.40;
  const isNetflixExcluded = excludedIds.includes('sub-netflix');
  const isBasicFitExcluded = excludedIds.includes('sub-basicfit');
  const savingsMonthly = (isNetflixExcluded ? 13.49 : 0) + (isBasicFitExcluded ? 29.99 : 0);
  const currentMonthly = baseMonthly - savingsMonthly;

  return (
    <div className="relative w-full flex flex-col items-center">
      {/* Top Controls & Story Progress Bar (Instagram / TikTok Style) */}
      <div className="w-full max-w-[340px] mb-3 flex flex-col gap-2 z-20">
        {/* 5-Segment Story Progress Bars */}
        <div className="flex gap-1.5 w-full px-1">
          {SCENES.map((s, idx) => {
            const isPast = idx < currentSceneIndex;
            const isCurrent = idx === currentSceneIndex;
            return (
              <button
                key={s.id}
                type="button"
                onClick={() => handleJumpToScene(idx)}
                className="h-1.5 flex-1 rounded-full bg-[#1B3B2F]/20 overflow-hidden relative transition-all hover:h-2"
                title={s.title}
                aria-label={`Aller à ${s.title}`}
              >
                <div
                  className="h-full bg-[#1B3B2F] rounded-full transition-all"
                  style={{
                    width: isPast ? '100%' : isCurrent ? `${progress}%` : '0%'
                  }}
                />
              </button>
            );
          })}
        </div>

        {/* Story Controls Toolbar */}
        <div className="flex items-center justify-between px-1 text-[11px]">
          <div className="flex items-center gap-1.5">
            <button
              type="button"
              onClick={handleTogglePlay}
              className="px-2 py-1 rounded-full bg-[#1B3B2F] text-[#F5EFE6] font-semibold flex items-center gap-1 hover:bg-[#2A5443] transition-all shadow-xs"
              title={isPlaying ? 'Mettre en pause' : 'Lecture'}
            >
              {isPlaying ? <Pause className="w-3 h-3" /> : <Play className="w-3 h-3 fill-current" />}
              <span>{isPlaying ? 'Pause' : 'Lire'}</span>
            </button>

            <button
              type="button"
              onClick={() => handleJumpToScene(0)}
              className="p-1 rounded-full bg-white/70 text-[#1B3B2F] hover:bg-white transition-all shadow-xs"
              title="Recommencer depuis le début"
            >
              <RotateCcw className="w-3 h-3" />
            </button>
          </div>

          {/* Interactive Mode Toggle */}
          <button
            type="button"
            onClick={handleToggleInteractive}
            className={`px-2.5 py-1 rounded-full text-[11px] font-bold transition-all flex items-center gap-1.5 shadow-xs ${
              isInteractiveMode
                ? 'bg-emerald-600 text-white ring-2 ring-emerald-400'
                : 'bg-white/80 text-[#1B3B2F] hover:bg-white'
            }`}
          >
            <Smartphone className="w-3 h-3" />
            <span>{isInteractiveMode ? 'Mode Interactif' : 'Tester en Direct'}</span>
          </button>
        </div>
      </div>

      {/* Realistic Mobile Smartphone Frame (iPhone Aspect Ratio) */}
      <div className="relative w-full max-w-[325px] sm:max-w-[340px] aspect-[9/18.8] bg-[#1B3B2F] rounded-[44px] p-2.5 shadow-[0_25px_60px_-15px_rgba(27,59,47,0.35),0_0_0_1px_rgba(27,59,47,0.15)] border-[3px] border-[#2A5443]/40 flex flex-col items-center select-none overflow-hidden group">
        {/* Dynamic Island with SubFlow Heartbeat */}
        <div className="w-full px-5 pt-1.5 pb-2 flex items-center justify-between text-[#F5EFE6] text-[11px] font-semibold z-30">
          <span className="font-mono text-[10px]">09:41</span>

          {/* Pill Notch */}
          <div className="w-24 h-5 bg-black/90 rounded-full flex items-center justify-between px-2.5 shadow-inner">
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
            <span className="text-[9px] text-[#F5EFE6]/90 font-medium tracking-tight">SubFlow</span>
            <span className="w-2 h-2 rounded-full bg-[#1B3B2F] border border-white/20" />
          </div>

          <div className="flex items-center gap-1.5 text-[10px]">
            <span className="text-[9px] font-bold">5G</span>
            <div className="w-4 h-2 border border-[#F5EFE6] rounded-xs p-0.5 flex items-center">
              <div className="w-full h-full bg-[#F5EFE6] rounded-2xs" />
            </div>
          </div>
        </div>

        {/* Screen Viewport (SubFlow Application Live Render) */}
        <div className="w-full flex-1 bg-[#FAF7F2] rounded-[32px] overflow-hidden relative flex flex-col shadow-inner">
          {/* Simulated Touch Finger Ripple Indicator during Video Mode */}
          {tapPosition.visible && !isInteractiveMode && (
            <div
              className="absolute z-50 pointer-events-none transition-all duration-300 transform -translate-x-1/2 -translate-y-1/2"
              style={{ left: `${tapPosition.x}%`, top: `${tapPosition.y}%` }}
            >
              <div className="relative flex items-center justify-center">
                <span className="w-8 h-8 rounded-full bg-[#1B3B2F]/30 animate-ping absolute" />
                <span className="w-6 h-6 rounded-full bg-[#1B3B2F]/60 border-2 border-white shadow-md flex items-center justify-center">
                  <span className="w-2 h-2 rounded-full bg-white" />
                </span>
              </div>
            </div>
          )}

          {/* Screen Header inside Phone */}
          <div className="px-3.5 pt-3 pb-2 bg-[#FAF7F2] border-b border-[#E8E4DC] flex items-center justify-between flex-shrink-0">
            <div className="flex items-center gap-1.5">
              <span className="w-6 h-6 rounded-lg bg-[#1B3B2F] text-[#FAF7F2] font-serif font-bold text-sm flex items-center justify-center">
                ∿
              </span>
              <span className="font-bold text-xs text-[#1B3B2F]">SubFlow</span>
            </div>

            <div className="flex items-center gap-1.5">
              <button
                type="button"
                onClick={() => setWhatIfActive(!whatIfActive)}
                className={`px-2 py-0.5 rounded-full text-[10px] font-bold transition-all flex items-center gap-1 ${
                  whatIfActive
                    ? 'bg-emerald-600 text-white shadow-xs'
                    : 'bg-[#E8E4DC] text-[#1B3B2F] hover:bg-[#DED9CE]'
                }`}
              >
                <SlidersHorizontal className="w-2.5 h-2.5" />
                <span>Simulation</span>
              </button>

              <button
                type="button"
                onClick={() => setIsAddModalOpen(true)}
                className="w-6 h-6 rounded-full bg-[#1B3B2F] text-white flex items-center justify-center shadow-xs hover:bg-[#2A5443] transition-colors"
                title="Ajouter un abonnement"
              >
                <Plus className="w-3.5 h-3.5" />
              </button>
            </div>
          </div>

          {/* Screen Content Body (Tabs) */}
          <div className="flex-1 overflow-y-auto px-3.5 py-2.5 flex flex-col gap-2.5 scrollbar-none">
            {/* What-If Live Savings Callout Banner */}
            {whatIfActive && (
              <div className="p-2.5 rounded-xl bg-emerald-50 border border-emerald-300 flex items-center justify-between animate-in fade-in zoom-in-95 duration-200">
                <div className="flex items-center gap-2">
                  <div className="w-7 h-7 rounded-lg bg-emerald-600 text-white flex items-center justify-center flex-shrink-0">
                    <TrendingDown className="w-4 h-4" />
                  </div>
                  <div>
                    <span className="text-[10px] font-bold text-emerald-900 block leading-tight">
                      Économie : +{savingsMonthly.toFixed(2)} €/mois
                    </span>
                    <span className="text-[9px] text-emerald-700">
                      Soit +{(savingsMonthly * 12).toFixed(0)} € par an épargnés
                    </span>
                  </div>
                </div>
                <span className="text-[9px] font-bold bg-emerald-200 text-emerald-900 px-1.5 py-0.5 rounded-md">
                  {excludedIds.length} écartés
                </span>
              </div>
            )}

            {/* TAB 1: OVERVIEW */}
            {activeTab === 'overview' && (
              <>
                {/* Total Monthly Card */}
                <div className="p-3 rounded-2xl bg-white border border-[#E8E4DC] shadow-xs flex flex-col gap-1.5">
                  <div className="flex items-center justify-between text-[10px] text-[#666B60]">
                    <span className="uppercase tracking-wider font-semibold">Total récurrent mensuel</span>
                    <span className="font-bold text-emerald-700 bg-emerald-50 px-1.5 py-0.5 rounded">
                      Budget 80 €
                    </span>
                  </div>
                  <div className="flex items-baseline gap-1">
                    <span className="text-2xl font-extrabold text-[#1B3B2F] tracking-tight">
                      {currentMonthly.toFixed(2)} €
                    </span>
                    <span className="text-[11px] text-[#666B60]">/ mois</span>
                  </div>

                  {/* Progress Bar */}
                  <div className="w-full h-1.5 rounded-full bg-[#E8E4DC] overflow-hidden mt-1">
                    <div
                      className="h-full rounded-full transition-all duration-500 bg-[#1B3B2F]"
                      style={{ width: `${Math.min((currentMonthly / 80) * 100, 100)}%` }}
                    />
                  </div>
                </div>

                {/* Subscriptions List */}
                <div className="flex flex-col gap-1.5">
                  <span className="text-[10px] font-bold uppercase tracking-wider text-[#666B60] px-0.5">
                    Abonnements actifs (5)
                  </span>

                  {/* Item 1: Netflix */}
                  <div
                    onClick={() => {
                      if (whatIfActive) {
                        setExcludedIds((prev) =>
                          isNetflixExcluded ? prev.filter((id) => id !== 'sub-netflix') : [...prev, 'sub-netflix']
                        );
                      }
                    }}
                    className={`p-2 rounded-xl border transition-all flex items-center justify-between cursor-pointer ${
                      isNetflixExcluded
                        ? 'bg-[#E8E4DC]/40 border-dashed border-[#C8C4BC] opacity-50'
                        : 'bg-white border-[#E8E4DC] hover:border-[#1B3B2F]'
                    }`}
                  >
                    <div className="flex items-center gap-2">
                      <div className="w-7 h-7 rounded-lg bg-black text-white flex items-center justify-center font-bold text-xs">
                        N
                      </div>
                      <div>
                        <span className="text-[11px] font-bold text-[#1B3B2F] block leading-tight">Netflix</span>
                        <span className="text-[9px] text-[#666B60]">Prélèvement le 14 du mois</span>
                      </div>
                    </div>
                    <div className="text-right">
                      <span className={`text-[11px] font-bold block ${isNetflixExcluded ? 'line-through text-neutral-400' : 'text-[#1B3B2F]'}`}>
                        13,49 €
                      </span>
                      {whatIfActive && (
                        <span className="text-[8px] font-bold text-emerald-700">
                          {isNetflixExcluded ? 'Écarté' : 'Actif'}
                        </span>
                      )}
                    </div>
                  </div>

                  {/* Item 2: Spotify */}
                  <div className="p-2 rounded-xl bg-white border border-[#E8E4DC] flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div className="w-7 h-7 rounded-lg bg-[#1DB954] text-black flex items-center justify-center font-bold text-xs">
                        ♫
                      </div>
                      <div>
                        <span className="text-[11px] font-bold text-[#1B3B2F] block leading-tight">Spotify Premium</span>
                        <span className="text-[9px] text-[#666B60]">Prélèvement le 18 du mois</span>
                      </div>
                    </div>
                    <span className="text-[11px] font-bold text-[#1B3B2F]">11,99 €</span>
                  </div>

                  {/* Item 3: Basic-Fit */}
                  <div
                    onClick={() => {
                      if (whatIfActive) {
                        setExcludedIds((prev) =>
                          isBasicFitExcluded ? prev.filter((id) => id !== 'sub-basicfit') : [...prev, 'sub-basicfit']
                        );
                      }
                    }}
                    className={`p-2 rounded-xl border transition-all flex items-center justify-between cursor-pointer ${
                      isBasicFitExcluded
                        ? 'bg-[#E8E4DC]/40 border-dashed border-[#C8C4BC] opacity-50'
                        : 'bg-white border-[#E8E4DC] hover:border-[#1B3B2F]'
                    }`}
                  >
                    <div className="flex items-center gap-2">
                      <div className="w-7 h-7 rounded-lg bg-[#FF6200] text-white flex items-center justify-center font-bold text-xs">
                        BF
                      </div>
                      <div>
                        <span className="text-[11px] font-bold text-[#1B3B2F] block leading-tight">Salle de sport</span>
                        <span className="text-[9px] text-[#666B60]">Prélèvement le 28 du mois</span>
                      </div>
                    </div>
                    <div className="text-right">
                      <span className={`text-[11px] font-bold block ${isBasicFitExcluded ? 'line-through text-neutral-400' : 'text-[#1B3B2F]'}`}>
                        29,99 €
                      </span>
                      {whatIfActive && (
                        <span className="text-[8px] font-bold text-emerald-700">
                          {isBasicFitExcluded ? 'Écarté' : 'Actif'}
                        </span>
                      )}
                    </div>
                  </div>

                  {/* Item 4: Forfait Mobile */}
                  <div className="p-2 rounded-xl bg-white border border-[#E8E4DC] flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div className="w-7 h-7 rounded-lg bg-[#4285F4] text-white flex items-center justify-center font-bold text-xs">
                        📱
                      </div>
                      <div>
                        <span className="text-[11px] font-bold text-[#1B3B2F] block leading-tight">Forfait Mobile 5G</span>
                        <span className="text-[9px] text-[#666B60]">Prélèvement le 02 du mois</span>
                      </div>
                    </div>
                    <span className="text-[11px] font-bold text-[#1B3B2F]">9,99 €</span>
                  </div>
                </div>
              </>
            )}

            {/* TAB 2: SCHEDULE (CALENDAR) */}
            {activeTab === 'schedule' && (
              <div className="flex flex-col gap-2.5 animate-in fade-in duration-200">
                <div className="p-2.5 rounded-xl bg-white border border-[#E8E4DC] flex items-center justify-between">
                  <div>
                    <span className="text-[11px] font-bold text-[#1B3B2F] block">Septembre 2026</span>
                    <span className="text-[9px] text-[#666B60]">4 échéances programmées</span>
                  </div>
                  <span className="text-[10px] font-bold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
                    Anticipé à 100%
                  </span>
                </div>

                {/* Mini Calendar Grid */}
                <div className="p-2.5 rounded-xl bg-white border border-[#E8E4DC]">
                  <div className="grid grid-cols-7 gap-1 text-center text-[9px] font-bold text-[#666B60] mb-1.5">
                    <span>L</span><span>M</span><span>M</span><span>J</span><span>V</span><span>S</span><span>D</span>
                  </div>
                  <div className="grid grid-cols-7 gap-1 text-center text-[9px]">
                    <span className="text-neutral-300 py-1">31</span>
                    <span className="py-1">1</span>
                    <span className="py-1 relative font-bold text-[#1B3B2F] bg-amber-50 rounded">
                      2
                      <span className="w-1 h-1 rounded-full bg-amber-500 mx-auto block mt-0.5" />
                    </span>
                    <span className="py-1">3</span><span className="py-1">4</span><span className="py-1">5</span><span className="py-1">6</span>
                    <span className="py-1">7</span><span className="py-1">8</span><span className="py-1">9</span><span className="py-1">10</span><span className="py-1">11</span><span className="py-1">12</span><span className="py-1">13</span>
                    <span className="py-1 relative font-bold text-white bg-[#1B3B2F] rounded shadow-2xs">
                      14
                      <span className="w-1 h-1 rounded-full bg-red-400 mx-auto block mt-0.5" />
                    </span>
                    <span className="py-1">15</span><span className="py-1">16</span><span className="py-1">17</span>
                    <span className="py-1 relative font-bold text-[#1B3B2F] bg-emerald-50 rounded">
                      18
                      <span className="w-1 h-1 rounded-full bg-emerald-500 mx-auto block mt-0.5" />
                    </span>
                    <span className="py-1">19</span><span className="py-1">20</span>
                    <span className="py-1">21</span><span className="py-1">22</span><span className="py-1">23</span><span className="py-1">24</span><span className="py-1">25</span><span className="py-1">26</span><span className="py-1">27</span>
                    <span className="py-1 relative font-bold text-[#1B3B2F] bg-orange-50 rounded">
                      28
                      <span className="w-1 h-1 rounded-full bg-orange-500 mx-auto block mt-0.5" />
                    </span>
                    <span className="py-1">29</span><span className="py-1">30</span>
                  </div>
                </div>

                {/* Upcoming renewals feed */}
                <div className="flex flex-col gap-1.5">
                  <span className="text-[10px] font-bold text-[#666B60] uppercase tracking-wider">
                    Prochaines dates
                  </span>

                  <div className="p-2 rounded-xl bg-white border border-[#E8E4DC] flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <span className="text-[10px] font-bold bg-neutral-100 text-[#1B3B2F] px-1.5 py-1 rounded">
                        14 Sep
                      </span>
                      <span className="text-[11px] font-bold text-[#1B3B2F]">Netflix</span>
                    </div>
                    <span className="text-[11px] font-bold text-[#1B3B2F]">13,49 €</span>
                  </div>

                  <div className="p-2 rounded-xl bg-white border border-[#E8E4DC] flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <span className="text-[10px] font-bold bg-neutral-100 text-[#1B3B2F] px-1.5 py-1 rounded">
                        18 Sep
                      </span>
                      <span className="text-[11px] font-bold text-[#1B3B2F]">Spotify Premium</span>
                    </div>
                    <span className="text-[11px] font-bold text-[#1B3B2F]">11,99 €</span>
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* ADD SUBSCRIPTION MODAL POPUP (Scene 4) */}
          {isAddModalOpen && (
            <div className="absolute inset-0 z-40 bg-black/40 backdrop-blur-xs flex items-end animate-in fade-in duration-200">
              <div className="w-full bg-white rounded-t-[24px] p-3.5 flex flex-col gap-2.5 shadow-2xl border-t border-[#E8E4DC] animate-in slide-in-from-bottom-5 duration-300">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-bold text-[#1B3B2F]">Ajouter un abonnement</span>
                  <button
                    type="button"
                    onClick={() => setIsAddModalOpen(false)}
                    className="text-[10px] font-bold text-[#666B60] p-1"
                  >
                    ✕
                  </button>
                </div>

                {/* Input with embedded logo */}
                <div className="flex flex-col gap-1">
                  <label className="text-[9px] font-bold text-[#666B60] uppercase">Nom du service</label>
                  <div className="relative flex items-center">
                    <div className="absolute left-2 w-6 h-6 rounded-md bg-emerald-100 text-emerald-800 flex items-center justify-center text-xs font-bold">
                      🏋️
                    </div>
                    <input
                      type="text"
                      readOnly
                      value={addNameInput || 'Salle de sport'}
                      className="w-full pl-9 pr-2 py-1.5 rounded-lg border border-[#1B3B2F] text-[11px] font-semibold text-[#1B3B2F] bg-white"
                    />
                  </div>
                  <span className="text-[8px] text-emerald-700 font-semibold">
                    ✓ Logo SVG Santé & Sport assigné automatiquement
                  </span>
                </div>

                <div className="grid grid-cols-2 gap-2">
                  <div>
                    <label className="text-[9px] font-bold text-[#666B60] uppercase">Montant</label>
                    <input
                      type="text"
                      readOnly
                      value="29,99 €"
                      className="w-full px-2 py-1 rounded-lg border border-[#E8E4DC] text-[11px] font-semibold text-[#1B3B2F] bg-neutral-50"
                    />
                  </div>
                  <div>
                    <label className="text-[9px] font-bold text-[#666B60] uppercase">Cycle</label>
                    <div className="px-2 py-1 rounded-lg border border-[#E8E4DC] text-[11px] font-semibold text-[#1B3B2F] bg-neutral-50">
                      Mensuel
                    </div>
                  </div>
                </div>

                <button
                  type="button"
                  onClick={() => setIsAddModalOpen(false)}
                  className="w-full py-2 rounded-lg bg-[#1B3B2F] text-white font-bold text-[11px] shadow-xs"
                >
                  Enregistrer l'abonnement
                </button>
              </div>
            </div>
          )}

          {/* CANCELLATION MODAL POPUP (Scene 5) */}
          {isCancelModalOpen && (
            <div className="absolute inset-0 z-40 bg-black/40 backdrop-blur-xs flex items-center justify-center p-3 animate-in fade-in duration-200">
              <div className="w-full bg-white rounded-2xl p-3.5 flex flex-col gap-2 shadow-2xl border border-[#E8E4DC] animate-in zoom-in-95 duration-200">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-1.5">
                    <Shield className="w-3.5 h-3.5 text-emerald-600" />
                    <span className="text-[11px] font-bold text-[#1B3B2F]">Résiliation Loi Chatel</span>
                  </div>
                  <button
                    type="button"
                    onClick={() => setIsCancelModalOpen(false)}
                    className="text-[10px] font-bold text-[#666B60]"
                  >
                    ✕
                  </button>
                </div>

                <p className="text-[9px] text-[#666B60] leading-snug">
                  Modèle certifié selon l'article L. 215-1 du Code de la consommation (Loi Chatel) sans engagement.
                </p>

                <div className="p-2 rounded-lg bg-neutral-50 border border-neutral-200 text-[8px] font-mono text-[#1B3B2F] leading-tight select-all">
                  « Conformément à la Loi Chatel, je vous notifie par la présente la résiliation sans frais... »
                </div>

                <div className="flex gap-1.5 mt-1">
                  <button
                    type="button"
                    onClick={() => setIsCancelModalOpen(false)}
                    className="flex-1 py-1.5 rounded-lg border border-[#E8E4DC] text-[10px] font-semibold text-[#1B3B2F]"
                  >
                    Copier la lettre
                  </button>
                  <button
                    type="button"
                    onClick={() => setIsCancelModalOpen(false)}
                    className="flex-1 py-1.5 rounded-lg bg-[#1B3B2F] text-white text-[10px] font-bold flex items-center justify-center gap-1"
                  >
                    <span>Lien 3 clics</span>
                    <ExternalLink className="w-2.5 h-2.5" />
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* Bottom Dock Navigation inside Phone */}
          <div className="px-3 py-2 bg-white/90 backdrop-blur-sm border-t border-[#E8E4DC] flex items-center justify-around flex-shrink-0">
            <button
              type="button"
              onClick={() => setActiveTab('overview')}
              className={`flex flex-col items-center gap-0.5 text-[9px] font-bold ${
                activeTab === 'overview' ? 'text-[#1B3B2F]' : 'text-[#666B60]/70'
              }`}
            >
              <Zap className="w-3.5 h-3.5" />
              <span>Aperçu</span>
            </button>

            <button
              type="button"
              onClick={() => setActiveTab('schedule')}
              className={`flex flex-col items-center gap-0.5 text-[9px] font-bold ${
                activeTab === 'schedule' ? 'text-[#1B3B2F]' : 'text-[#666B60]/70'
              }`}
            >
              <Calendar className="w-3.5 h-3.5" />
              <span>Échéances</span>
            </button>

            <button
              type="button"
              onClick={() => setIsAddModalOpen(true)}
              className="flex flex-col items-center gap-0.5 text-[9px] font-bold text-[#666B60]/70"
            >
              <Plus className="w-3.5 h-3.5" />
              <span>Ajouter</span>
            </button>
          </div>
        </div>

        {/* Bottom Home Indicator Bar */}
        <div className="w-full pt-2 pb-0.5 flex items-center justify-center">
          <div className="w-28 h-1 bg-[#F5EFE6]/40 rounded-full" />
        </div>
      </div>

      {/* Dynamic Marketing Ad Callout Badge (Floating below/beside phone) */}
      <div className="w-full max-w-[340px] mt-3.5 p-3 rounded-2xl bg-[#1B3B2F] text-[#F5EFE6] border border-[#2A5443] shadow-lg flex items-center justify-between gap-3 transition-all duration-300 animate-in fade-in slide-in-from-bottom-2">
        <div className="flex items-center gap-2.5 min-w-0">
          <div className="w-8 h-8 rounded-xl bg-[#2A5443] text-white flex items-center justify-center flex-shrink-0 shadow-xs">
            {scene.badgeIcon}
          </div>
          <div className="min-w-0">
            <span className="text-xs font-bold text-white block truncate">
              {scene.badge}
            </span>
            <span className="text-[11px] text-[#F5EFE6]/75 block truncate">
              {scene.badgeSub}
            </span>
          </div>
        </div>

        <Link
          href="/app"
          className="px-3 py-1.5 rounded-full bg-[#F5EFE6] text-[#1B3B2F] text-[11px] font-bold hover:bg-white transition-all flex-shrink-0 flex items-center gap-1 shadow-xs"
        >
          <span>Essayer</span>
          <ArrowRight className="w-3 h-3" />
        </Link>
      </div>
    </div>
  );
};
