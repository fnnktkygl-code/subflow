'use client';
import { pick } from '@subflow/core';
import React, { useEffect, useState } from 'react';
import { getStorageError } from '../store/browserStorage';
import { useTranslation } from '../hooks/useTranslation';
import { translateMessage } from '../lib/messages';
export function StorageNotice(): React.ReactElement | null {
  const { locale } = useTranslation();
  const [error, setError] = useState<string | null>(null);
  useEffect(() => {
    const update = () => setError(getStorageError());
    update(); window.addEventListener('subflow-storage-health', update);
    return () => window.removeEventListener('subflow-storage-health', update);
  }, []);
  return error ? <div role="alert" className="m-4 rounded-xl border border-amber-500 bg-amber-50 p-4 text-sm text-amber-950">{translateMessage(error, locale)} <a href="/settings" className="underline font-bold">{pick(locale, { fr: 'Ouvrir les sauvegardes', en: 'Open backups', es: 'Abrir las copias' })}</a></div> : null;
}
