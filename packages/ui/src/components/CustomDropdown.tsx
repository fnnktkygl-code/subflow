'use client';

import React, { useState, useRef, useEffect, useId } from 'react';
import { ChevronDown, Check } from 'lucide-react';

export interface DropdownOption {
  value: string;
  label: string;
  icon?: React.ReactNode;
  subtitle?: string;
  badge?: string;
}

export interface CustomDropdownProps {
  options: DropdownOption[] | string[];
  value: string;
  onChange: (value: string) => void;
  label?: string;
  placeholder?: string;
  className?: string;
}

export const CustomDropdown: React.FC<CustomDropdownProps> = ({
  options,
  value,
  onChange,
  label,
  placeholder = 'Select option...',
  className = ''
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const dropdownId = useId();

  const normalizedOptions: DropdownOption[] = options.map((opt) =>
    typeof opt === 'string' ? { value: opt, label: opt } : opt
  );

  const selectedOption = normalizedOptions.find((opt) => opt.value === value);

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(e.target as Node)) {
        setIsOpen(false);
      }
    };
    const handleKeyDown = (e: KeyboardEvent) => {
      if (isOpen && (e.key === 'Escape' || e.key === 'Esc')) {
        e.stopPropagation();
        setIsOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    document.addEventListener('keydown', handleKeyDown);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
      document.removeEventListener('keydown', handleKeyDown);
    };
  }, [isOpen]);

  return (
    <div className={`relative ${className}`} ref={containerRef}>
      {label && (
        <label
          htmlFor={dropdownId}
          className="block text-xs font-semibold text-japandi-muted uppercase tracking-wider mb-1.5"
        >
          {label}
        </label>
      )}

      {/* Trigger Button with accessible ARIA attributes */}
      <button
        id={dropdownId}
        type="button"
        aria-expanded={isOpen}
        aria-haspopup="listbox"
        aria-controls={`${dropdownId}-menu`}
        aria-label={label || placeholder}
        onClick={() => setIsOpen(!isOpen)}
        className="w-full flex items-center justify-between px-3.5 py-2.5 rounded-japandi-xl bg-japandi-elevated border border-japandi-border text-japandi-text text-sm hover:border-japandi-pine focus:outline-none focus:ring-2 focus:ring-japandi-pine/30 transition-all select-none shadow-xs"
      >
        <div className="flex items-center gap-2.5 min-w-0 pr-1">
          {selectedOption?.icon && <span className="flex-shrink-0 text-base">{selectedOption.icon}</span>}
          <div className="flex items-center gap-2 truncate">
            <span className="font-bold text-xs sm:text-sm text-japandi-text">
              {selectedOption ? selectedOption.label : placeholder}
            </span>
            {selectedOption?.badge && (
              <span className="text-[10px] font-extrabold px-1.5 py-0.5 rounded bg-japandi-sand/80 text-japandi-pine border border-japandi-border">
                {selectedOption.badge}
              </span>
            )}
          </div>
        </div>
        <ChevronDown
          className={`w-4 h-4 text-japandi-muted transition-transform duration-200 flex-shrink-0 ml-1 ${
            isOpen ? 'transform rotate-180 text-japandi-pine' : ''
          }`}
        />
      </button>

      {/* Dropdown Menu (opens upwards with listbox role) */}
      {isOpen && (
        <div
          id={`${dropdownId}-menu`}
          role="listbox"
          aria-label={label || placeholder}
          className="absolute z-[100] bottom-full mb-2 w-full min-w-[240px] right-0 rounded-japandi-xl bg-japandi-surface border border-japandi-border shadow-japandi-xl overflow-hidden animate-in fade-in zoom-in-95 duration-150 max-h-72 overflow-y-auto"
        >
          <div className="p-1.5 flex flex-col gap-1">
            {normalizedOptions.map((opt) => {
              const isSelected = opt.value === value;
              return (
                <button
                  key={opt.value}
                  type="button"
                  role="option"
                  aria-selected={isSelected}
                  onClick={() => {
                    onChange(opt.value);
                    setIsOpen(false);
                  }}
                  className={`w-full flex items-center justify-between px-3 py-2.5 rounded-japandi-lg text-xs font-semibold transition-all text-left ${
                    isSelected
                      ? 'bg-japandi-pine/10 text-japandi-pine border border-japandi-pine/20'
                      : 'text-japandi-text hover:bg-japandi-sand/60 border border-transparent'
                  }`}
                >
                  <div className="flex items-center gap-2.5 min-w-0">
                    {opt.icon && <span className="flex-shrink-0 text-base">{opt.icon}</span>}
                    <div className="flex flex-col min-w-0">
                      <div className="flex items-center gap-1.5">
                        <span className="font-bold truncate">{opt.label}</span>
                        {opt.badge && (
                          <span className="text-[10px] font-extrabold px-1.5 py-0.5 rounded bg-japandi-sand/80 text-japandi-pine border border-japandi-border">
                            {opt.badge}
                          </span>
                        )}
                      </div>
                      {opt.subtitle && (
                        <span className="text-[10px] text-japandi-muted font-normal truncate">
                          {opt.subtitle}
                        </span>
                      )}
                    </div>
                  </div>
                  {isSelected && <Check className="w-4 h-4 text-japandi-pine flex-shrink-0 ml-2" />}
                </button>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
};
