'use client';
import { pick } from '@subflow/core';

// Mini Uko for the what-if bar: thinks while you explore, celebrates each time
// an extra subscription is set aside (and savings grow).

import React, { useEffect, useRef, useState } from 'react';
import { UkoMascot } from './UkoMascot';
import type { UkoState } from './ukoBus';
import { useTranslation } from '../../hooks/useTranslation';

export const WhatIfUko: React.FC<{ excludedCount: number }> = ({ excludedCount }) => {
  const { locale } = useTranslation();
  const [state, setState] = useState<UkoState>('thinking');
  const prev = useRef(excludedCount);
  useEffect(() => {
    if (excludedCount > prev.current) {
      setState('idle');
      requestAnimationFrame(() => setState('success'));
    } else if (excludedCount === 0) setState('thinking');
    prev.current = excludedCount;
  }, [excludedCount]);
  return (
    <UkoMascot
      state={state}
      interactive={false}
      className="w-9 h-[52px] -my-2 flex-shrink-0"
      label={pick(locale, { fr: 'Uko calcule vos économies', en: 'Uko works out your savings', es: 'Uko calcula tu ahorro' })}
      onComplete={(done) => { if (done === 'success') setState(excludedCount ? 'idle' : 'thinking'); }}
    />
  );
};
