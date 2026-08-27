'use client';

import React, { useState, useRef, useEffect, useId } from 'react';
import { ChevronDown, Check } from 'lucide-react';

export interface DropdownOption {
  value: string;
  label: string;
  icon?: React.ReactNode;
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
        className="w-full flex items-center justify-between px-3.5 py-2.5 rounded-japandi-md bg-japandi-elevated border border-japandi-border text-japandi-text text-sm hover:border-japandi-border-strong focus:outline-none focus:ring-2 focus:ring-japandi-pine transition-all select-none"
      >
        <div className="flex items-center gap-2 min-w-0 pr-1">
          {selectedOption?.icon && <span className="flex-shrink-0">{selectedOption.icon}</span>}
          <span className="truncate font-semibold text-xs sm:text-sm">
            {selectedOption ? selectedOption.label : placeholder}
          </span>
        </div>
        <ChevronDown
          className={`w-4 h-4 text-japandi-muted transition-transform duration-200 flex-shrink-0 ${
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
          className="absolute z-[100] bottom-full mb-2 w-full min-w-[180px] right-0 rounded-japandi-md bg-japandi-surface border border-japandi-border shadow-japandi-xl overflow-hidden animate-in fade-in zoom-in-95 duration-150 max-h-56 overflow-y-auto"
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
                  className={`w-full flex items-center justify-between px-2.5 py-2 rounded-japandi-sm text-xs font-semibold transition-colors text-left ${
                    isSelected
                      ? 'bg-japandi-pine/10 text-japandi-pine'
                      : 'text-japandi-text hover:bg-japandi-sand/60'
                  }`}
                >
                  <div className="flex items-center gap-2.5">
                    {opt.icon && <span className="flex-shrink-0">{opt.icon}</span>}
                    <span className="whitespace-nowrap">{opt.label}</span>
                  </div>
                  {isSelected && <Check className="w-3.5 h-3.5 text-japandi-pine flex-shrink-0 ml-2" />}
                </button>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
};
