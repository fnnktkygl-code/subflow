'use client';
import React, { useEffect, useRef, useState } from 'react';
import Link from 'next/link';
import { ArrowRight, ArrowUpRight, Check } from 'lucide-react';
import { Locale } from '@subflow/core';
import { PhoneClip } from '../components/landing/PhoneClip';
import { UkoMascot } from '../components/uko/UkoMascot';
import type { UkoState } from '../components/uko/ukoBus';
import { useTranslation } from '../hooks/useTranslation';
import './landing.css';

// Every clip is a screen recording of the real app in the page's language
// (fictitious data, real speed): public/landing/<fr|en|es>/<clip>.mp4.
const CLIPS = ['add', 'calendar', 'simulate', 'cancel'] as const;
// The same rules as in the app (ActionableInsightHeader + the add form).
const MOOD_STATES: UkoState[] = ['empty', 'thinking', 'success', 'error', 'sleep'];

type Copy = {
  nav: [string, string, string]; open: string; home: string;
  eyebrow: string; h1: React.ReactNode; lead: string; start: string; demo: string;
  heroLabel: string; heroUko: string; caption: string;
  factsLabel: string; facts: [string, string, string, string, string];
  tourEyebrow: string; tourTitle: React.ReactNode;
  steps: { tag: string; title: React.ReactNode; text: string; points: string[] }[];
  ukoEyebrow: string; ukoTitle: React.ReactNode; ukoLead: string; moodsLabel: string;
  moods: { label: string; text: string }[];
  privacyEyebrow: string; privacyTitle: React.ReactNode; privacy: string[]; privacyNote: string; privacyLink: string;
  closingTitle: React.ReactNode; closingText: string; closingCta: string; feedback: string;
};

const COPY: Record<Locale, Copy> = {
  fr: {
    nav: ['Fonctions', 'Uko', 'Vie privée'], open: 'Ouvrir l’app', home: 'SubFlow accueil',
    eyebrow: 'Gratuit · Sans compte · Sans publicité',
    h1: <>Vos prélèvements.<br />Votre <em>tranquillité.</em></>,
    lead: 'Retrouvez ce qui revient chaque mois, voyez ce qui arrive, et décidez de ce qui reste.',
    start: 'Commencer', demo: 'Essayer avec des données fictives',
    heroLabel: 'SubFlow, écran d’accueil : Uko et les trois thèmes (clair, sombre, rose)', heroUko: 'Uko, le compagnon de SubFlow, vous salue',
    caption: 'Enregistrement de l’app · données fictives',
    factsLabel: 'SubFlow en bref', facts: ['services pré-remplis', 'compte requis', 'publicité', 'thèmes', 'langues'],
    tourEyebrow: 'Filmé dans l’app', tourTitle: <>Quatre gestes.<br /><em>L’essentiel.</em></>,
    steps: [
      { tag: 'Ajouter', title: <>Trois lettres,<br /><em>c’est ajouté.</em></>, text: 'Tapez « Netf » : Netflix apparaît avec son logo et son prix. Un tap, et votre coût mensuel est à jour.', points: ['357 services pré-remplis', 'Mensuel, annuel ou hebdomadaire', 'Montant et date modifiables'] },
      { tag: 'Anticiper', title: <>Chaque prélèvement,<br /><em>à sa date.</em></>, text: 'Le calendrier marque les jours de prélèvement et totalise le mois. Touchez un jour pour voir le détail.', points: ['Total des prélèvements du mois', 'Navigation de mois en mois', 'Ajout depuis un jour choisi'] },
      { tag: 'Simuler', title: <>Décochez.<br /><em>Voyez l’économie.</em></>, text: 'En mode simulation, écartez un abonnement : le total baisse et l’économie s’affiche. Rien n’est résilié.', points: ['Coût mensuel et annuel recalculés', 'Vos abonnements restent intacts', 'Sortie de la simulation en un tap'] },
      { tag: 'Résilier', title: <>Résilier,<br /><em>sans chercher.</em></>, text: 'Depuis un abonnement, l’assistant ouvre la page de résiliation du service et prépare une lettre type.', points: ['Lien vers la page de résiliation', 'Préavis indicatif', 'Lettre à compléter et copier'] }
    ],
    ukoEyebrow: 'Le compagnon', ukoTitle: <>Uko suit<br /><em>vos comptes.</em></>,
    ukoLead: 'Il réagit à ce qui se passe dans l’app et prend les couleurs de votre thème. Touchez une situation :', moodsLabel: 'Situations',
    moods: [
      { label: 'Liste vide', text: 'Aucun abonnement pour l’instant.' },
      { label: 'Prélèvement proche', text: 'Un débit arrive dans les prochains jours.' },
      { label: 'Tout va bien', text: 'Ajout réussi, budget respecté.' },
      { label: 'Attention', text: 'Budget dépassé ou saisie incomplète.' },
      { label: 'Rien à signaler', text: 'Tout est calme.' }
    ],
    privacyEyebrow: 'Vie privée', privacyTitle: <>Vos données.<br /><em>Vos choix.</em></>,
    privacy: ['Sans compte : vos données restent dans votre navigateur.', 'Aucune connexion bancaire nécessaire.', 'Export CSV, ou fichier chiffré par votre mot de passe.', 'Sauvegarde Google Drive facultative.', 'Pas de publicité.'],
    privacyNote: 'Le stockage du navigateur n’est pas chiffré par SubFlow, et la sauvegarde Google Drive n’est pas chiffrée de bout en bout.',
    privacyLink: 'Politique de confidentialité',
    closingTitle: <>Faites le point.<br /><em>Gardez l’esprit libre.</em></>,
    closingText: 'Le suivi, la simulation et l’export sont gratuits. Pas de carte bancaire.',
    closingCta: 'Ajouter mon premier prélèvement', feedback: 'Une idée pour SubFlow ? Écrivez-nous.'
  },
  en: {
    nav: ['Features', 'Uko', 'Privacy'], open: 'Open the app', home: 'SubFlow home',
    eyebrow: 'Free · No account · No ads',
    h1: <>Your recurring payments.<br />Your <em>peace of mind.</em></>,
    lead: 'See what comes back every month, what is coming next, and decide what stays.',
    start: 'Get started', demo: 'Try it with sample data',
    heroLabel: 'SubFlow home screen: Uko and the three themes (light, dark, pink)', heroUko: 'Uko, the SubFlow companion, says hello',
    caption: 'Recorded in the app · sample data',
    factsLabel: 'SubFlow at a glance', facts: ['pre-filled services', 'accounts needed', 'ads', 'themes', 'languages'],
    tourEyebrow: 'Filmed in the app', tourTitle: <>Four moves.<br /><em>The essentials.</em></>,
    steps: [
      { tag: 'Add', title: <>Three letters,<br /><em>and it is added.</em></>, text: 'Type “Netf”: Netflix shows up with its logo and price. One tap, and your monthly cost is up to date.', points: ['357 pre-filled services', 'Monthly, yearly or weekly', 'Amount and date can be edited'] },
      { tag: 'Plan', title: <>Every payment,<br /><em>on its date.</em></>, text: 'The calendar marks each payment day and adds up the month. Tap a day to see the details.', points: ['Total of the month’s payments', 'Month-by-month navigation', 'Add from a chosen day'] },
      { tag: 'Simulate', title: <>Untick it.<br /><em>See the savings.</em></>, text: 'In simulation mode, leave a subscription out: the total drops and the savings show up. Nothing is cancelled.', points: ['Monthly and yearly cost recalculated', 'Your subscriptions stay untouched', 'Leave the simulation in one tap'] },
      { tag: 'Cancel', title: <>Cancel,<br /><em>without searching.</em></>, text: 'From a subscription, the assistant opens the service’s cancellation page and prepares a template letter.', points: ['Link to the cancellation page', 'Indicative notice period', 'Letter to complete and copy'] }
    ],
    ukoEyebrow: 'The companion', ukoTitle: <>Uko keeps an eye<br /><em>on your budget.</em></>,
    ukoLead: 'He reacts to what happens in the app and takes on your theme’s colours. Tap a situation:', moodsLabel: 'Situations',
    moods: [
      { label: 'Empty list', text: 'No subscriptions yet.' },
      { label: 'Payment soon', text: 'A payment is due in the next few days.' },
      { label: 'All good', text: 'Added successfully, budget respected.' },
      { label: 'Heads up', text: 'Budget exceeded or form incomplete.' },
      { label: 'All quiet', text: 'Nothing to report.' }
    ],
    privacyEyebrow: 'Privacy', privacyTitle: <>Your data.<br /><em>Your choices.</em></>,
    privacy: ['No account: your data stays in your browser.', 'No bank connection needed.', 'CSV export, or a file encrypted with your password.', 'Optional Google Drive backup.', 'No ads.'],
    privacyNote: 'Browser storage is not encrypted by SubFlow, and the Google Drive backup is not end-to-end encrypted.',
    privacyLink: 'Privacy policy',
    closingTitle: <>Take stock.<br /><em>Keep a clear mind.</em></>,
    closingText: 'Tracking, simulation and export are free. No credit card.',
    closingCta: 'Add my first payment', feedback: 'An idea for SubFlow? Write to us.'
  },
  es: {
    nav: ['Funciones', 'Uko', 'Privacidad'], open: 'Abrir la app', home: 'Inicio de SubFlow',
    eyebrow: 'Gratis · Sin cuenta · Sin anuncios',
    h1: <>Tus cargos recurrentes.<br />Tu <em>tranquilidad.</em></>,
    lead: 'Ve lo que vuelve cada mes, lo que está por llegar, y decide qué se queda.',
    start: 'Empezar', demo: 'Probar con datos de ejemplo',
    heroLabel: 'Pantalla de inicio de SubFlow: Uko y los tres temas (claro, oscuro, rosa)', heroUko: 'Uko, el compañero de SubFlow, te saluda',
    caption: 'Grabado en la app · datos de ejemplo',
    factsLabel: 'SubFlow en breve', facts: ['servicios predefinidos', 'cuentas necesarias', 'anuncios', 'temas', 'idiomas'],
    tourEyebrow: 'Grabado en la app', tourTitle: <>Cuatro gestos.<br /><em>Lo esencial.</em></>,
    steps: [
      { tag: 'Añadir', title: <>Tres letras,<br /><em>y ya está.</em></>, text: 'Escribe «Netf»: aparece Netflix con su logo y su precio. Un toque, y tu coste mensual se actualiza.', points: ['357 servicios predefinidos', 'Mensual, anual o semanal', 'Importe y fecha editables'] },
      { tag: 'Anticipar', title: <>Cada cargo,<br /><em>en su fecha.</em></>, text: 'El calendario marca los días de cargo y suma el mes. Toca un día para ver el detalle.', points: ['Total de cargos del mes', 'Navegación mes a mes', 'Añadir desde un día elegido'] },
      { tag: 'Simular', title: <>Desmárcala.<br /><em>Mira el ahorro.</em></>, text: 'En modo simulación, deja fuera una suscripción: el total baja y aparece el ahorro. No se da de baja nada.', points: ['Coste mensual y anual recalculado', 'Tus suscripciones no cambian', 'Salir de la simulación con un toque'] },
      { tag: 'Dar de baja', title: <>Date de baja,<br /><em>sin buscar.</em></>, text: 'Desde una suscripción, el asistente abre la página de baja del servicio y prepara una carta modelo.', points: ['Enlace a la página de baja', 'Preaviso orientativo', 'Carta para completar y copiar'] }
    ],
    ukoEyebrow: 'El compañero', ukoTitle: <>Uko sigue<br /><em>tus cuentas.</em></>,
    ukoLead: 'Reacciona a lo que pasa en la app y adopta los colores de tu tema. Toca una situación:', moodsLabel: 'Situaciones',
    moods: [
      { label: 'Lista vacía', text: 'Aún no hay suscripciones.' },
      { label: 'Cargo próximo', text: 'Llega un cargo en los próximos días.' },
      { label: 'Todo bien', text: 'Añadida con éxito, presupuesto respetado.' },
      { label: 'Atención', text: 'Presupuesto superado o formulario incompleto.' },
      { label: 'Nada que contar', text: 'Todo está tranquilo.' }
    ],
    privacyEyebrow: 'Privacidad', privacyTitle: <>Tus datos.<br /><em>Tus decisiones.</em></>,
    privacy: ['Sin cuenta: tus datos se quedan en tu navegador.', 'No hace falta conectar tu banco.', 'Exportación CSV, o un archivo cifrado con tu contraseña.', 'Copia opcional en Google Drive.', 'Sin anuncios.'],
    privacyNote: 'SubFlow no cifra el almacenamiento del navegador, y la copia de Google Drive no está cifrada de extremo a extremo.',
    privacyLink: 'Política de privacidad',
    closingTitle: <>Haz balance.<br /><em>Despeja la mente.</em></>,
    closingText: 'El seguimiento, la simulación y la exportación son gratis. Sin tarjeta.',
    closingCta: 'Añadir mi primer cargo', feedback: '¿Una idea para SubFlow? Escríbenos.'
  }
};
const LANGS: [Locale, string][] = [['fr', 'FR'], ['en', 'EN'], ['es', 'ES']];
const FACT_VALUES: (number | string)[] = [357, 0, 0, 3, 'FR · EN · ES'];

export default function LandingPage() {
  const { locale, setLocale } = useTranslation();
  const C = COPY[locale] ?? COPY.fr;
  const root = useRef<HTMLDivElement>(null);
  const [step, setStep] = useState(0);
  const [mood, setMood] = useState<UkoState>('thinking');
  const [scrolled, setScrolled] = useState(false);
  const clip = (name: string) => `${locale}/${name}`;

  // Scroll reveals and the 357 counter. Content stays visible without JavaScript.
  useEffect(() => {
    const el = root.current;
    if (!el) return;
    el.classList.add('lp-js');
    const still = matchMedia('(prefers-reduced-motion: reduce)').matches;
    const io = new IntersectionObserver((entries) => entries.forEach((entry) => {
      if (!entry.isIntersecting) return;
      const target = entry.target as HTMLElement;
      target.classList.add('is-in');
      io.unobserve(target);
      const end = Number(target.dataset.count);
      if (!end || still) return;
      const start = performance.now();
      const tick = (now: number) => {
        const k = Math.min(1, (now - start) / 1100);
        target.textContent = String(Math.round(end * (1 - Math.pow(1 - k, 3))));
        if (k < 1) requestAnimationFrame(tick);
      };
      requestAnimationFrame(tick);
    }), { threshold: 0.2 });
    el.querySelectorAll('[data-reveal], [data-count]').forEach((n) => io.observe(n));
    const onScroll = () => setScrolled(window.scrollY > 8);
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => { io.disconnect(); window.removeEventListener('scroll', onScroll); };
  }, []);

  // The step crossing the middle of the screen drives the sticky phone (desktop).
  useEffect(() => {
    const steps = root.current?.querySelectorAll<HTMLElement>('[data-step]');
    if (!steps) return;
    const io = new IntersectionObserver((entries) => entries.forEach((entry) => {
      if (entry.isIntersecting) setStep(Number((entry.target as HTMLElement).dataset.step));
    }), { rootMargin: '-50% 0px -50% 0px' });
    steps.forEach((n) => io.observe(n));
    return () => io.disconnect();
  }, []);

  const moodIndex = Math.max(0, MOOD_STATES.indexOf(mood));
  const current = C.moods[moodIndex]!;

  return <div className="landing" ref={root}>
    <header className={`lp-nav${scrolled ? ' is-scrolled' : ''}`}>
      <div className="lp-nav-inner">
        <Link className="landing-brand" href="/" aria-label={C.home}><span className="brand-mark">∿</span>SubFlow<span className="brand-dot">.</span></Link>
        <nav aria-label="SubFlow">
          <a href="#features">{C.nav[0]}</a><a href="#uko">{C.nav[1]}</a><a href="#privacy">{C.nav[2]}</a>
          <div className="lp-lang" role="group" aria-label="Langue · Language · Idioma">
            {LANGS.map(([code, short]) => <button key={code} type="button" lang={code} aria-pressed={locale === code} onClick={() => setLocale(code)}>{short}</button>)}
          </div>
          <Link className="lp-nav-open" href="/app">{C.open} <ArrowUpRight size={15} /></Link>
        </nav>
      </div>
    </header>

    <section className="lp-hero">
      <div className="lp-hero-copy" data-reveal>
        <p className="lp-eyebrow"><span />{C.eyebrow}</p>
        <h1>{C.h1}</h1>
        <p className="lp-lead">{C.lead}</p>
        <div className="lp-actions">
          <Link className="lp-primary" href="/app">{C.start} <ArrowRight size={18} /></Link>
          <Link className="lp-secondary" href="/demo">{C.demo} <ArrowUpRight size={16} /></Link>
        </div>
      </div>
      <div className="lp-hero-visual" data-reveal>
        <div className="lp-arch" aria-hidden="true" />
        <PhoneClip key={clip('themes')} name={clip('themes')} label={C.heroLabel} className="lp-hero-phone" />
        <UkoMascot state="welcome" palette="light" className="lp-hero-uko" label={C.heroUko} />
        <p className="lp-caption">{C.caption}</p>
      </div>
    </section>

    <ul className="lp-facts" aria-label={C.factsLabel}>
      {C.facts.map((label, i) => { const v = FACT_VALUES[i]!; return <li key={i} data-reveal>
        <strong data-count={typeof v === 'number' && v ? v : undefined}>{v}</strong><span>{label}</span>
      </li>; })}
    </ul>

    <section id="features" className="lp-tour">
      <header className="lp-section-head" data-reveal>
        <p className="lp-eyebrow"><span />{C.tourEyebrow}</p>
        <h2>{C.tourTitle}</h2>
      </header>
      <div className="lp-tour-grid">
        <ol className="lp-steps">
          {C.steps.map((s, i) => <li key={CLIPS[i]} data-step={i} className={step === i ? 'is-active' : ''}>
            <PhoneClip key={clip(CLIPS[i]!)} name={clip(CLIPS[i]!)} label={`SubFlow : ${s.tag.toLowerCase()}`} className="lp-step-phone" />
            <div className="lp-step-copy" data-reveal>
              <span className="lp-step-tag">{String(i + 1).padStart(2, '0')} · {s.tag}</span>
              <h3>{s.title}</h3>
              <p>{s.text}</p>
              <ul className="lp-points">{s.points.map((p) => <li key={p}><Check size={15} />{p}</li>)}</ul>
            </div>
          </li>)}
        </ol>
        <div className="lp-stage" aria-hidden="true">
          <div className="lp-stage-inner">
            <div className="lp-stage-screens">
              {CLIPS.map((c, i) => <PhoneClip key={clip(c)} name={clip(c)} label="" active={step === i} className={`lp-stage-phone${step === i ? ' is-on' : ''}`} />)}
            </div>
            <div className="lp-stage-dots">{CLIPS.map((c, i) => <span key={c} className={step === i ? 'is-on' : ''} />)}</div>
          </div>
        </div>
      </div>
    </section>

    <section id="uko" className="lp-uko">
      <div className="lp-uko-stage" data-reveal>
        <UkoMascot state={mood} palette="light" oneShot="loop" className="lp-uko-mascot" label={`Uko : ${current.label}`} />
        <p className="lp-uko-says" aria-live="polite">{current.text}</p>
      </div>
      <div className="lp-uko-copy" data-reveal>
        <p className="lp-eyebrow"><span />{C.ukoEyebrow}</p>
        <h2>{C.ukoTitle}</h2>
        <p className="lp-lead">{C.ukoLead}</p>
        <div className="lp-moods" role="group" aria-label={C.moodsLabel}>
          {MOOD_STATES.map((s, i) => <button key={s} type="button" aria-pressed={mood === s} onClick={() => setMood(s)}>{C.moods[i]!.label}</button>)}
        </div>
      </div>
    </section>

    <section id="privacy" className="lp-privacy">
      <header className="lp-section-head" data-reveal>
        <p className="lp-eyebrow"><span />{C.privacyEyebrow}</p>
        <h2>{C.privacyTitle}</h2>
      </header>
      <div data-reveal>
        <ul className="lp-points lp-points-lg">{C.privacy.map((p) => <li key={p}><Check size={17} />{p}</li>)}</ul>
        <p className="lp-note">{C.privacyNote}</p>
        <Link className="lp-secondary" href="/privacy">{C.privacyLink} <ArrowUpRight size={16} /></Link>
      </div>
    </section>

    <section className="lp-closing" data-reveal>
      <h2>{C.closingTitle}</h2>
      <p>{C.closingText}</p>
      <Link className="lp-primary lp-primary-light" href="/app">{C.closingCta} <ArrowRight size={18} /></Link>
      <a className="lp-feedback" href="mailto:contact.aadatech@gmail.com?subject=SubFlow">{C.feedback}</a>
    </section>
  </div>;
}
