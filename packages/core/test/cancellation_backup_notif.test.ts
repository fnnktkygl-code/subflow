import { describe, it, expect } from 'vitest';
import {
  getCancellationGuide,
  generateCancellationLetter,
  exportSubscriptionsToCSV,
  parseSubscriptionsFromCSV,
  encryptBackupData,
  decryptBackupData,
  getUpcomingRenewalsForNotification,
  Subscription
} from '../src';

describe('1. 1-Click Cancellation Assistant & Legal Letters', () => {
  it('fetches exact direct cancellation URLs and legal addresses for known services', () => {
    const netflixGuide = getCancellationGuide('Netflix');
    expect(netflixGuide).toBeDefined();
    expect(netflixGuide?.directCancelUrl).toContain('netflix.com/cancelplan');
    expect(netflixGuide?.threeClicksCompliant).toBe(true);

    const canalGuide = getCancellationGuide('Canal+');
    expect(canalGuide?.postalAddress).toContain('Cergy-Pontoise');
  });

  it('generates a compliant Loi Chatel cancellation letter', () => {
    const letter = generateCancellationLetter({
      senderName: 'Richard Dupont',
      senderAddress: '12 rue de la Paix',
      senderCity: '75002 Paris',
      serviceName: 'Canal+',
      recipientEntity: 'Groupe CANAL+ Service Résiliation',
      recipientAddress: 'TSA 86712, 95905 Cergy-Pontoise',
      reason: 'echeance_chatel',
      contractNumber: 'CANAL-987654'
    });

    expect(letter).toContain('Loi Chatel');
    expect(letter).toContain('Art. L. 215-1');
    expect(letter).toContain('Richard Dupont');
    expect(letter).toContain('CANAL-987654');
  });

  it('generates a price hike cancellation letter (Art. L. 224-33)', () => {
    const letter = generateCancellationLetter({
      senderName: 'Richard Dupont',
      senderAddress: '12 rue de la Paix',
      senderCity: '75002 Paris',
      serviceName: 'Free Mobile',
      recipientEntity: 'Free Mobile',
      recipientAddress: '75371 Paris Cedex 08',
      reason: 'hausse_tarif'
    });

    expect(letter).toContain('L. 224-33');
    expect(letter).toContain('sans pénalité ni frais');
  });
});

describe('2. CSV Import / Export Engine (RFC 4180)', () => {
  const sampleSubs: Subscription[] = [
    {
      id: 'sub-1',
      name: 'Netflix, Premium',
      amount: 19.99,
      category: 'Entertainment',
      cycle: 'Monthly',
      startDate: '2026-08-01',
      notes: 'Family "shared" account'
    },
    {
      id: 'sub-2',
      name: 'Gym',
      amount: 360,
      category: 'Health & Fitness',
      cycle: 'Yearly',
      startDate: '2026-08-01'
    }
  ];

  it('exports subscriptions into RFC 4180 compliant CSV string', () => {
    const csv = exportSubscriptionsToCSV(sampleSubs);
    expect(csv).toContain('"Netflix, Premium"');
    expect(csv).toContain('"Family ""shared"" account"');
    expect(csv).toContain('360');
  });

  it('parses CSV string back into valid Subscription objects', () => {
    const csv = exportSubscriptionsToCSV(sampleSubs);
    const parsed = parseSubscriptionsFromCSV(csv);
    expect(parsed.length).toBe(2);
    expect(parsed[0]?.name).toBe('Netflix, Premium');
    expect(parsed[0]?.amount).toBe(19.99);
    expect(parsed[0]?.notes).toBe('Family "shared" account');
    expect(parsed[1]?.name).toBe('Gym');
    expect(parsed[1]?.amount).toBe(360);
  });
});

describe('3. WebCrypto AES-GCM Encrypted Backup Engine', () => {
  const testData = {
    profile: { name: 'Richard', currency: 'EUR' },
    subscriptions: [
      { id: '1', name: 'Secret VPN', amount: 5 }
    ]
  };

  it('encrypts data and decrypts successfully with correct password', async () => {
    const password = 'SuperSecurePassword123!';
    const encryptedString = await encryptBackupData(testData, password);

    expect(encryptedString).toContain('ciphertext');
    expect(encryptedString).toContain('salt');
    expect(encryptedString).toContain('iv');

    const decrypted = await decryptBackupData(encryptedString, password);
    expect(decrypted).toEqual(testData);
  });

  it('rejects decryption when password is wrong', async () => {
    const password = 'CorrectPassword123!';
    const encryptedString = await encryptBackupData(testData, password);

    await expect(decryptBackupData(encryptedString, 'WrongPassword456!')).rejects.toThrow(
      'Incorrect password or corrupted backup file.'
    );
  });
});

describe('4. Local Notification Scheduler (48h Reminders)', () => {
  const subs: Subscription[] = [
    {
      id: 'sub-netflix',
      name: 'Netflix',
      amount: 13.49,
      category: 'Entertainment',
      cycle: 'Monthly',
      startDate: '2026-08-29' // In 2 days from Aug 27, 2026
    },
    {
      id: 'sub-far',
      name: 'Far Away Sub',
      amount: 50,
      category: 'Utilities',
      cycle: 'Monthly',
      startDate: '2026-09-15'
    }
  ];

  it('schedules notification for subscriptions due in the next 48h (2 days)', () => {
    const refDate = new Date(2026, 7, 27); // Aug 27, 2026
    const notifications = getUpcomingRenewalsForNotification(subs, refDate, 2);

    expect(notifications.length).toBe(1);
    expect(notifications[0]?.subscriptionName).toBe('Netflix');
    expect(notifications[0]?.daysRemaining).toBe(2);
    expect(notifications[0]?.body).toContain('dans 2 jours');
  });
});
