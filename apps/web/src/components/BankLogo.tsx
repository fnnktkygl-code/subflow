'use client';

import React from 'react';
import { TrueLayerBankProvider } from '@subflow/core';

interface BankLogoProps {
  bank: TrueLayerBankProvider;
  size?: number;
  className?: string;
}

export const BankLogo: React.FC<BankLogoProps> = ({ bank, size = 40, className = '' }) => {
  const renderVectorLogo = () => {
    switch (bank.id) {
      case 'stet-boursorama':
        return (
          <svg viewBox="0 0 100 100" className="w-full h-full drop-shadow-xs select-none" fill="none">
            {/* BoursoBank Fuchsia / Magenta rounded background */}
            <rect width="100" height="100" rx="22" fill="#E6007E" />
            {/* Subtle BoursoBank gradient overlay */}
            <circle cx="85" cy="15" r="45" fill="#142B47" opacity="0.35" />
            {/* Authentic BoursoBank bold modern 'B' mark */}
            <path
              d="M26 22H55C66 22 73 28 73 38C73 44 69 49 63 51C71 53 77 60 77 68C77 78 68 84 56 84H26V22ZM40 34V46H53C58 46 61 43 61 39.5C61 36 58 34 53 34H40ZM40 58V72H54C59 72 63 69 63 65C63 61 59 58 54 58H40Z"
              fill="#FFFFFF"
            />
            <circle cx="76" cy="24" r="6" fill="#142B47" />
          </svg>
        );

      case 'revolut':
        return (
          <svg viewBox="0 0 100 100" className="w-full h-full drop-shadow-xs select-none" fill="none">
            {/* Revolut Pitch Black Background */}
            <rect width="100" height="100" rx="22" fill="#000000" />
            {/* Official Revolut Geometric 'R' */}
            <path
              d="M26 22H53C64 22 71 28 71 38C71 47 64 53 54 54L72 78H58L42 56H39V78H26V22ZM39 33V45H52C57 45 61 42 61 38.5C61 35 57 33 52 33H39Z"
              fill="#FFFFFF"
            />
          </svg>
        );

      case 'stet-bnp-paribas':
        return (
          <svg viewBox="0 0 100 100" className="w-full h-full drop-shadow-xs select-none" fill="none">
            {/* BNP Paribas Emerald Green */}
            <rect width="100" height="100" rx="22" fill="#00915A" />
            {/* Dynamic flight stars motif */}
            <path d="M22 66C32 66 48 54 52 34C48 42 42 48 34 50C28 52 24 58 22 66Z" fill="#FFFFFF" />
            <path d="M38 74C46 72 58 60 62 42C58 48 53 53 46 55C42 56 39 64 38 74Z" fill="#FFFFFF" />
            <path d="M54 78C62 76 72 66 76 50C72 54 68 58 62 60C58 61 55 68 54 78Z" fill="#FFFFFF" />
            <path d="M72 40L75 32L83 30L77 24L78 16L71 20L64 16L66 24L60 30L68 32L72 40Z" fill="#FFFFFF" />
          </svg>
        );

      case 'stet-credit-agricole':
        return (
          <svg viewBox="0 0 100 100" className="w-full h-full drop-shadow-xs select-none" fill="none">
            {/* Crédit Agricole Teal Green */}
            <rect width="100" height="100" rx="22" fill="#007D8F" />
            {/* Authentic CA swoosh monogram */}
            <path
              d="M20 32C20 32 35 26 50 36C40 39 32 47 32 58C32 70 42 76 54 74C64 72 70 64 72 58H58V48H84C84 62 76 76 62 82C44 88 22 80 20 56V32Z"
              fill="#FFFFFF"
            />
            {/* Red accent mark */}
            <path d="M60 26L80 18V38L60 26Z" fill="#E30613" />
          </svg>
        );

      case 'stet-societe-generale':
        return (
          <svg viewBox="0 0 100 100" className="w-full h-full drop-shadow-xs select-none" fill="none">
            <rect width="100" height="100" rx="22" fill="#FFFFFF" />
            <g clipPath="url(#sg-clip-id)">
              <rect width="100" height="50" fill="#E60028" />
              <rect y="50" width="100" height="50" fill="#000000" />
              <rect y="46" width="100" height="8" fill="#FFFFFF" />
            </g>
            <defs>
              <clipPath id="sg-clip-id">
                <rect width="100" height="100" rx="22" />
              </clipPath>
            </defs>
          </svg>
        );

      case 'stet-la-banque-postale':
        return (
          <svg viewBox="0 0 100 100" className="w-full h-full drop-shadow-xs select-none" fill="none">
            {/* La Banque Postale Deep Blue */}
            <rect width="100" height="100" rx="22" fill="#0A2265" />
            {/* Yellow stylized post emblem */}
            <path d="M22 48C36 34 60 28 78 34C64 42 50 48 38 60C30 68 25 76 22 78V48Z" fill="#FFCC00" />
            <path d="M42 62C54 52 70 48 82 50C70 58 60 64 52 74C46 80 43 84 42 84V62Z" fill="#FFCC00" />
          </svg>
        );

      default:
        return (
          <svg viewBox="0 0 100 100" className="w-full h-full drop-shadow-xs select-none" fill="none">
            <rect width="100" height="100" rx="22" fill="#2563EB" />
            <path d="M50 20L75 32V52C75 68 64 80 50 85C36 80 25 68 25 52V32L50 20Z" fill="#1D4ED8" />
            <path d="M52 34L38 52H48L46 66L60 48H50L52 34Z" fill="#FFFFFF" />
          </svg>
        );
    }
  };

  return (
    <div
      style={{ width: size, height: size }}
      className={`relative rounded-xl overflow-hidden shadow-xs flex items-center justify-center flex-shrink-0 select-none ${className}`}
    >
      {renderVectorLogo()}
    </div>
  );
};
