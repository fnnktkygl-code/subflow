'use client';

import React, { useState } from 'react';
import { TrueLayerBankProvider } from '@subflow/core';

interface BankLogoProps {
  bank: TrueLayerBankProvider;
  size?: number;
}

export const BankLogo: React.FC<BankLogoProps> = ({ bank, size = 40 }) => {
  const [hasError, setHasError] = useState(false);

  // High quality Logo.dev URL for the bank's domain
  const logoUrl = bank.logoUrl || `https://img.logo.dev/${bank.domain}?token=pk_X1cpD_81THS3lP56vQoYTw`;

  const renderFallbackSvg = () => {
    switch (bank.id) {
      case 'stet-boursorama':
        return (
          <div
            style={{ width: size, height: size }}
            className="rounded-xl flex items-center justify-center bg-gradient-to-br from-[#E6007E] to-[#142B47] text-white shadow-xs font-black select-none"
          >
            <span className="text-sm tracking-tighter">B</span>
          </div>
        );
      case 'revolut':
        return (
          <div
            style={{ width: size, height: size }}
            className="rounded-xl flex items-center justify-center bg-black text-white shadow-xs font-black select-none"
          >
            <span className="text-base tracking-tighter font-serif italic">R</span>
          </div>
        );
      case 'stet-bnp-paribas':
        return (
          <div
            style={{ width: size, height: size }}
            className="rounded-xl flex items-center justify-center bg-[#00965E] text-white shadow-xs font-extrabold select-none"
          >
            <span className="text-xs tracking-tight">BNP</span>
          </div>
        );
      case 'stet-credit-agricole':
        return (
          <div
            style={{ width: size, height: size }}
            className="rounded-xl flex items-center justify-center bg-[#007D8F] text-white shadow-xs font-black select-none"
          >
            <span className="text-xs tracking-tight">CA</span>
          </div>
        );
      case 'stet-societe-generale':
        return (
          <div
            style={{ width: size, height: size }}
            className="rounded-xl flex flex-col overflow-hidden shadow-xs border border-japandi-border select-none"
          >
            <div className="flex-1 bg-[#E60028]" />
            <div className="flex-1 bg-black" />
          </div>
        );
      case 'stet-la-banque-postale':
        return (
          <div
            style={{ width: size, height: size }}
            className="rounded-xl flex items-center justify-center bg-[#0C2340] text-[#FFCC00] shadow-xs font-black select-none"
          >
            <span className="text-xs">LBP</span>
          </div>
        );
      default:
        return (
          <div
            style={{ width: size, height: size }}
            className="rounded-xl flex items-center justify-center bg-blue-600 text-white shadow-xs font-bold select-none"
          >
            <span className="text-xs">TL</span>
          </div>
        );
    }
  };

  if (hasError) {
    return renderFallbackSvg();
  }

  return (
    <div
      style={{ width: size, height: size }}
      className="relative rounded-xl overflow-hidden bg-white dark:bg-slate-900 border border-japandi-border shadow-xs flex items-center justify-center flex-shrink-0 p-1 select-none"
    >
      <img
        src={logoUrl}
        alt={`${bank.name} logo`}
        className="w-full h-full object-contain rounded-lg"
        loading="lazy"
        onError={() => setHasError(true)}
      />
    </div>
  );
};
