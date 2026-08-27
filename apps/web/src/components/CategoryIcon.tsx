import React from 'react';
import { useSubscriptionStore } from '../store/useSubscriptionStore';

export interface CategoryIconProps {
  category: string;
  className?: string;
  size?: number;
  showBackground?: boolean;
  themeMode?: string;
}

export const BARBIE_CATEGORY_PALETTE: Record<
  string,
  { color: string; bgColor: string }
> = {

  Entertainment: { color: '#EC4899', bgColor: 'rgba(236, 72, 153, 0.16)' },
  Productivity: { color: '#8B5CF6', bgColor: 'rgba(139, 92, 246, 0.16)' },
  Utilities: { color: '#F43F5E', bgColor: 'rgba(244, 63, 94, 0.16)' },
  'Health & Fitness': { color: '#FB7185', bgColor: 'rgba(251, 113, 133, 0.16)' },
  'Food & Dining': { color: '#F472B6', bgColor: 'rgba(244, 114, 182, 0.16)' },
  Shopping: { color: '#DB2777', bgColor: 'rgba(219, 39, 119, 0.16)' },
  General: { color: '#BE123C', bgColor: 'rgba(190, 18, 60, 0.16)' }
};

export const JAPANDI_CATEGORY_PALETTE: Record<
  string,
  { color: string; bgColor: string }
> = {
  Entertainment: { color: '#B87D56', bgColor: 'rgba(184, 125, 86, 0.15)' },
  Productivity: { color: '#3B4D3C', bgColor: 'rgba(59, 77, 60, 0.15)' },
  Utilities: { color: '#C4823F', bgColor: 'rgba(196, 130, 63, 0.15)' },
  'Health & Fitness': { color: '#477A56', bgColor: 'rgba(71, 122, 86, 0.15)' },
  'Food & Dining': { color: '#C49A6C', bgColor: 'rgba(196, 154, 108, 0.15)' },
  Shopping: { color: '#8C7355', bgColor: 'rgba(140, 115, 85, 0.15)' },
  General: { color: '#8C867A', bgColor: 'rgba(140, 134, 122, 0.15)' }
};

export const CATEGORY_METADATA: Record<
  string,
  { color: string; bgColor: string; label: string; icon: React.ReactNode }
> = {
  Entertainment: {
    color: '#B87D56',
    bgColor: 'rgba(184, 125, 86, 0.15)',
    label: 'Entertainment',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-full h-full">
        <rect x="2" y="2" width="20" height="20" rx="2.18" ry="2.18" />
        <line x1="7" y1="2" x2="7" y2="22" />
        <line x1="17" y1="2" x2="17" y2="22" />
        <line x1="2" y1="12" x2="22" y2="12" />
        <line x1="2" y1="7" x2="7" y2="7" />
        <line x1="2" y1="17" x2="7" y2="17" />
        <line x1="17" y1="17" x2="22" y2="17" />
        <line x1="17" y1="7" x2="22" y2="7" />
      </svg>
    )
  },
  Productivity: {
    color: '#3B4D3C',
    bgColor: 'rgba(59, 77, 60, 0.15)',
    label: 'Productivity',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-full h-full">
        <rect x="2" y="3" width="20" height="14" rx="2" ry="2" />
        <line x1="8" y1="21" x2="16" y2="21" />
        <line x1="12" y1="17" x2="12" y2="21" />
      </svg>
    )
  },
  Utilities: {
    color: '#C4823F',
    bgColor: 'rgba(196, 130, 63, 0.15)',
    label: 'Utilities',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-full h-full">
        <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" />
      </svg>
    )
  },
  'Health & Fitness': {
    color: '#477A56',
    bgColor: 'rgba(71, 122, 86, 0.15)',
    label: 'Health & Fitness',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-full h-full">
        <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
      </svg>
    )
  },
  'Food & Dining': {
    color: '#C49A6C',
    bgColor: 'rgba(196, 154, 108, 0.15)',
    label: 'Food & Dining',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-full h-full">
        <path d="M18 8h1a4 4 0 0 1 0 8h-1" />
        <path d="M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8z" />
        <line x1="6" y1="1" x2="6" y2="4" />
        <line x1="10" y1="1" x2="10" y2="4" />
        <line x1="14" y1="1" x2="14" y2="4" />
      </svg>
    )
  },
  Shopping: {
    color: '#8C7355',
    bgColor: 'rgba(140, 115, 85, 0.15)',
    label: 'Shopping',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-full h-full">
        <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z" />
        <line x1="3" y1="6" x2="21" y2="6" />
        <path d="M16 10a4 4 0 0 1-8 0" />
      </svg>
    )
  },
  General: {
    color: '#8C867A',
    bgColor: 'rgba(140, 134, 122, 0.15)',
    label: 'General',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-full h-full">
        <polygon points="12 2 2 7 12 12 22 7 12 2" />
        <polyline points="2 17 12 22 22 17" />
        <polyline points="2 12 12 17 22 12" />
      </svg>
    )
  }
};

export const CategoryIcon: React.FC<CategoryIconProps> = ({
  category,
  className = 'w-4 h-4',
  size,
  showBackground = false,
  themeMode
}) => {
  const storeTheme = useSubscriptionStore((s) => s.profile.themeMode);
  const activeTheme = themeMode || storeTheme;

  const norm = category.trim();
  const matchedKey =
    Object.keys(CATEGORY_METADATA).find((k) => k.toLowerCase() === norm.toLowerCase()) ||
    Object.keys(CATEGORY_METADATA).find((k) => norm.toLowerCase().includes(k.toLowerCase())) ||
    'General';

  const matched = CATEGORY_METADATA[matchedKey] || CATEGORY_METADATA['General']!;

  let color = matched.color;
  let bgColor = matched.bgColor;

  if (activeTheme === 'barbie') {
    const pal = BARBIE_CATEGORY_PALETTE[matchedKey] || BARBIE_CATEGORY_PALETTE['General']!;
    color = pal.color;
    bgColor = pal.bgColor;
  }


  if (showBackground) {
    return (
      <div
        className="flex items-center justify-center rounded-japandi-sm flex-shrink-0 p-1.5 shadow-xs transition-colors"
        style={{
          backgroundColor: bgColor,
          color: color,
          width: size ? `${size}px` : undefined,
          height: size ? `${size}px` : undefined
        }}
      >
        <div className={className}>{matched.icon}</div>
      </div>
    );
  }

  return (
    <span
      className={`inline-flex items-center justify-center flex-shrink-0 transition-colors ${className}`}
      style={{ color: color, width: size ? `${size}px` : undefined, height: size ? `${size}px` : undefined }}
    >
      {matched.icon}
    </span>
  );
};

