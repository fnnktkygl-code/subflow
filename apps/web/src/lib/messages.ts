import { Locale } from '@subflow/core';

// Messages raised outside React (storage, Google Drive) are written in French;
// screens translate the known ones for English and Spanish.
const MESSAGES: Record<string, { en: string; es: string }> = {
  'Sauvegarde locale impossible (stockage plein ou bloqué). Vos modifications restent dans cette page : exportez-les avant de la fermer.': {
    en: 'Local save failed (storage full or blocked). Your changes stay on this page: export them before closing it.',
    es: 'No se pudo guardar localmente (almacenamiento lleno o bloqueado). Tus cambios siguen en esta página: expórtalos antes de cerrarla.'
  },
  'Un ancien stockage contenant une connexion Google n’a pas pu être assaini. SubFlow a refusé de le charger : effacez les données du site avant de continuer.': {
    en: 'An old storage entry holding a Google connection could not be cleaned. SubFlow refused to load it: clear the site data before continuing.',
    es: 'No se pudo limpiar un almacenamiento antiguo con una conexión de Google. SubFlow no lo ha cargado: borra los datos del sitio antes de continuar.'
  },
  'Le stockage local est inaccessible ou endommagé. Les nouvelles modifications restent temporaires : exportez une sauvegarde avant de fermer cette page.': {
    en: 'Local storage is unavailable or damaged. New changes are temporary: export a backup before closing this page.',
    es: 'El almacenamiento local no está disponible o está dañado. Los cambios nuevos son temporales: exporta una copia antes de cerrar esta página.'
  },
  'Impossible d’effacer le stockage local. Vérifiez les autorisations du navigateur.': {
    en: 'Could not clear local storage. Check the browser permissions.',
    es: 'No se pudo borrar el almacenamiento local. Revisa los permisos del navegador.'
  },
  'Connexion Google indisponible dans la démonstration': { en: 'Google sign-in is not available in the demo', es: 'El inicio de sesión con Google no está disponible en la demo' },
  'Échec de la connexion à Google Drive': { en: 'Could not connect to Google Drive', es: 'No se pudo conectar con Google Drive' },
  'Une opération Drive est déjà en cours.': { en: 'A Drive operation is already running.', es: 'Ya hay una operación de Drive en curso.' },
  'Session Google expirée. Reconnectez-vous.': { en: 'Google session expired. Sign in again.', es: 'La sesión de Google ha caducado. Vuelve a iniciar sesión.' },
  'Une sauvegarde distante existe ou a changé. Restaurez-la avant de sauvegarder pour éviter de l’écraser.': {
    en: 'A remote backup exists or has changed. Restore it before saving so it is not overwritten.',
    es: 'Existe una copia remota o ha cambiado. Restáurala antes de guardar para no sobrescribirla.'
  },
  'Non connecté à Google Drive': { en: 'Not connected to Google Drive', es: 'No conectado a Google Drive' }
};

export function translateMessage(message: string | null | undefined, locale: Locale): string {
  if (!message) return '';
  if (locale === 'fr') return message;
  const known = MESSAGES[message];
  return known ? known[locale] : message;
}
