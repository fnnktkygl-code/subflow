'use client';

import { useEffect, useRef } from 'react';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { pushToGoogleDrive } from '../services/googleDriveSync';

export function useGoogleDriveAutoSync() {
  const subscriptions = useSubscriptionStore((state) => state.subscriptions);
  const profile = useSubscriptionStore((state) => state.profile);
  const accessToken = useSubscriptionStore((state) => state.googleAccount?.accessToken);
  const isInitialMount = useRef(true);
  const debounceTimerRef = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    if (isInitialMount.current) {
      isInitialMount.current = false;
      return;
    }

    if (!accessToken) {
      return;
    }

    if (debounceTimerRef.current) {
      clearTimeout(debounceTimerRef.current);
    }

    debounceTimerRef.current = setTimeout(() => {
      void pushToGoogleDrive().catch(() => { /* Service exposes the failure in the store. */ });
    }, 1500);

    return () => {
      if (debounceTimerRef.current) clearTimeout(debounceTimerRef.current);
    };
  }, [subscriptions, profile, accessToken]);
}
