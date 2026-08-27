'use client';

import React, { useState } from 'react';
import { TrueLayerBankProvider } from '@subflow/core';

interface BankLogoProps {
  bank: TrueLayerBankProvider;
  size?: number;
  className?: string;
}

const BANK_ASSET_MAP: Record<string, string> = {
  'stet-boursorama': '/banks/boursobank.png',
  'revolut': '/banks/revolut.png',
  'stet-bnp-paribas': '/banks/bnpparibas.png',
  'stet-credit-agricole': '/banks/credit_agricole.png',
  'stet-societe-generale': '/banks/societe_generale.png',
  'stet-la-banque-postale': '/banks/la_banque_postale.png',
  'mock-sandbox': '/banks/truelayer.svg'
};

export const BankLogo: React.FC<BankLogoProps> = ({ bank, size = 40, className = '' }) => {
  const [hasError, setHasError] = useState(false);
  const assetSrc = BANK_ASSET_MAP[bank.id] || '/banks/truelayer.svg';

  return (
    <div
      style={{ width: size, height: size }}
      className={`relative rounded-xl overflow-hidden shadow-xs flex items-center justify-center flex-shrink-0 bg-white dark:bg-slate-900 border border-japandi-border/40 select-none ${className}`}
    >
      <img
        src={assetSrc}
        alt={`${bank.name} logo officiel`}
        className="w-full h-full object-contain rounded-xl"
        loading="eager"
        onError={() => setHasError(true)}
      />
    </div>
  );
};
