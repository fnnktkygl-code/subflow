'use client';
import React, { useEffect, useState } from 'react';
import { getStorageError } from '../store/browserStorage';
export function StorageNotice(): React.ReactElement | null {
  const [error, setError] = useState<string | null>(null);
  useEffect(() => {
    const update = () => setError(getStorageError());
    update(); window.addEventListener('subflow-storage-health', update);
    return () => window.removeEventListener('subflow-storage-health', update);
  }, []);
  return error ? <div role="alert" className="m-4 rounded-xl border border-amber-500 bg-amber-50 p-4 text-sm text-amber-950">{error} <a href="/settings" className="underline font-bold">Ouvrir les sauvegardes</a></div> : null;
}
