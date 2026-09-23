'use client';
import React, { useState } from 'react';
import { Download, Upload, Lock, X, Cloud } from 'lucide-react';
import { exportSubscriptionsToCSV, parseSubscriptionsFromCSV, encryptBackupData, decryptBackupData } from '@subflow/core';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useEscapeKey } from '../hooks/useEscapeKey';
import { GoogleAccountModal } from './GoogleAccountModal';

export function BackupManagerModal({ isOpen, onClose }: { isOpen: boolean; onClose: () => void }) {
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
      if (password.length < 12) throw new Error('Choisissez un mot de passe d’au moins 12 caractères.');
      download(await encryptBackupData({ version: 1, subscriptions, profile }, password), 'subflow', 'application/json');
      setNotice('Sauvegarde chiffrée téléchargée. Conservez votre mot de passe séparément.');
    } catch (error) { setNotice((error as Error).message); } finally { setBusy(false); }
  };
  const restorePrevious = () => {
    try {
      const raw = localStorage.getItem('subflow-recovery-v1');
      if (!raw) { setNotice('Aucune restauration précédente à annuler.'); return; }
      useSubscriptionStore.getState().restoreFromCloud(JSON.parse(raw));
      setNotice('La copie locale précédente a été restaurée.');
    } catch { setNotice('Impossible de récupérer la copie précédente.'); }
  };
  const importFile = async () => {
    setBusy(true); setNotice('');
    try {
      if (!file) throw new Error('Choisissez un fichier.');
      if (file.size > 5 * 1024 * 1024) throw new Error('Le fichier dépasse la limite de 5 Mo.');
      const text = await file.text();
      const payload = file.name.toLowerCase().endsWith('.csv') ? { subscriptions: parseSubscriptionsFromCSV(text) } : await decryptBackupData(text, password) as { subscriptions?: unknown };
      const count = importSubscriptions(payload.subscriptions);
      setNotice(`${count} prélèvement(s) ajouté(s). Les doublons ont été ignorés et les réglages actuels conservés.`);
      setFile(null);
    } catch { setNotice('Import impossible : vérifiez le format, les données et le mot de passe. Aucune donnée n’a été ajoutée.'); } finally { setBusy(false); }
  };
  return <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-sm flex items-center justify-center p-4" onClick={onClose}>
    <section role="dialog" aria-modal="true" aria-labelledby="backup-title" className="bg-japandi-surface border rounded-3xl p-6 max-w-lg w-full max-h-[90dvh] overflow-auto space-y-5 shadow-xl" onClick={e => e.stopPropagation()}>
      <div className="flex items-center justify-between"><h2 id="backup-title" className="text-xl font-bold">Vos données vous appartiennent</h2><button autoFocus onClick={onClose} aria-label="Fermer" className="p-3"><X size={20}/></button></div>
      <p className="text-sm text-japandi-muted">Exportez une copie avant de changer d’appareil ou d’effacer votre navigateur.</p>
      <button className="backup-action" onClick={() => download(exportSubscriptionsToCSV(subscriptions), 'csv', 'text/csv;charset=utf-8')}><Download size={18}/>Exporter en CSV · non chiffré</button>
      <label className="block text-sm font-semibold">Mot de passe de la sauvegarde chiffrée<input autoComplete="new-password" type="password" value={password} onChange={e => setPassword(e.target.value)} placeholder="12 caractères minimum" className="mt-2 w-full border rounded-xl p-3 bg-japandi-elevated"/></label>
      <button className="backup-action" disabled={busy} onClick={exportEncrypted}><Lock size={18}/>Télécharger une sauvegarde chiffrée</button>
      <p className="text-xs text-japandi-muted">Sans ce mot de passe, le fichier chiffré ne peut pas être récupéré.</p>
      <div className="border-t pt-4 space-y-3"><label className="block text-sm font-semibold">Importer un CSV ou une sauvegarde .subflow<input type="file" accept=".csv,.subflow" onChange={e => setFile(e.target.files?.[0] || null)} className="block w-full mt-2 text-sm"/></label>
      <p className="text-xs text-japandi-muted">Ajoute les prélèvements manquants sans remplacer vos données. Limite : 5 Mo, 10 000 lignes.</p>
      <button className="backup-action" disabled={busy || !file} onClick={importFile}><Upload size={18}/>{busy ? 'Traitement…' : 'Importer le fichier sélectionné'}</button></div>
      {notice && <p role="status" className="rounded-xl p-3 bg-japandi-elevated text-sm">{notice}</p>}
      <button className="backup-action" onClick={restorePrevious}>Annuler la dernière restauration Drive</button>
      <button className="backup-action" onClick={() => setGoogleOpen(true)}><Cloud size={18}/>Gérer la sauvegarde Google Drive</button>
    </section>
    <GoogleAccountModal isOpen={googleOpen} onClose={() => setGoogleOpen(false)}/>
  </div>;
}
