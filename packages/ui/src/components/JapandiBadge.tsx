import React from 'react';
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export interface JapandiBadgeProps extends React.HTMLAttributes<HTMLSpanElement> {
  variant?: 'neutral' | 'pine' | 'terracotta' | 'clay';
  size?: 'sm' | 'md';
}

export const JapandiBadge: React.FC<JapandiBadgeProps> = ({
  children,
  className,
  variant = 'neutral',
  size = 'sm',
  ...props
}) => {
  const baseStyles = 'inline-flex items-center font-semibold rounded-japandi-full tracking-wide uppercase';

  const variants = {
    neutral: 'bg-japandi-sand/60 text-japandi-muted',
    pine: 'bg-japandi-pine/15 text-japandi-pine',
    terracotta: 'bg-japandi-terracotta/15 text-japandi-terracotta',
    clay: 'bg-japandi-clay/15 text-japandi-clay'
  };

  const sizes = {
    sm: 'text-[10px] px-2 py-0.5',
    md: 'text-xs px-2.5 py-1'
  };

  return (
    <span className={twMerge(clsx(baseStyles, variants[variant], sizes[size], className))} {...props}>
      {children}
    </span>
  );
};
