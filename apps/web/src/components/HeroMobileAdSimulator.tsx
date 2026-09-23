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
  Smartphone,
  MousePointerClick
} from 'lucide-react';

interface SceneInfo {
  id: string;
  title: string;
  shortLabel: string;
  badge: string;
  badgeSub: string;
  badgeIcon: React.ReactNode;
}

const SCENES: SceneInfo[] = [
  {
    id: 'overview',
    title: 'Vue d\'ensemble & Budget',
    shortLabel: '01. Dashboard',
    badge: 'Vos prélèvements sous contrôle',
    badgeSub: 'Coût mensuel consolidé · 67,37 €/mois',
    badgeIcon: <Zap className="w-3.5 h-3.5 text-amber-400 fill-amber-400" />
  },
  {
    id: 'whatif',
    title: 'Mode Simulation What-If',
    shortLabel: '02. Économies',
    badge: '-43,39 € / mois économisés en direct !',
    badgeSub: 'Simulez en 2 clics sans toucher à vos vrais contrats',
    badgeIcon: <TrendingDown className="w-3.5 h-3.5 text-emerald-400" />
  },
  {
    id: 'schedule',
    title: 'Calendrier des Échéances',
    shortLabel: '03. Calendrier',
    badge: 'Zéro surprise en fin de mois',
    badgeSub: 'Voyez exactement quand chaque débit arrive sur votre compte',
    badgeIcon: <Calendar className="w-3.5 h-3.5 text-sky-400" />
  },
  {
    id: 'add',
    title: 'Catalogue & Vrais Logos de Marque',
    shortLabel: '04. Ajout & Logos',
    badge: '350+ presets & vrais logos de marque',
    badgeSub: 'Netflix, Spotify, Canal+ avec leurs vrais logos vectoriels',
    badgeIcon: <Sparkles className="w-3.5 h-3.5 text-purple-400" />
  },
  {
    id: 'loichatel',
    title: 'Assistant Loi Châtel & Résiliation',
    shortLabel: '05. Loi Châtel',
    badge: 'Résiliation en 3 clics (Loi Châtel)',
    badgeSub: 'Modèle officiel certifié Art. L215-1 prêt à l\'envoi',
    badgeIcon: <Shield className="w-3.5 h-3.5 text-teal-400" />
  }
];

export const HeroMobileAdSimulator: React.FC = () => {
  const [currentSceneIndex, setCurrentSceneIndex] = useState(0);
  const [isPlaying, setIsPlaying] = useState(true);
  const [isInteractiveMode, setIsInteractiveMode] = useState(false);
  const [progress, setProgress] = useState(0);

  const iframeRef = useRef<HTMLIFrameElement | null>(null);

  // Sync state received from the real app running inside the iframe
  useEffect(() => {
    const handleIframeMessage = (e: MessageEvent) => {
      if (!e.data || typeof e.data !== 'object') return;

      if (e.data.type === 'SUBFLOW_DEMO_SCENE_CHANGE') {
        if (typeof e.data.sceneIndex === 'number') {
          setCurrentSceneIndex(e.data.sceneIndex);
          setProgress(0);
        }
      }
    };

    window.addEventListener('message', handleIframeMessage);
    return () => window.removeEventListener('message', handleIframeMessage);
  }, []);

  // Story progress bar ticker
  useEffect(() => {
    if (isInteractiveMode || !isPlaying) return;

    const intervalStep = 60;
    const totalDuration = 6000;
    const progressIncrement = (intervalStep / totalDuration) * 100;

    const interval = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 100) {
          return 0;
        }
        return prev + progressIncrement;
      });
    }, intervalStep);

    return () => clearInterval(interval);
  }, [isPlaying, isInteractiveMode, currentSceneIndex]);

  // Jump to specific scene in the real app iframe
  const handleJumpToScene = (index: number) => {
    setCurrentSceneIndex(index);
    setProgress(0);
    setIsPlaying(true);
    setIsInteractiveMode(false);

    iframeRef.current?.contentWindow?.postMessage(
      {
        type: 'GOTO_SCENE',
        scene: index
      },
      '*'
    );
  };

  const handleTogglePlay = () => {
    const next = !isPlaying;
    setIsPlaying(next);
    iframeRef.current?.contentWindow?.postMessage(
      {
        type: 'TOGGLE_PLAY',
        isPlaying: next
      },
      '*'
    );
  };

  const handleToggleInteractive = () => {
    const next = !isInteractiveMode;
    setIsInteractiveMode(next);
    if (next) {
      setIsPlaying(false);
    } else {
      setIsPlaying(true);
      setProgress(0);
    }

    iframeRef.current?.contentWindow?.postMessage(
      {
        type: 'TOGGLE_INTERACTIVE',
        interactive: next
      },
      '*'
    );
  };

  const activeScene = SCENES[currentSceneIndex] ?? SCENES[0]!;

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
              className="px-2.5 py-1 rounded-full bg-[#1B3B2F] text-[#F5EFE6] font-semibold flex items-center gap-1 hover:bg-[#2A5443] transition-all shadow-xs"
              title={isPlaying ? 'Mettre en pause' : 'Lecture'}
            >
              {isPlaying ? <Pause className="w-3 h-3" /> : <Play className="w-3 h-3 fill-current" />}
              <span>{isPlaying ? 'Pause' : 'Lire'}</span>
            </button>

            <button
              type="button"
              onClick={() => handleJumpToScene(0)}
              className="p-1.5 rounded-full bg-white/80 text-[#1B3B2F] hover:bg-white transition-all shadow-xs"
              title="Recommencer depuis le début"
            >
              <RotateCcw className="w-3 h-3" />
            </button>
          </div>

          {/* Interactive Mode Toggle */}
          <button
            type="button"
            onClick={handleToggleInteractive}
            className={`px-3 py-1 rounded-full text-[11px] font-bold transition-all flex items-center gap-1.5 shadow-xs ${
              isInteractiveMode
                ? 'bg-emerald-600 text-white ring-2 ring-emerald-400'
                : 'bg-white/80 text-[#1B3B2F] hover:bg-white'
            }`}
          >
            <Smartphone className="w-3 h-3" />
            <span>{isInteractiveMode ? 'Mode Direct Actif' : 'Tester en Direct'}</span>
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

        {/* Screen Viewport: RUNS THE 100% REAL SUBFLOW APPLICATION */}
        <div className="w-full flex-1 bg-[#FAF7F2] rounded-[32px] overflow-hidden relative flex flex-col shadow-inner">
          <iframe
            ref={iframeRef}
            src="/demo?embed=1&automode=1"
            title="SubFlow Vraie Application en Direct"
            className="w-full h-full border-0 bg-[#FAF7F2]"
            sandbox="allow-scripts allow-same-origin allow-forms"
          />

          {/* Dynamic Marketing Ad Overlay Badge (Synchronized with the active scene) */}
          <div className="absolute top-12 left-2 right-2 z-20 pointer-events-none transition-all duration-300 transform translate-y-0">
            <div className="bg-[#1B3B2F]/90 backdrop-blur-md text-[#F5EFE6] px-3 py-1.5 rounded-xl shadow-lg border border-white/10 flex items-center gap-2">
              <div className="p-1 rounded-full bg-white/10 flex-shrink-0">
                {activeScene?.badgeIcon}
              </div>
              <div className="min-w-0">
                <strong className="block text-[10px] font-bold leading-tight truncate text-emerald-300">
                  {activeScene?.badge}
                </strong>
                <span className="block text-[8px] text-[#F5EFE6]/80 leading-tight truncate">
                  {activeScene?.badgeSub}
                </span>
              </div>
            </div>
          </div>

          {/* Bottom Home Indicator Bar (iOS Style) */}
          <div className="absolute bottom-1 left-1/2 transform -translate-x-1/2 w-28 h-1 bg-[#1B3B2F]/30 rounded-full z-30 pointer-events-none" />
        </div>
      </div>

      {/* Reassurance Caption */}
      <div className="mt-3 flex items-center gap-2 text-[11px] text-[#5A6354]">
        <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
        <span>Vraie application SubFlow en direct · Vrais logos & calculs réels</span>
      </div>
    </div>
  );
};
