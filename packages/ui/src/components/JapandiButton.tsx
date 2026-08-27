import React from 'react';
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export interface JapandiButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'danger';
  size?: 'sm' | 'md' | 'lg' | 'icon';
  isLoading?: boolean;
}

export const JapandiButton = React.forwardRef<HTMLButtonElement, JapandiButtonProps>(
  ({ children, className, variant = 'primary', size = 'md', isLoading = false, disabled, ...props }, ref) => {
    const baseStyles = 'inline-flex items-center justify-center font-medium transition-all duration-150 focus:outline-none focus:ring-2 focus:ring-japandi-pine focus:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none active:scale-[0.98] select-none';

    const variants = {
      primary: 'bg-japandi-pine text-white hover:bg-opacity-90 shadow-japandi-sm',
      secondary: 'bg-japandi-sand text-japandi-text hover:bg-opacity-80',
      outline: 'border border-japandi-border bg-transparent text-japandi-text hover:bg-japandi-surface hover:border-japandi-border-strong',
      ghost: 'bg-transparent text-japandi-text hover:bg-japandi-sand/30',
      danger: 'bg-japandi-terracotta text-white hover:bg-opacity-90 shadow-japandi-sm'
    };

    const sizes = {
      sm: 'h-8 px-3 text-xs rounded-japandi-sm gap-1.5',
      md: 'h-10 px-4 text-sm rounded-japandi-md gap-2',
      lg: 'h-12 px-6 text-base rounded-japandi-lg gap-2.5',
      icon: 'h-10 w-10 p-0 rounded-japandi-md'
    };

    return (
      <button
        ref={ref}
        disabled={disabled || isLoading}
        className={twMerge(clsx(baseStyles, variants[variant], sizes[size], className))}
        {...props}
      >
        {isLoading ? (
          <span className="inline-block h-4 w-4 animate-spin rounded-full border-2 border-current border-t-transparent" />
        ) : (
          children
        )}
      </button>
    );
  }
);
JapandiButton.displayName = 'JapandiButton';
