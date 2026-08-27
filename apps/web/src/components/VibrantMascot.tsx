'use client';

import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Sparkles } from 'lucide-react';
import confetti from 'canvas-confetti';

export type MascotMood = 'happy' | 'celebrating' | 'curious' | 'alert';

export interface VibrantMascotProps {
  mood?: MascotMood;
  totalMonthly?: number;
  savingsMonthly?: number;
  activeCount?: number;
  size?: 'sm' | 'md' | 'lg';
  showBubble?: boolean;
  className?: string;
}

const QUOTES = {
  happy: [
    "Tout est sous contrôle ! 🌸",
    "Super gestion ce mois-ci ! ✨",
    "Tes abonnements te remercient ! 💖",
    "Budget parfaitement optimisé ! 🚀"
  ],
  celebrating: [
    "Woohoo ! Économies au max ! 🎉",
    "Champion de la gestion ! 🏆",
    "Regarde ces économies briller ! ⭐",
    "Tu maîtrises tes flux comme un chef ! 🔥"
  ],
  curious: [
    "Mode What-If activé : on simule ! 🔮",
    "Et si tu réinvestissais ces gains ? 💡",
    "Découvre de nouveaux services IA ! 🤖",
    "Teste de nouvelles combinaisons ! 🎨"
  ],
  alert: [
    "Attention aux renouvellements proches ! ⚡",
    "Un petit coup d'œil au calendrier ? 📅",
    "Pense à résilier ce que tu n'utilises plus ! ✂️"
  ]
};

export const VibrantMascot: React.FC<VibrantMascotProps> = ({
  mood = 'happy',
  totalMonthly = 0,
  savingsMonthly = 0,
  activeCount = 0,
  size = 'md',
  showBubble = true,
  className = ''
}) => {
  const [isHovered, setIsHovered] = useState(false);
  const [isWinking, setIsWinking] = useState(false);
  const [currentQuoteIndex, setCurrentQuoteIndex] = useState(0);

  // Periodic winking and quotes
  useEffect(() => {
    const winkInterval = setInterval(() => {
      setIsWinking(true);
      setTimeout(() => setIsWinking(false), 220);
    }, 4000);

    const quoteInterval = setInterval(() => {
      const quotesList = QUOTES[mood] || QUOTES.happy;
      setCurrentQuoteIndex((prev) => (prev + 1) % quotesList.length);
    }, 6000);

    return () => {
      clearInterval(winkInterval);
      clearInterval(quoteInterval);
    };
  }, [mood]);

  const triggerCelebration = () => {
    try {
      confetti({
        particleCount: 40,
        spread: 60,
        origin: { y: 0.7 },
        colors: ['#FF2A6D', '#8B5CF6', '#00F5D4', '#FFB703', '#3B82F6']
      });
    } catch {
      // Ignore
    }
  };

  const scaleMap = {
    sm: 0.75,
    md: 1,
    lg: 1.25
  };
  const scale = scaleMap[size];

  const currentQuote = (QUOTES[mood] || QUOTES.happy)[currentQuoteIndex % (QUOTES[mood] || QUOTES.happy).length];

  return (
    <div className={`relative flex items-center gap-3 select-none ${className}`}>
      {/* Speech Dialogue Bubble */}
      {showBubble && (
        <motion.div
          initial={{ opacity: 0, y: 8, scale: 0.9 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          transition={{ type: 'spring', stiffness: 350, damping: 20 }}
          className="relative bg-white/95 backdrop-blur-md px-3.5 py-2 rounded-2xl border-2 border-purple-300/80 shadow-lg shadow-purple-500/10 text-xs font-bold text-indigo-950 flex items-center gap-2 max-w-[210px] sm:max-w-[260px]"
        >
          <span className="text-sm">✨</span>
          <span className="truncate">{currentQuote}</span>
          <div className="absolute -right-2 top-1/2 -translate-y-1/2 w-0 h-0 border-t-[6px] border-t-transparent border-b-[6px] border-b-transparent border-l-[8px] border-l-purple-300/80" />
        </motion.div>
      )}

      {/* Mascot Character "Subby" */}
      <motion.div
        onHoverStart={() => setIsHovered(true)}
        onHoverEnd={() => setIsHovered(false)}
        onClick={triggerCelebration}
        animate={{
          y: isHovered ? [0, -8, 0] : [0, -4, 0],
          rotate: isHovered ? [0, -5, 5, 0] : [0, -1, 1, 0]
        }}
        transition={{
          repeat: Infinity,
          duration: isHovered ? 1.2 : 2.8,
          ease: 'easeInOut'
        }}
        whileTap={{ scale: 0.9, rotate: -12 }}
        className="relative cursor-pointer flex-shrink-0"
        style={{ width: `${64 * scale}px`, height: `${64 * scale}px` }}
        title="Subby — Cliquez pour fêter vos économies !"
      >
        {/* Glow Aura */}
        <div className="absolute inset-0 bg-gradient-to-tr from-pink-400 via-purple-400 to-cyan-400 rounded-full blur-md opacity-60 animate-pulse" />

        {/* Mascot Body SVG */}
        <svg
          viewBox="0 0 100 100"
          className="w-full h-full relative z-10 drop-shadow-md"
        >
          <defs>
            <linearGradient id="subbyGrad" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stopColor="#FF6584" />
              <stop offset="50%" stopColor="#8B5CF6" />
              <stop offset="100%" stopColor="#06B6D4" />
            </linearGradient>
            <linearGradient id="bellyGrad" x1="0%" y1="0%" x2="0%" y2="100%">
              <stop offset="0%" stopColor="#FFFFFF" />
              <stop offset="100%" stopColor="#FDF2F8" />
            </linearGradient>
            <linearGradient id="cheekGrad" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stopColor="#FF2A6D" />
              <stop offset="100%" stopColor="#FF758C" />
            </linearGradient>
          </defs>

          {/* Ears / Antennas */}
          <circle cx="28" cy="24" r="10" fill="url(#subbyGrad)" />
          <circle cx="28" cy="24" r="5" fill="#FFE4E6" />
          <circle cx="72" cy="24" r="10" fill="url(#subbyGrad)" />
          <circle cx="72" cy="24" r="5" fill="#FFE4E6" />

          {/* Main Squishy Body */}
          <rect
            x="16"
            y="20"
            width="68"
            height="64"
            rx="32"
            fill="url(#subbyGrad)"
            stroke="#FFFFFF"
            strokeWidth="3"
          />

          {/* Soft Belly Patch */}
          <ellipse cx="50" cy="56" rx="22" ry="18" fill="url(#bellyGrad)" opacity="0.95" />

          {/* Cheerful Eyes */}
          {!isWinking ? (
            <>
              {/* Left Eye */}
              <circle cx="38" cy="42" r="5" fill="#1E1B4B" />
              <circle cx="39.5" cy="40.5" r="2" fill="#FFFFFF" />

              {/* Right Eye */}
              <circle cx="62" cy="42" r="5" fill="#1E1B4B" />
              <circle cx="63.5" cy="40.5" r="2" fill="#FFFFFF" />
            </>
          ) : (
            <>
              {/* Left Eye Winking Arch */}
              <path
                d="M 33 43 Q 38 37 43 43"
                stroke="#1E1B4B"
                strokeWidth="3"
                strokeLinecap="round"
                fill="none"
              />
              {/* Right Open Eye */}
              <circle cx="62" cy="42" r="5" fill="#1E1B4B" />
              <circle cx="63.5" cy="40.5" r="2" fill="#FFFFFF" />
            </>
          )}

          {/* Rosy Cheeks */}
          <circle cx="28" cy="49" r="4.5" fill="url(#cheekGrad)" opacity="0.8" />
          <circle cx="72" cy="49" r="4.5" fill="url(#cheekGrad)" opacity="0.8" />

          {/* Happy Mouth */}
          <path
            d={
              mood === 'celebrating' || isHovered
                ? 'M 42 50 Q 50 62 58 50 Z'
                : 'M 43 51 Q 50 58 57 51'
            }
            stroke="#1E1B4B"
            strokeWidth="2.5"
            strokeLinecap="round"
            fill={mood === 'celebrating' || isHovered ? '#FF2A6D' : 'none'}
          />

          {/* Little Star Badge / Coin on Belly */}
          <circle cx="50" cy="62" r="6" fill="#FFD600" stroke="#FFF" strokeWidth="1" />
          <text
            x="50"
            y="65"
            fontSize="7"
            fontWeight="bold"
            textAnchor="middle"
            fill="#713F12"
          >
            €
          </text>
        </svg>

        {/* Floating Sparkle Particles */}
        <motion.div
          animate={{ scale: [0.8, 1.2, 0.8], opacity: [0.6, 1, 0.6] }}
          transition={{ repeat: Infinity, duration: 1.8 }}
          className="absolute -top-1 -right-1 text-yellow-400 drop-shadow"
        >
          <Sparkles className="w-4 h-4 fill-yellow-400" />
        </motion.div>
      </motion.div>
    </div>
  );
};
