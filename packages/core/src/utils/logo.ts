export const LOCAL_SVG_LOGOS: Record<string, string> = {
  netflix: '/logos/netflix.svg',
  spotify: '/logos/spotify.svg',
  chatgpt: '/logos/chatgpt.svg',
  'chatgpt plus': '/logos/chatgpt.svg',
  openai: '/logos/chatgpt.svg',
  'amazon prime': '/logos/amazon_prime_video.svg',
  'prime video': '/logos/amazon_prime_video.svg',
  amazon: '/logos/amazon_prime_video.svg',
  'apple tv': '/logos/apple_tv.svg',
  'apple music': '/logos/applemusic.svg',
  applemusic: '/logos/applemusic.svg',
  'canal+': '/logos/canal_plus.svg',
  canalplus: '/logos/canal_plus.svg',
  canal: '/logos/canal_plus.svg',
  canva: '/logos/canva.svg',
  'disney+': '/logos/disney_plus.svg',
  disneyplus: '/logos/disney_plus.svg',
  disney: '/logos/disney_plus.svg',
  figma: '/logos/figma.svg',
  'hbo max': '/logos/hbo_max.svg',
  hbomax: '/logos/hbo_max.svg',
  hulu: '/logos/hulu.svg',
  twitter: '/logos/twitter.svg',
  typeform: '/logos/typeform.svg',
  youtube: '/logos/youtube.svg',
  'youtube premium': '/logos/youtube.svg',
  barbie: '/logos/barbie.svg'
};

export const KNOWN_BRAND_DOMAINS: Record<string, string> = {
  netflix: 'netflix.com',
  spotify: 'spotify.com',
  amazon: 'amazon.com',
  'amazon prime': 'amazon.com',
  'prime video': 'primevideo.com',
  prime: 'primevideo.com',
  apple: 'apple.com',
  'apple music': 'apple.com',
  'apple tv': 'apple.com',
  'apple one': 'apple.com',
  icloud: 'apple.com',
  'icloud+': 'apple.com',
  'icloud+ 200gb': 'apple.com',
  disney: 'disneyplus.com',
  'disney+': 'disneyplus.com',
  'disney plus': 'disneyplus.com',
  youtube: 'youtube.com',
  'youtube premium': 'youtube.com',
  'youtube music': 'youtube.com',
  github: 'github.com',
  'github copilot': 'github.com',
  openai: 'openai.com',
  chatgpt: 'openai.com',
  'chatgpt plus': 'openai.com',
  notion: 'notion.so',
  'notion plus': 'notion.so',
  'notion ai': 'notion.so',
  figma: 'figma.com',
  canva: 'canva.com',
  adobe: 'adobe.com',
  'creative cloud': 'adobe.com',
  playstation: 'playstation.com',
  'ps plus': 'playstation.com',
  xbox: 'xbox.com',
  'xbox game pass': 'xbox.com',
  nintendo: 'nintendo.com',
  'nintendo switch online': 'nintendo.com',
  'basic fit': 'basic-fit.com',
  'basic-fit': 'basic-fit.com',
  fitnesspark: 'fitnesspark.fr',
  'fitness park': 'fitnesspark.fr',
  canal: 'canalplus.com',
  'canal+': 'canalplus.com',
  'canal plus': 'canalplus.com',
  mycanal: 'canalplus.com',
  deezer: 'deezer.com',
  'deezer premium': 'deezer.com',
  free: 'free.fr',
  'free mobile': 'free.fr',
  freebox: 'free.fr',
  orange: 'orange.fr',
  sosh: 'sosh.fr',
  sfr: 'sfr.fr',
  'red by sfr': 'red-by-sfr.fr',
  bouygues: 'bouyguestelecom.fr',
  'b&you': 'b-and-you.fr',
  edf: 'edf.fr',
  engie: 'engie.fr',
  totalenergies: 'totalenergies.fr',
  lefigaro: 'lefigaro.fr',
  'le figaro': 'lefigaro.fr',
  lemonde: 'lemonde.fr',
  'le monde': 'lemonde.fr',
  mediapart: 'mediapart.fr',
  lequipe: 'lequipe.fr',
  "l'equipe": 'lequipe.fr',
  strava: 'strava.com',
  duolingo: 'duolingo.com',
  crunchyroll: 'crunchyroll.com',
  max: 'max.com',
  'hbo max': 'max.com',
  'paramount+': 'paramountplus.com',
  dazn: 'dazn.com',
  uber: 'uber.com',
  'uber one': 'uber.com',
  deliveroo: 'deliveroo.fr',
  'pass navigo': 'iledefrance-mobilites.fr',
  navigo: 'iledefrance-mobilites.fr',
  sncf: 'sncf-connect.com',
  'max actif': 'sncf-connect.com',
  subflow: 'subflowapp.vercel.app'
};

export function extractDomain(subscriptionName: string): string {
  let trimmed = subscriptionName.trim().toLowerCase();
  if (!trimmed) return '';

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    try {
      const url = new URL(trimmed);
      return url.hostname.replace(/^www\./, '');
    } catch (_) {}
  }

  const noSpaces = trimmed.replace(/\s+/g, '');

  if (KNOWN_BRAND_DOMAINS[trimmed]) {
    return KNOWN_BRAND_DOMAINS[trimmed];
  }
  if (KNOWN_BRAND_DOMAINS[noSpaces]) {
    return KNOWN_BRAND_DOMAINS[noSpaces];
  }

  for (const [key, domain] of Object.entries(KNOWN_BRAND_DOMAINS)) {
    if (trimmed.includes(key) || noSpaces.includes(key.replace(/\s+/g, ''))) {
      return domain;
    }
  }

  const cleaned = trimmed.replace(/[^a-z0-9\.\-]/g, '');
  if (!cleaned) return '';

  if (cleaned.includes('.')) {
    return cleaned;
  }

  return `${cleaned}.com`;
}

export function fetchLogo(subscriptionName: string): string {
  const trimmed = subscriptionName.trim();
  if (!trimmed) return '';

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://') || trimmed.startsWith('/')) {
    return trimmed;
  }

  const norm = trimmed.toLowerCase();
  if (LOCAL_SVG_LOGOS[norm]) {
    return LOCAL_SVG_LOGOS[norm];
  }

  const domain = extractDomain(trimmed);
  if (!domain) return '';

  return `https://www.google.com/s2/favicons?domain=${domain}&sz=128`;
}

export function getLogoSources(subscriptionName: string): string[] {
  const trimmed = subscriptionName.trim();
  if (!trimmed) return [];

  const norm = trimmed.toLowerCase();
  const sources: string[] = [];

  if (LOCAL_SVG_LOGOS[norm]) {
    sources.push(LOCAL_SVG_LOGOS[norm]!);
  }

  if (trimmed.startsWith('http://') || trimmed.startsWith('https://') || trimmed.startsWith('/')) {
    sources.push(trimmed);
  }

  const domain = extractDomain(trimmed);
  if (domain) {
    sources.push(`https://www.google.com/s2/favicons?domain=${domain}&sz=128`);
    sources.push(`https://unavatar.io/${domain}`);
    sources.push(`https://icon.horse/icon/${domain}`);
  }

  return sources;
}
