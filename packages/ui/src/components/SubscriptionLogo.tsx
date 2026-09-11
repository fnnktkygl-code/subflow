'use client';

import React, { useState, useEffect } from 'react';
import { extractDomain, getLogoSources, getNativeSvgIconById, getNativeSvgIconForCategory } from '@subflow/core';

export interface SubscriptionLogoProps {
  name: string;
  domain?: string;
  logoUrl?: string;
  category?: string;
  size?: number;
  className?: string;
  showCategoryBadge?: boolean;
}

const CATEGORY_COLORS: Record<string, string> = {
  Entertainment: '#B87D56', // Terracotta Clay
  Productivity: '#3B4D3C', // Kuro-Matsu Pine
  Utilities: '#C4823F', // Yuzu Amber
  'Health & Fitness': '#477A56', // Matcha Green
  'Food & Dining': '#C49A6C', // Hinoki Warm Ochre
  Shopping: '#8C7355', // Sandalwood
  Transport: '#5E7D8A', // Indigo Fog
  General: '#8C867A' // Tatami Ash
};

function renderCategoryPinIcon(category: string) {
  const norm = category.toLowerCase().trim();
  if (norm.includes('entertain') || norm.includes('stream') || norm.includes('music')) {
    return (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-2.5 h-2.5 text-white">
        <rect x="2" y="2" width="20" height="20" rx="2.18" ry="2.18" />
        <line x1="7" y1="2" x2="7" y2="22" />
        <line x1="17" y1="2" x2="17" y2="22" />
        <line x1="2" y1="12" x2="22" y2="12" />
        <line x1="2" y1="7" x2="7" y2="7" />
        <line x1="17" y1="7" x2="22" y2="7" />
      </svg>
    );
  }
  if (norm.includes('product') || norm.includes('work') || norm.includes('dev') || norm.includes('ai')) {
    return (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-2.5 h-2.5 text-white">
        <rect x="2" y="3" width="20" height="14" rx="2" ry="2" />
        <line x1="8" y1="21" x2="16" y2="21" />
        <line x1="12" y1="17" x2="12" y2="21" />
      </svg>
    );
  }
  if (norm.includes('util') || norm.includes('cloud') || norm.includes('mobile') || norm.includes('telecom')) {
    return (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-2.5 h-2.5 text-white">
        <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" />
      </svg>
    );
  }
  if (norm.includes('health') || norm.includes('fit') || norm.includes('gym') || norm.includes('sport')) {
    return (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-2.5 h-2.5 text-white">
        <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
      </svg>
    );
  }
  if (norm.includes('food') || norm.includes('din') || norm.includes('eat') || norm.includes('deliver')) {
    return (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-2.5 h-2.5 text-white">
        <path d="M18 8h1a4 4 0 0 1 0 8h-1" />
        <path d="M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8z" />
      </svg>
    );
  }
  if (norm.includes('shop') || norm.includes('store') || norm.includes('cloth')) {
    return (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-2.5 h-2.5 text-white">
        <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z" />
        <line x1="3" y1="6" x2="21" y2="6" />
      </svg>
    );
  }
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-2.5 h-2.5 text-white">
      <polygon points="12 2 2 7 12 12 22 7 12 2" />
      <polyline points="2 17 12 22 22 17" />
      <polyline points="2 12 12 17 22 12" />
    </svg>
  );
}

export const SubscriptionLogo: React.FC<SubscriptionLogoProps> = ({
  name,
  domain,
  logoUrl,
  category = 'General',
  size = 44,
  className = '',
  showCategoryBadge = false
}) => {
  const [sourceIndex, setSourceIndex] = useState(0);
  const [hasError, setHasError] = useState(false);

  // Check if logoUrl is a native SVG token (e.g., 'svg:sparkles' or 'svg:dumbbell')
  const isExplicitNativeSvg = Boolean(logoUrl && logoUrl.startsWith('svg:'));
  const nativeSvgId = isExplicitNativeSvg ? logoUrl!.replace(/^svg:/, '') : null;
  const explicitNativeIcon = nativeSvgId ? getNativeSvgIconById(nativeSvgId) : null;

  const sources = React.useMemo(() => {
    if (isExplicitNativeSvg) return [];
    const list: string[] = [];
    if (logoUrl && /^\/logos\/[a-zA-Z0-9_ .-]+\.(svg|png|webp)$/.test(logoUrl)) {
      list.push(logoUrl);
    }
    const derived = getLogoSources(name, domain);
    derived.forEach((s) => {
      if (!list.includes(s)) list.push(s);
    });
    return list;
  }, [name, domain, logoUrl, isExplicitNativeSvg]);

  // Reset fallback sequence when name, domain, or logoUrl updates
  useEffect(() => {
    setSourceIndex(0);
    setHasError(false);
  }, [name, domain, logoUrl]);

  const currentSrc = sources[sourceIndex];

  const handleImageError = () => {
    if (sourceIndex + 1 < sources.length) {
      setSourceIndex((prev) => prev + 1);
    } else {
      setHasError(true);
    }
  };

  const categoryColor = CATEGORY_COLORS[category] || '#8C867A';
  const fallbackSvgIcon = getNativeSvgIconForCategory(category);
  const isSmall = size <= 20;

  // Render native SVG icon inside styled container
  const renderNativeSvgContent = (iconSvg: string) => {
    const iconSize = Math.max(16, Math.round(size * 0.5));
    return (
      <div
        className="w-full h-full flex items-center justify-center transition-all"
        style={{
          backgroundColor: `${categoryColor}14`,
          color: categoryColor
        }}
      >
        <svg
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          style={{ width: `${iconSize}px`, height: `${iconSize}px` }}
          dangerouslySetInnerHTML={{ __html: iconSvg }}
        />
      </div>
    );
  };

  const hasValidImage = !hasError && Boolean(currentSrc);

  return (
    <div
      className={`relative flex-shrink-0 select-none ${className}`}
      style={{ width: `${size}px`, height: `${size}px` }}
    >
      {/* Main Logo Container with High-Contrast Canvas for Light/Dark mode parity */}
      <div
        className={`w-full h-full ${
          isSmall ? 'rounded-full' : 'rounded-japandi-xl border border-japandi-border/80 dark:border-white/10 shadow-xs'
        } ${hasValidImage && !isExplicitNativeSvg ? 'bg-white dark:bg-white' : 'bg-japandi-surface'} overflow-hidden flex items-center justify-center`}
      >
        {isExplicitNativeSvg && explicitNativeIcon ? (
          renderNativeSvgContent(explicitNativeIcon.svg)
        ) : hasValidImage ? (
          <img
            src={currentSrc}
            alt={name || 'Service'}
            className={`w-full h-full object-contain p-1 transform scale-100 ${
              isSmall ? 'rounded-full' : 'rounded-japandi-xl'
            }`}
            loading="lazy"
            onError={handleImageError}
          />
        ) : (
          renderNativeSvgContent(fallbackSvgIcon.svg)
        )}
      </div>

      {/* Floating Category Pin Badge matching Flutter exactly */}
      {showCategoryBadge && !isSmall && (
        <div
          className="absolute -bottom-1 -right-1 w-4 h-4 rounded-full border-[1.5px] border-japandi-surface flex items-center justify-center shadow-xs z-10"
          style={{ backgroundColor: categoryColor }}
          title={category}
        >
          {renderCategoryPinIcon(category)}
        </div>
      )}
    </div>
  );
};

