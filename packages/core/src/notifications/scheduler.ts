import { Subscription } from '../types';
import { calculateUpcomingOccurrences } from '../math/budget';

export interface PendingNotification {
  id: string;
  subscriptionName: string;
  amount: number;
  currencySymbol: string;
  dueFormatted: string;
  daysRemaining: number;
  title: string;
  body: string;
}

export function getUpcomingRenewalsForNotification(
  subscriptions: Subscription[],
  referenceDate: Date = new Date(),
  leadDays: number = 2 // 48h = 2 days
): PendingNotification[] {
  const occurrences = calculateUpcomingOccurrences(subscriptions, referenceDate, leadDays);

  return occurrences.map((occ) => {
    const sub = occ.subscription;
    const days = occ.daysRemaining;

    let timeText = 'aujourd\'hui';
    if (days === 1) timeText = 'demain';
    else if (days === 2) timeText = 'dans 2 jours';
    else if (days > 2) timeText = `dans ${days} jours`;

    const currency = sub.currencySymbol || '€';
    const amountStr = `${currency}${sub.amount.toFixed(2)}`;

    return {
      id: `notif-${sub.id}-${occ.dueDate.toISOString().split('T')[0]}`,
      subscriptionName: sub.name,
      amount: sub.amount,
      currencySymbol: currency,
      dueFormatted: occ.formattedDate,
      daysRemaining: days,
      title: `🔔 Échéance SubFlow : ${sub.name}`,
      body: `Votre abonnement ${sub.name} (${amountStr}) sera prélevé ${timeText} (${occ.formattedDate}).`
    };
  });
}
