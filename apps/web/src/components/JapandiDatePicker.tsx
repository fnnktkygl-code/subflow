'use client';

import React, { useState, useRef, useEffect } from 'react';
import { Calendar as CalendarIcon, ChevronLeft, ChevronRight, X } from 'lucide-react';

interface JapandiDatePickerProps {
  value: string; // ISO format: YYYY-MM-DD
  onChange: (dateStr: string) => void;
  label?: string;
}

const MONTH_NAMES = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

// Generate years from 2020 to 2035
const YEARS = Array.from({ length: 16 }, (_, i) => 2020 + i);

export const JapandiDatePicker: React.FC<JapandiDatePickerProps> = ({
  value,
  onChange,
  label = 'Renewal Date'
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);

  // Parse initial date
  const parsedDate = React.useMemo(() => {
    if (!value) return new Date();
    const parts = value.split('-');
    if (parts.length === 3) {
      return new Date(parseInt(parts[0]!, 10), parseInt(parts[1]!, 10) - 1, parseInt(parts[2]!, 10));
    }
    return new Date();
  }, [value]);

  const [viewYear, setViewYear] = useState(parsedDate.getFullYear());
  const [viewMonth, setViewMonth] = useState(parsedDate.getMonth());

  useEffect(() => {
    const parts = value.split('-');
    if (parts.length === 3) {
      setViewYear(parseInt(parts[0]!, 10));
      setViewMonth(parseInt(parts[1]!, 10) - 1);
    }
  }, [value]);

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(e.target as Node)) {
        setIsOpen(false);
      }
    };
    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [isOpen]);

  const daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate();
  const firstDayOfWeek = (new Date(viewYear, viewMonth, 1).getDay() + 6) % 7; // Monday = 0

  const handlePrevMonth = () => {
    if (viewMonth === 0) {
      setViewMonth(11);
      setViewYear(viewYear - 1);
    } else {
      setViewMonth(viewMonth - 1);
    }
  };

  const handleNextMonth = () => {
    if (viewMonth === 11) {
      setViewMonth(0);
      setViewYear(viewYear + 1);
    } else {
      setViewMonth(viewMonth + 1);
    }
  };

  const handleSelectDay = (day: number) => {
    const monthStr = String(viewMonth + 1).padStart(2, '0');
    const dayStr = String(day).padStart(2, '0');
    const dateString = `${viewYear}-${monthStr}-${dayStr}`;
    onChange(dateString);
    setIsOpen(false);
  };

  // Format display date: 27/08/2026
  const formattedDisplay = `${String(parsedDate.getDate()).padStart(2, '0')}/${String(parsedDate.getMonth() + 1).padStart(2, '0')}/${parsedDate.getFullYear()}`;

  return (
    <div className="relative" ref={containerRef}>
      {label && (
        <label className="block text-xs font-semibold text-japandi-muted uppercase tracking-wider mb-1.5">
          {label}
        </label>
      )}

      {/* Trigger Button */}
      <button
        type="button"
        onClick={() => setIsOpen(!isOpen)}
        className="w-full flex items-center justify-between px-3.5 py-2.5 rounded-japandi-md bg-japandi-elevated border border-japandi-border text-japandi-text text-sm hover:border-japandi-border-strong focus:outline-none focus:ring-2 focus:ring-japandi-pine transition-all select-none"
      >
        <span className="font-semibold text-japandi-text">{formattedDisplay}</span>
        <CalendarIcon className="w-4 h-4 text-japandi-muted" />
      </button>

      {/* Bespoke Japandi Calendar Popover Modal / Overlay */}
      {isOpen && (
        <div className="fixed inset-0 z-[200] flex items-center justify-center p-4 bg-black/40 backdrop-blur-xs animate-in fade-in duration-150">
          <div
            className="w-full max-w-[320px] rounded-japandi-2xl bg-japandi-surface border border-japandi-border shadow-japandi-xl p-4 flex flex-col gap-3 animate-in zoom-in-95 duration-150 select-none"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Header: Month & Year Selectors with Chevrons */}
            <div className="flex items-center justify-between pb-2 border-b border-japandi-border">
              <div className="flex items-center gap-1.5">
                {/* Month Dropdown Selector */}
                <select
                  value={viewMonth}
                  onChange={(e) => setViewMonth(parseInt(e.target.value, 10))}
                  className="px-2 py-1 text-xs font-bold rounded-japandi-sm bg-japandi-elevated border border-japandi-border text-japandi-text focus:outline-none focus:ring-1 focus:ring-japandi-pine cursor-pointer"
                >
                  {MONTH_NAMES.map((m, idx) => (
                    <option key={m} value={idx}>
                      {m}
                    </option>
                  ))}
                </select>

                {/* Year Dropdown Selector */}
                <select
                  value={viewYear}
                  onChange={(e) => setViewYear(parseInt(e.target.value, 10))}
                  className="px-2 py-1 text-xs font-bold rounded-japandi-sm bg-japandi-elevated border border-japandi-border text-japandi-text focus:outline-none focus:ring-1 focus:ring-japandi-pine cursor-pointer"
                >
                  {YEARS.map((y) => (
                    <option key={y} value={y}>
                      {y}
                    </option>
                  ))}
                </select>
              </div>

              {/* Chevrons & Close */}
              <div className="flex items-center gap-1">
                <button
                  type="button"
                  onClick={handlePrevMonth}
                  className="p-1 rounded-japandi-sm hover:bg-japandi-sand text-japandi-muted hover:text-japandi-text transition-colors"
                >
                  <ChevronLeft className="w-4 h-4" />
                </button>
                <button
                  type="button"
                  onClick={handleNextMonth}
                  className="p-1 rounded-japandi-sm hover:bg-japandi-sand text-japandi-muted hover:text-japandi-text transition-colors"
                >
                  <ChevronRight className="w-4 h-4" />
                </button>
                <button
                  type="button"
                  onClick={() => setIsOpen(false)}
                  className="p-1 ml-1 rounded-japandi-sm hover:bg-japandi-sand text-japandi-muted hover:text-japandi-text transition-colors"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>
            </div>

            {/* Days of Week Header */}
            <div className="grid grid-cols-7 gap-1 text-center text-[10px] font-bold text-japandi-muted py-0.5">
              <span>M</span>
              <span>T</span>
              <span>W</span>
              <span>T</span>
              <span>F</span>
              <span>S</span>
              <span>S</span>
            </div>

            {/* Days Grid */}
            <div className="grid grid-cols-7 gap-1">
              {Array.from({ length: firstDayOfWeek }).map((_, i) => (
                <div key={`empty-${i}`} className="h-8" />
              ))}

              {Array.from({ length: daysInMonth }).map((_, i) => {
                const day = i + 1;
                const isSelected =
                  parsedDate.getDate() === day &&
                  parsedDate.getMonth() === viewMonth &&
                  parsedDate.getFullYear() === viewYear;

                return (
                  <button
                    key={`day-${day}`}
                    type="button"
                    onClick={() => handleSelectDay(day)}
                    className={`h-8 rounded-japandi-md text-xs font-semibold flex items-center justify-center transition-colors ${
                      isSelected
                        ? 'bg-japandi-pine text-white font-extrabold shadow-japandi-xs'
                        : 'text-japandi-text hover:bg-japandi-sand/80'
                    }`}
                  >
                    {day}
                  </button>
                );
              })}
            </div>

            {/* Quick Actions: Today & Cancel */}
            <div className="mt-1 pt-2.5 border-t border-japandi-border flex items-center justify-between">
              <button
                type="button"
                onClick={() => {
                  const today = new Date();
                  const m = String(today.getMonth() + 1).padStart(2, '0');
                  const d = String(today.getDate()).padStart(2, '0');
                  onChange(`${today.getFullYear()}-${m}-${d}`);
                  setIsOpen(false);
                }}
                className="text-xs font-bold text-japandi-pine hover:underline px-1 py-0.5"
              >
                Today
              </button>
              <button
                type="button"
                onClick={() => setIsOpen(false)}
                className="text-xs font-medium text-japandi-muted hover:text-japandi-text px-1 py-0.5"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
