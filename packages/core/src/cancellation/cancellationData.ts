import { COMPLETE_SUBSCRIPTION_CATALOG } from '../presets/catalog';

export interface CancellationGuide {
  serviceName: string;
  directCancelUrl: string;
  threeClicksCompliant: boolean;
  legalEntityName: string;
  postalAddress: string;
  noticePeriodDays: number;
  tips: string;
}

export const CANCELLATION_DATABASE: Record<string, CancellationGuide> = {
  netflix: {
    serviceName: 'Netflix',
    directCancelUrl: 'https://www.netflix.com/cancelplan',
    threeClicksCompliant: true,
    legalEntityName: 'Netflix Services France S.A.S.',
    postalAddress: '10 rue du 4 Septembre, 75002 Paris',
    noticePeriodDays: 0,
    tips: 'Résiliation immédiate en 1 clic. Vous conservez l\'accès jusqu\'à la fin de la période de facturation en cours.'
  },
  spotify: {
    serviceName: 'Spotify',
    directCancelUrl: 'https://www.spotify.com/account/subscription/',
    threeClicksCompliant: true,
    legalEntityName: 'Spotify France SAS',
    postalAddress: '54 rue de Londres, 75008 Paris',
    noticePeriodDays: 0,
    tips: 'Le compte repasse en version gratuite (Free) à la date de fin sans coupure de vos playlists.'
  },
  'chatgpt plus': {
    serviceName: 'ChatGPT Plus (OpenAI)',
    directCancelUrl: 'https://chatgpt.com/#settings/Account',
    threeClicksCompliant: true,
    legalEntityName: 'OpenAI Ireland Ltd.',
    postalAddress: '1 Grand Canal Higher, Dublin, Ireland',
    noticePeriodDays: 0,
    tips: 'Cliquez sur "Manage subscription" puis "Cancel Plan" dans les réglages de votre compte.'
  },
  'canal+': {
    serviceName: 'Canal+',
    directCancelUrl: 'https://client.canalplus.com/abonnement/resiliation',
    threeClicksCompliant: true,
    legalEntityName: 'Groupe CANAL+ Service Résiliation',
    postalAddress: 'TSA 86712, 95905 Cergy-Pontoise Cedex 9',
    noticePeriodDays: 30,
    tips: 'Pour les contrats avec engagement, résiliation possible à l\'échéance avec préavis d\'1 mois (Loi Chatel).'
  },
  'amazon prime': {
    serviceName: 'Amazon Prime',
    directCancelUrl: 'https://www.amazon.fr/mc/manage',
    threeClicksCompliant: true,
    legalEntityName: 'Amazon EU S.à r.l. (Succursale France)',
    postalAddress: '67 boulevard du Général Leclerc, 92110 Clichy',
    noticePeriodDays: 0,
    tips: 'Si vous n\'avez pas utilisé les avantages Prime depuis le renouvellement, Amazon rembourse intégralement.'
  },
  'disney+': {
    serviceName: 'Disney+',
    directCancelUrl: 'https://www.disneyplus.com/account/subscription',
    threeClicksCompliant: true,
    legalEntityName: 'The Walt Disney Company (Benelux) BV',
    postalAddress: '25 boulevard de la Madeleine, 75008 Paris',
    noticePeriodDays: 0,
    tips: 'Annulation en ligne sans frais avec maintien des droits jusqu\'au terme mensuel/annuel.'
  },
  'basic-fit': {
    serviceName: 'Basic-Fit',
    directCancelUrl: 'https://my.basic-fit.com/',
    threeClicksCompliant: true,
    legalEntityName: 'Basic Fit II SAS',
    postalAddress: 'Postbus 3124, 2130 KC Hoofddorp, Pays-Bas',
    noticePeriodDays: 30,
    tips: 'Résiliable depuis l\'espace membre My Basic-Fit ou par lettre recommandée avec accusé de réception.'
  },
  'fitness park': {
    serviceName: 'Fitness Park',
    directCancelUrl: 'https://espace-adherent.fitnesspark.fr/',
    threeClicksCompliant: false,
    legalEntityName: 'Fitness Park Service Résiliation',
    postalAddress: 'Contacter votre club franchisé directement',
    noticePeriodDays: 30,
    tips: 'Chaque salle est une franchise indépendante : lettre recommandée recommandée avec préavis de 30 jours.'
  },
  'free mobile': {
    serviceName: 'Free Mobile',
    directCancelUrl: 'https://mobile.free.fr/moncompte/',
    threeClicksCompliant: true,
    legalEntityName: 'Free Mobile - Service Résiliation',
    postalAddress: '75371 Paris Cedex 08',
    noticePeriodDays: 10,
    tips: 'Si vous changez d\'opérateur, obtenez simplement votre code RIO au 3179 (gratuit) : votre nouvel opérateur résilie automatiquement sans démarche !'
  },
  'pass navigo': {
    serviceName: 'Pass Navigo (Île-de-France Mobilités)',
    directCancelUrl: 'https://www.iledefrance-mobilites.fr/titres-et-tarifs/gestion-forfait',
    threeClicksCompliant: true,
    legalEntityName: 'Comutitres S.A.S. - Forfait Navigo',
    postalAddress: 'TSA 67563, 95905 Cergy-Pontoise Cedex 9',
    noticePeriodDays: 0,
    tips: 'Résiliation ou suspension possible en agence RATP/SNCF ou en ligne avant le 20 du mois en cours.'
  },
  'apple music': {
    serviceName: 'Apple Music / Services',
    directCancelUrl: 'https://support.apple.com/billing',
    threeClicksCompliant: true,
    legalEntityName: 'Apple Distribution International Ltd.',
    postalAddress: 'Hollyhill Industrial Estate, Cork, Irlande',
    noticePeriodDays: 0,
    tips: 'Gérez et annulez directement depuis Réglages > [Votre Nom] > Abonnements sur votre iPhone/Mac.'
  },
  'youtube premium': {
    serviceName: 'YouTube Premium',
    directCancelUrl: 'https://www.youtube.com/paid_memberships',
    threeClicksCompliant: true,
    legalEntityName: 'Google Ireland Ltd.',
    postalAddress: 'Gordon House, Barrow Street, Dublin 4, Irlande',
    noticePeriodDays: 0,
    tips: 'Désactivation immédiate du renouvellement automatique en 1 clic.'
  }
};

export function getCancellationGuide(subscriptionName: string): CancellationGuide | null {
  const norm = subscriptionName.trim().toLowerCase();
  
  if (CANCELLATION_DATABASE[norm]) {
    return CANCELLATION_DATABASE[norm]!;
  }

  for (const [key, guide] of Object.entries(CANCELLATION_DATABASE)) {
    if (norm.includes(key)) {
      return guide;
    }
  }

  // Check 350+ catalog
  const match = COMPLETE_SUBSCRIPTION_CATALOG.find(
    (c) =>
      norm.includes(c.name.toLowerCase()) ||
      c.name.toLowerCase().includes(norm) ||
      (c.domain && norm.includes(c.domain.toLowerCase()))
  );

  if (match) {
    return {
      serviceName: match.name,
      directCancelUrl: match.cancellationUrl || `https://${match.domain}`,
      threeClicksCompliant: match.threeClicksCompliant ?? true,
      legalEntityName: `${match.name} Service Client`,
      postalAddress: 'Siège social / Service Résiliation',
      noticePeriodDays: match.category === 'Utilities' ? 30 : 0,
      tips: match.threeClicksCompliant
        ? 'Bouton de résiliation en 3 clics disponible depuis l\'espace client en ligne.'
        : 'Résiliation disponible via les paramètres du compte ou le service support.'
    };
  }

  // Generic fallback
  return {
    serviceName: subscriptionName,
    directCancelUrl: `https://www.google.com/search?q=résilier+abonnement+${encodeURIComponent(subscriptionName)}+en+ligne`,
    threeClicksCompliant: false,
    legalEntityName: subscriptionName,
    postalAddress: 'Service Client / Service Résiliation',
    noticePeriodDays: 30,
    tips: 'Depuis le 1er juin 2023, la loi française impose à tout professionnel proposant la souscription en ligne d\'offrir un bouton de résiliation en 3 clics.'
  };
}
