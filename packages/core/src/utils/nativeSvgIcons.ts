// Curated collection of clean, lightweight, industry-standard SVG icons for SubFlow
// Adheres strictly to the Japandi design philosophy: simple lines, balanced geometry, WCAG AAA contrast.

export interface NativeSvgIcon {
  id: string;
  name: string;
  category: string;
  viewBox?: string;
  svg: string; // Inner SVG paths / elements
}

export const NATIVE_SVG_ICONS: NativeSvgIcon[] = [
  // ============================================================================
  // 1. STREAMING, MEDIA & ENTERTAINMENT
  // ============================================================================
  {
    id: 'film',
    name: 'Cinéma & Film',
    category: 'Entertainment',
    svg: '<rect x="2" y="2" width="20" height="20" rx="2.18" ry="2.18"/><line x1="7" y1="2" x2="7" y2="22"/><line x1="17" y1="2" x2="17" y2="22"/><line x1="2" y1="12" x2="22" y2="12"/><line x1="2" y1="7" x2="7" y2="7"/><line x1="2" y1="17" x2="7" y2="17"/><line x1="17" y1="17" x2="22" y2="17"/><line x1="17" y1="7" x2="22" y2="7"/>'
  },
  {
    id: 'tv',
    name: 'Télévision & Séries',
    category: 'Entertainment',
    svg: '<rect x="2" y="7" width="20" height="15" rx="2" ry="2"/><polyline points="17 2 12 7 7 2"/>'
  },
  {
    id: 'music',
    name: 'Musique & Hi-Fi',
    category: 'Entertainment',
    svg: '<path d="M9 18V5l12-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="18" cy="16" r="3"/>'
  },
  {
    id: 'headphones',
    name: 'Casque & Podcasts',
    category: 'Entertainment',
    svg: '<path d="M3 18v-6a9 9 0 0 1 18 0v6"/><path d="M21 19a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2h3zM3 19a2 2 0 0 0 2 2h1a2 2 0 0 0 2-2v-3a2 2 0 0 0-2-2H3z"/>'
  },
  {
    id: 'gamepad',
    name: 'Jeux Vidéo & Gaming',
    category: 'Entertainment',
    svg: '<line x1="6" y1="12" x2="10" y2="12"/><line x1="8" y1="10" x2="8" y2="14"/><line x1="15" y1="13" x2="15.01" y2="13"/><line x1="18" y1="11" x2="18.01" y2="11"/><rect x="2" y="6" width="20" height="12" rx="6"/>'
  },
  {
    id: 'radio',
    name: 'Radio & Live Stream',
    category: 'Entertainment',
    svg: '<circle cx="12" cy="12" r="2"/><path d="M16.24 7.76a6 6 0 0 1 0 8.49m-8.48-.01a6 6 0 0 1 0-8.49m11.31-2.82a10 10 0 0 1 0 14.14m-14.14 0a10 10 0 0 1 0-14.14"/>'
  },

  // ============================================================================
  // 2. PRODUCTIVITY, AI, TECH & WORK
  // ============================================================================
  {
    id: 'laptop',
    name: 'Ordinateur & Logiciel',
    category: 'Productivity',
    svg: '<rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/>'
  },
  {
    id: 'cpu',
    name: 'IA, Algorithme & Cloud',
    category: 'Productivity',
    svg: '<rect x="4" y="4" width="16" height="16" rx="2"/><rect x="9" y="9" width="6" height="6"/><line x1="9" y1="1" x2="9" y2="4"/><line x1="15" y1="1" x2="15" y2="4"/><line x1="9" y1="20" x2="9" y2="23"/><line x1="15" y1="20" x2="15" y2="23"/><line x1="20" y1="9" x2="23" y2="9"/><line x1="20" y1="14" x2="23" y2="14"/><line x1="1" y1="9" x2="4" y2="9"/><line x1="1" y1="14" x2="4" y2="14"/>'
  },
  {
    id: 'sparkles',
    name: 'Intelligence Artificielle',
    category: 'Productivity',
    svg: '<path d="m12 3-1.9 5.8a2 2 0 0 1-1.3 1.3L3 12l5.8 1.9a2 2 0 0 1 1.3 1.3L12 21l1.9-5.8a2 2 0 0 1 1.3-1.3L21 12l-5.8-1.9a2 2 0 0 1-1.3-1.3Z"/>'
  },
  {
    id: 'code',
    name: 'Développement & API',
    category: 'Productivity',
    svg: '<polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/>'
  },
  {
    id: 'cloud',
    name: 'Stockage Cloud & Sauvegarde',
    category: 'Productivity',
    svg: '<path d="M17.5 19H9a7 7 0 1 1 6.71-9h1.79a4.5 4.5 0 1 1 0 9Z"/>'
  },
  {
    id: 'palette',
    name: 'Design & Créativité',
    category: 'Productivity',
    svg: '<circle cx="13.5" cy="6.5" r=".5"/><circle cx="17.5" cy="10.5" r=".5"/><circle cx="8.5" cy="7.5" r=".5"/><circle cx="6.5" cy="12.5" r=".5"/><path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10c.926 0 1.648-.746 1.648-1.688 0-.437-.18-.835-.437-1.125-.29-.289-.438-.652-.438-1.125a1.64 1.64 0 0 1 1.668-1.668h1.996c3.051 0 5.555-2.503 5.555-5.554C21.965 6.012 17.461 2 12 2z"/>'
  },
  {
    id: 'book-open',
    name: 'Lecture, Presse & Savoir',
    category: 'Productivity',
    svg: '<path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>'
  },

  // ============================================================================
  // 3. UTILITIES, TELECOMS & HOUSING
  // ============================================================================
  {
    id: 'zap',
    name: 'Électricité & Énergie',
    category: 'Utilities',
    svg: '<polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>'
  },
  {
    id: 'wifi',
    name: 'Box Internet & Fibre',
    category: 'Utilities',
    svg: '<path d="M5 12.55a11 11 0 0 1 14.08 0"/><path d="M1.42 9a16 16 0 0 1 21.16 0"/><path d="M8.53 16.11a6 6 0 0 1 6.95 0"/><line x1="12" y1="20" x2="12.01" y2="20"/>'
  },
  {
    id: 'smartphone',
    name: 'Forfait Mobile & Téléphone',
    category: 'Utilities',
    svg: '<rect x="5" y="2" width="14" height="20" rx="2" ry="2"/><line x1="12" y1="18" x2="12.01" y2="18"/>'
  },
  {
    id: 'home',
    name: 'Logement & Loyer',
    category: 'Utilities',
    svg: '<path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/>'
  },
  {
    id: 'shield',
    name: 'Sécurité & VPN',
    category: 'Utilities',
    svg: '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>'
  },
  {
    id: 'key',
    name: 'Gestionnaire de Mots de Passe',
    category: 'Utilities',
    svg: '<path d="m21 2-2 2m-1.5 1.5L14 9l-3-3-4.5 4.5a5.5 5.5 0 1 0 7.78 7.78L18.7 13.8l1.4 1.4 2.8-2.8-1.4-1.4 2.1-2.1L21 2z"/>'
  },

  // ============================================================================
  // 4. HEALTH, FITNESS & WELL-BEING
  // ============================================================================
  {
    id: 'heart-pulse',
    name: 'Santé & Compléments',
    category: 'Health & Fitness',
    svg: '<path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/><path d="M3.22 12H9.5l1.5-3 2 6.5 1.5-3.5h6.28"/>'
  },
  {
    id: 'dumbbell',
    name: 'Salle de Sport & Musculation',
    category: 'Health & Fitness',
    svg: '<path d="m6.5 6.5 11 11"/><path d="m21 21-1-1a2 2 0 0 0-2.83 0l-2.59 2.59a2 2 0 0 0 0 2.83l1 1a2 2 0 0 0 2.83 0L21 23.83a2 2 0 0 0 0-2.83Z"/><path d="m3 3 1 1a2 2 0 0 0 2.83 0L9.41 1.41a2 2 0 0 0 0-2.83l-1-1a2 2 0 0 0-2.83 0L3 0.17a2 2 0 0 0 0 2.83Z"/><path d="m18 15 1.41-1.41a2 2 0 0 0 0-2.83L15.17 6.5a2 2 0 0 0-2.83 0L10.93 7.91"/><path d="m6 9-1.41 1.41a2 2 0 0 0 0 2.83L8.83 17.5a2 2 0 0 0 2.83 0l1.41-1.41"/>'
  },
  {
    id: 'activity',
    name: 'Course & Running (Strava)',
    category: 'Health & Fitness',
    svg: '<polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>'
  },
  {
    id: 'smile',
    name: 'Méditation & Sommeil',
    category: 'Health & Fitness',
    svg: '<circle cx="12" cy="12" r="10"/><path d="M8 14s1.5 2 4 2 4-2 4-2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/>'
  },

  // ============================================================================
  // 5. FOOD, DINING & GROCERIES
  // ============================================================================
  {
    id: 'coffee',
    name: 'Café & Boissons',
    category: 'Food & Dining',
    svg: '<path d="M18 8h1a4 4 0 0 1 0 8h-1"/><path d="M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8z"/><line x1="6" y1="1" x2="6" y2="4"/><line x1="10" y1="1" x2="10" y2="4"/><line x1="14" y1="1" x2="14" y2="4"/>'
  },
  {
    id: 'utensils',
    name: 'Restaurants & Box Repas',
    category: 'Food & Dining',
    svg: '<path d="M18 2v6a3 3 0 0 1-3 3 3 3 0 0 1-3-3V2"/><path d="M15 11v11"/><path d="M5 2v8a2 2 0 0 0 2 2h1a2 2 0 0 0 2-2V2"/><path d="M7 12v10"/>'
  },
  {
    id: 'shopping-bag',
    name: 'Courses & Livraison',
    category: 'Food & Dining',
    svg: '<path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4Z"/><path d="M3 6h18"/><path d="M16 10a4 4 0 0 1-8 0"/>'
  },

  // ============================================================================
  // 6. SHOPPING & E-COMMERCE
  // ============================================================================
  {
    id: 'shopping-cart',
    name: 'E-Commerce & Amazon',
    category: 'Shopping',
    svg: '<circle cx="8" cy="21" r="1"/><circle cx="19" cy="21" r="1"/><path d="M2.05 2.05h2l2.66 12.42a2 2 0 0 0 2 1.58h9.78a2 2 0 0 0 1.95-1.57l1.65-7.43H5.12"/>'
  },
  {
    id: 'tag',
    name: 'Mode & Vêtements',
    category: 'Shopping',
    svg: '<path d="M12 2H2v10l9.29 9.29c.94.94 2.48.94 3.42 0l6.58-6.58c.94-.94.94-2.48 0-3.42L12 2Z"/><circle cx="7" cy="7" r=".5" fill="currentColor"/>'
  },
  {
    id: 'gift',
    name: 'Box Cadeaux & Surprise',
    category: 'Shopping',
    svg: '<polyline points="20 12 20 22 4 22 4 12"/><rect x="2" y="7" width="20" height="5"/><line x1="12" y1="22" x2="12" y2="7"/><path d="M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z"/><path d="M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z"/>'
  },

  // ============================================================================
  // 7. TRANSPORT & MOBILITY
  // ============================================================================
  {
    id: 'car',
    name: 'Voiture, Leasing & Car-Sharing',
    category: 'Transport',
    svg: '<path d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9C18.7 10.6 16 10 16 10s-1.3-1.4-2.2-2.3c-.5-.4-1.1-.7-1.8-.7H5c-.6 0-1.1.4-1.4.9l-1.4 2.9A3.7 3.7 0 0 0 2 12v4c0 .6.4 1 1 1h2"/><circle cx="7" cy="17" r="2"/><circle cx="17" cy="17" r="2"/><path d="M5 17h2m8 0h2"/>'
  },
  {
    id: 'train',
    name: 'Train & Pass Navigo / SNCF',
    category: 'Transport',
    svg: '<rect x="4" y="3" width="16" height="16" rx="2"/><path d="M4 11h16"/><path d="M12 3v8"/><path d="m8 19-2 3"/><path d="m18 22-2-3"/><circle cx="8" cy="15" r="1"/><circle cx="16" cy="15" r="1"/>'
  },
  {
    id: 'bike',
    name: 'Vélo & Trottinette (Vélib\')',
    category: 'Transport',
    svg: '<circle cx="18.5" cy="17.5" r="3.5"/><circle cx="5.5" cy="17.5" r="3.5"/><circle cx="15" cy="5" r="1"/><path d="M12 17.5V14l-3-3 4-3 2 3h2"/>'
  },

  // ============================================================================
  // 8. BANK, FINANCES & ASSURANCES
  // ============================================================================
  {
    id: 'landmark',
    name: 'Banque & Comptes',
    category: 'General',
    svg: '<line x1="2" y1="22" x2="22" y2="22"/><line x1="12" y1="2" x2="12" y2="6"/><polyline points="2 6 12 2 22 6"/><rect x="4" y="10" width="3" height="12"/><rect x="10.5" y="10" width="3" height="12"/><rect x="17" y="10" width="3" height="12"/>'
  },
  {
    id: 'credit-card',
    name: 'Cotisation Carte & Tenue de Compte',
    category: 'General',
    svg: '<rect x="1" y="4" width="22" height="16" rx="2" ry="2"/><line x1="1" y1="10" x2="23" y2="10"/>'
  },
  {
    id: 'trending-up',
    name: 'Investissement & Courtier',
    category: 'General',
    svg: '<polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/>'
  },

  // ============================================================================
  // 9. GENERAL & WABI-SABI MINIMALIST
  // ============================================================================
  {
    id: 'feather',
    name: 'Sérénité & Wabi-Sabi',
    category: 'General',
    svg: '<path d="M20.24 12.24a6 6 0 0 0-8.49-8.49L5 10.5V19h8.5z"/><line x1="16" y1="8" x2="2" y2="22"/><line x1="17.5" y1="15" x2="9" y2="15"/>'
  },
  {
    id: 'bell',
    name: 'Rappels & Alertes',
    category: 'General',
    svg: '<path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/>'
  },
  {
    id: 'circle-dot',
    name: 'Neutre Minimaliste',
    category: 'General',
    svg: '<circle cx="12" cy="12" r="10"/><circle cx="12" cy="12" r="1"/>'
  }
];

export function getNativeSvgIconById(iconId: string): NativeSvgIcon | undefined {
  return NATIVE_SVG_ICONS.find((i) => i.id === iconId);
}

export function getNativeSvgIconForCategory(category: string): NativeSvgIcon {
  const norm = (category || '').toLowerCase().trim();
  if (norm.includes('entertain') || norm.includes('stream') || norm.includes('music')) {
    return getNativeSvgIconById('film') || NATIVE_SVG_ICONS[0]!;
  }
  if (norm.includes('product') || norm.includes('work') || norm.includes('dev') || norm.includes('ai')) {
    return getNativeSvgIconById('sparkles') || NATIVE_SVG_ICONS[0]!;
  }
  if (norm.includes('util') || norm.includes('telecom') || norm.includes('cloud') || norm.includes('energy')) {
    return getNativeSvgIconById('zap') || NATIVE_SVG_ICONS[0]!;
  }
  if (norm.includes('transport') || norm.includes('auto') || norm.includes('train') || norm.includes('vehic')) {
    return getNativeSvgIconById('train') || NATIVE_SVG_ICONS[0]!;
  }
  if (norm.includes('health') || norm.includes('fit') || norm.includes('gym') || /\bsport\b/.test(norm)) {
    return getNativeSvgIconById('heart-pulse') || NATIVE_SVG_ICONS[0]!;
  }
  if (norm.includes('food') || norm.includes('din') || norm.includes('eat') || norm.includes('cafe')) {
    return getNativeSvgIconById('coffee') || NATIVE_SVG_ICONS[0]!;
  }
  if (norm.includes('shop') || norm.includes('store') || norm.includes('cloth')) {
    return getNativeSvgIconById('shopping-bag') || NATIVE_SVG_ICONS[0]!;
  }
  return getNativeSvgIconById('feather') || NATIVE_SVG_ICONS[0]!;
}


