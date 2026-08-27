'use client';

import { useEffect, useRef } from 'react';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { pushToGoogleDrive } from '../services/googleDriveSync';

export function useGoogleDriveAutoSync() {
  const subscriptions = useSubscriptionStore((state) => state.subscriptions);
  const profile = useSubscriptionStore((state) => state.profile);
  const googleAccount = useSubscriptionStore((state) => state.googleAccount);
  const isInitialMount = useRef(true);
  const debounceTimerRef = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    if (isInitialMount.current) {
      isInitialMount.current = false;
      return;
    }

    if (!googleAccount || !googleAccount.accessToken) {
      return;
    }

    if (debounceTimerRef.current) {
      clearTimeout(debounceTimerRef.current);
    }

    debounceTimerRef.current = setTimeout(() => {
      pushToGoogleDrive();
    }, 1500);

    return () => {
      if (debounceTimerRef.current) clearTimeout(debounceTimerRef.current);
    };
  }, [subscriptions, profile, googleAccount]);
}
