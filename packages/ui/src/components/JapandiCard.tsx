import React from 'react';
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export interface JapandiCardProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: 'surface' | 'elevated' | 'subtle';
  padding?: 'none' | 'sm' | 'md' | 'lg';
  isHoverable?: boolean;
}

export const JapandiCard: React.FC<JapandiCardProps> = ({
  children,
  className,
  variant = 'surface',
  padding = 'md',
  isHoverable = false,
  ...props
}) => {
  const baseStyles = 'rounded-japandi-lg border transition-all duration-200';
  
  const variants = {
    surface: 'bg-japandi-surface border-japandi-border shadow-japandi-sm',
    elevated: 'bg-japandi-elevated border-japandi-border shadow-japandi-md',
    subtle: 'bg-japandi-bg border-transparent'
  };

  const paddings = {
    none: 'p-0',
    sm: 'p-3',
    md: 'p-5',
    lg: 'p-7'
  };

  const hoverStyles = isHoverable
    ? 'hover:border-japandi-border-strong hover:shadow-japandi-md hover:-translate-y-0.5 cursor-pointer active:translate-y-0 active:shadow-japandi-sm'
    : '';

  return (
    <div
      className={twMerge(clsx(baseStyles, variants[variant], paddings[padding], hoverStyles, className))}
      {...props}
    >
      {children}
    </div>
  );
};
