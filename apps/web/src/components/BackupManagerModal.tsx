'use client';
import React, { useState } from 'react';
import { Download, Upload, Lock, X, Cloud } from 'lucide-react';
import { exportSubscriptionsToCSV, parseSubscriptionsFromCSV, encryptBackupData, decryptBackupData, pick } from '@subflow/core';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useEscapeKey } from '../hooks/useEscapeKey';
import { GoogleAccountModal } from './GoogleAccountModal';
import { useTranslation } from '../hooks/useTranslation';

export function BackupManagerModal({ isOpen, onClose }: { isOpen: boolean; onClose: () => void }) {
  const { locale } = useTranslation();
  const { subscriptions, profile, importSubscriptions } = useSubscriptionStore();
  const [password, setPassword] = useState('');
  const [file, setFile] = useState<File | null>(null);
  const [notice, setNotice] = useState('');
  const [busy, setBusy] = useState(false);
  const [googleOpen, setGoogleOpen] = useState(false);
  useEscapeKey(isOpen && !googleOpen, onClose);
  if (!isOpen) return null;
  const download = (text: string, extension: string, type: string) => {
    const url = URL.createObjectURL(new Blob([text], { type }));
    const link = document.createElement('a');
    link.href = url; link.download = `subflow-${new Date().toISOString().slice(0, 10)}.${extension}`; link.click();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
  };
  const exportEncrypted = async () => {
    setBusy(true); setNotice('');
    try {
      if (password.length < 12) throw new Error(pick(locale, { fr: 'Choisissez un mot de passe d’au moins 12 caractères.', en: 'Choose a password of at least 12 characters.', es: 'Elige una contraseña de al menos 12 caracteres.' }));
      download(await encryptBackupData({ version: 1, subscriptions, profile }, password), 'subflow', 'application/json');
      setNotice(pick(locale, { fr: 'Sauvegarde chiffrée téléchargée. Conservez votre mot de passe séparément.', en: 'Encrypted backup downloaded. Keep your password somewhere else.', es: 'Copia cifrada descargada. Guarda tu contraseña en otro sitio.' }));
    } catch (error) { setNotice((error as Error).message); } finally { setBusy(false); }
  };
  const restorePrevious = () => {
    try {
      const raw = localStorage.getItem('subflow-recovery-v1');
      if (!raw) { setNotice(pick(locale, { fr: 'Aucune restauration précédente à annuler.', en: 'No previous restore to undo.', es: 'No hay ninguna restauración anterior que deshacer.' })); return; }
      useSubscriptionStore.getState().restoreFromCloud(JSON.parse(raw));
      setNotice(pick(locale, { fr: 'La copie locale précédente a été restaurée.', en: 'The previous local copy was restored.', es: 'Se ha restaurado la copia local anterior.' }));
    } catch { setNotice(pick(locale, { fr: 'Impossible de récupérer la copie précédente.', en: 'Could not recover the previous copy.', es: 'No se pudo recuperar la copia anterior.' })); }
  };
  const importFile = async () => {
    setBusy(true); setNotice('');
    try {
      if (!file) throw new Error(pick(locale, { fr: 'Choisissez un fichier.', en: 'Choose a file.', es: 'Elige un archivo.' }));
      if (file.size > 5 * 1024 * 1024) throw new Error(pick(locale, { fr: 'Le fichier dépasse la limite de 5 Mo.', en: 'The file is over the 5 MB limit.', es: 'El archivo supera el límite de 5 MB.' }));
      const text = await file.text();
      const payload = file.name.toLowerCase().endsWith('.csv') ? { subscriptions: parseSubscriptionsFromCSV(text) } : await decryptBackupData(text, password) as { subscriptions?: unknown };
      const count = importSubscriptions(payload.subscriptions);
      setNotice(`${count} ` + pick(locale, { fr: 'prélèvement(s) ajouté(s). Les doublons ont été ignorés et les réglages actuels conservés.', en: 'payment(s) added. Duplicates were skipped and current settings kept.', es: 'cargo(s) añadido(s). Se han ignorado los duplicados y se conservan los ajustes actuales.' }));
      setFile(null);
    } catch { setNotice(pick(locale, { fr: 'Import impossible : vérifiez le format, les données et le mot de passe. Aucune donnée n’a été ajoutée.', en: 'Import failed: check the format, the data and the password. Nothing was added.', es: 'No se pudo importar: revisa el formato, los datos y la contraseña. No se ha añadido nada.' })); } finally { setBusy(false); }
  };
  return <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-sm flex items-center justify-center p-4" onClick={onClose}>
    <section role="dialog" aria-modal="true" aria-labelledby="backup-title" className="bg-japandi-surface border rounded-3xl p-6 max-w-lg w-full max-h-[90dvh] overflow-auto space-y-5 shadow-xl" onClick={e => e.stopPropagation()}>
      <div className="flex items-center justify-between"><h2 id="backup-title" className="text-xl font-bold">{pick(locale, { fr: 'Vos données vous appartiennent', en: 'Your data belongs to you', es: 'Tus datos son tuyos' })}</h2><button autoFocus onClick={onClose} aria-label={pick(locale, { fr: 'Fermer', en: 'Close', es: 'Cerrar' })} className="p-3"><X size={20}/></button></div>
      <p className="text-sm text-japandi-muted">{pick(locale, { fr: 'Exportez une copie avant de changer d’appareil ou d’effacer votre navigateur.', en: 'Export a copy before switching devices or clearing your browser.', es: 'Exporta una copia antes de cambiar de dispositivo o de borrar tu navegador.' })}</p>
      <button className="backup-action" onClick={() => download(exportSubscriptionsToCSV(subscriptions), 'csv', 'text/csv;charset=utf-8')}><Download size={18}/>{pick(locale, { fr: 'Exporter en CSV · non chiffré', en: 'Export as CSV · not encrypted', es: 'Exportar a CSV · sin cifrar' })}</button>
      <label className="block text-sm font-semibold">{pick(locale, { fr: 'Mot de passe de la sauvegarde chiffrée', en: 'Encrypted backup password', es: 'Contraseña de la copia cifrada' })}<input autoComplete="new-password" type="password" value={password} onChange={e => setPassword(e.target.value)} placeholder={pick(locale, { fr: '12 caractères minimum', en: '12 characters minimum', es: 'Mínimo 12 caracteres' })} className="mt-2 w-full border rounded-xl p-3 bg-japandi-elevated"/></label>
      <button className="backup-action" disabled={busy} onClick={exportEncrypted}><Lock size={18}/>{pick(locale, { fr: 'Télécharger une sauvegarde chiffrée', en: 'Download an encrypted backup', es: 'Descargar una copia cifrada' })}</button>
      <p className="text-xs text-japandi-muted">{pick(locale, { fr: 'Sans ce mot de passe, le fichier chiffré ne peut pas être récupéré.', en: 'Without this password, the encrypted file cannot be recovered.', es: 'Sin esta contraseña, el archivo cifrado no se puede recuperar.' })}</p>
      <div className="border-t pt-4 space-y-3"><label className="block text-sm font-semibold">{pick(locale, { fr: 'Importer un CSV ou une sauvegarde .subflow', en: 'Import a CSV or a .subflow backup', es: 'Importar un CSV o una copia .subflow' })}<input type="file" accept=".csv,.subflow" onChange={e => setFile(e.target.files?.[0] || null)} className="block w-full mt-2 text-sm"/></label>
      <p className="text-xs text-japandi-muted">{pick(locale, { fr: 'Ajoute les prélèvements manquants sans remplacer vos données. Limite : 5 Mo, 10 000 lignes.', en: 'Adds the missing payments without replacing your data. Limit: 5 MB, 10,000 rows.', es: 'Añade los cargos que faltan sin reemplazar tus datos. Límite: 5 MB, 10 000 filas.' })}</p>
      <button className="backup-action" disabled={busy || !file} onClick={importFile}><Upload size={18}/>{busy ? pick(locale, { fr: 'Traitement…', en: 'Working…', es: 'Procesando…' }) : pick(locale, { fr: 'Importer le fichier sélectionné', en: 'Import the selected file', es: 'Importar el archivo seleccionado' })}</button></div>
      {notice && <p role="status" className="rounded-xl p-3 bg-japandi-elevated text-sm">{notice}</p>}
      <button className="backup-action" onClick={restorePrevious}>{pick(locale, { fr: 'Annuler la dernière restauration Drive', en: 'Undo the last Drive restore', es: 'Deshacer la última restauración de Drive' })}</button>
      <button className="backup-action" onClick={() => setGoogleOpen(true)}><Cloud size={18}/>{pick(locale, { fr: 'Gérer la sauvegarde Google Drive', en: 'Manage the Google Drive backup', es: 'Gestionar la copia de Google Drive' })}</button>
    </section>
    <GoogleAccountModal isOpen={googleOpen} onClose={() => setGoogleOpen(false)}/>
  </div>;
}
