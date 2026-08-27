'use client';

import React, { useState, useEffect } from 'react';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useTranslation } from '../hooks/useTranslation';
import { getUpcomingRenewalsForNotification } from '@subflow/core';
import { Bell, Check, BellRing, ShieldCheck, Sparkles, Send } from 'lucide-react';

export const NotificationSettingsCard: React.FC = () => {
  const { subscriptions } = useSubscriptionStore();
  const { t } = useTranslation();
  const [permission, setPermission] = useState<NotificationPermission>('default');
  const [leadTime, setLeadTime] = useState<number>(2); // 2 days = 48h
  const [testSent, setTestSent] = useState(false);

  useEffect(() => {
    if (typeof window !== 'undefined' && 'Notification' in window) {
      setPermission(Notification.permission);
    }
  }, []);

  const handleRequestPermission = async () => {
    if (typeof window !== 'undefined' && 'Notification' in window) {
      const res = await Notification.requestPermission();
      setPermission(res);
    }
  };

  const handleSendTestNotification = () => {
    const upcoming = getUpcomingRenewalsForNotification(subscriptions, new Date(), leadTime);
    const firstSub = subscriptions[0];
    const item = upcoming[0] || {
      title: firstSub ? `🔔 SubFlow : ${firstSub.name}` : '🔔 SubFlow Notifications',
      body: firstSub ? `Votre abonnement ${firstSub.name} arrive bientôt à échéance.` : 'Les notifications de prélèvement sont actives !'
    };

    if (typeof window !== 'undefined' && 'Notification' in window && Notification.permission === 'granted') {
      new Notification(item.title, {
        body: item.body,
        icon: firstSub?.logoUrl || '/icon-192.png'
      });
    }


    setTestSent(true);
    setTimeout(() => setTestSent(false), 3000);
  };

  return (
    <div className="rounded-japandi-2xl bg-japandi-surface border border-japandi-border p-5 sm:p-6 shadow-japandi-sm flex flex-col gap-4">
      <div className="flex items-center justify-between pb-3 border-b border-japandi-border">
        <div className="flex items-center gap-2.5">
          <div className="w-8 h-8 rounded-japandi-full bg-japandi-pine/10 flex items-center justify-center text-japandi-pine">
            <BellRing className="w-4 h-4" />
          </div>
          <div>
            <h3 className="font-extrabold text-sm text-japandi-text">
              {t('notifications.title')}
            </h3>
            <p className="text-[11px] text-japandi-muted">
              {t('notifications.subtitle')}
            </p>
          </div>
        </div>

        {permission === 'granted' ? (
          <span className="text-[10px] font-extrabold px-2 py-0.5 rounded-japandi-full bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20 flex items-center gap-1">
            <Check className="w-3 h-3" />
            <span>{t('common.active')}</span>
          </span>
        ) : (
          <button
            type="button"
            onClick={handleRequestPermission}
            className="px-3 py-1.5 rounded-japandi-md bg-japandi-pine text-white text-xs font-bold shadow-xs hover:bg-japandi-pine/90 transition-all"
          >
            {t('common.confirm')}
          </button>
        )}
      </div>

      {/* Configuration Lead Time */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 items-center">
        <div>
          <label className="block text-xs font-bold text-japandi-text mb-1">
            {t('notifications.reminderTiming')}
          </label>
          <select
            value={leadTime}
            onChange={(e) => setLeadTime(parseInt(e.target.value, 10))}
            className="w-full text-xs font-semibold px-3 py-2 rounded-japandi-md bg-japandi-elevated border border-japandi-border text-japandi-text focus:outline-none focus:ring-1 focus:ring-japandi-pine"
          >
            <option value={2}>{t('notifications.hours48')}</option>
            <option value={1}>{t('notifications.hours24')}</option>
            <option value={0}>{t('notifications.dayOf')}</option>
          </select>
        </div>

        <div>
          <label className="block text-xs font-bold text-japandi-text mb-1">
            {t('notifications.testBtn')}
          </label>
          <button
            type="button"
            onClick={handleSendTestNotification}
            className="w-full py-2 px-3 rounded-japandi-md bg-japandi-elevated border border-japandi-border hover:border-japandi-pine text-japandi-text text-xs font-bold flex items-center justify-center gap-1.5 transition-colors shadow-2xs"
          >
            <Send className="w-3.5 h-3.5 text-japandi-pine" />
            <span>{testSent ? '✓ Test Sent!' : t('notifications.testBtn')}</span>
          </button>
        </div>
      </div>

      <div className="p-3 rounded-japandi-lg bg-japandi-sand/40 border border-japandi-border flex items-center gap-2 text-[11px] text-japandi-muted">
        <ShieldCheck className="w-4 h-4 text-japandi-pine flex-shrink-0" />
        <span>{t('notifications.subtitle')}</span>
      </div>
    </div>
  );
};
