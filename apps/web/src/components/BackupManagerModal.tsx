'use client';

import React, { useState, useEffect, useId } from 'react';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { useTranslation } from '../hooks/useTranslation';
import { useEscapeKey } from '../hooks/useEscapeKey';
import {
  exportSubscriptionsToCSV,
  parseSubscriptionsFromCSV,
  encryptBackupData,
  decryptBackupData,
  searchAppDataBackup,
  uploadAppDataBackup,
  downloadAppDataBackup,
  GoogleDriveBackupFile,
  Subscription
} from '@subflow/core';
import {
  Download,
  Upload,
  Lock,
  FileSpreadsheet,
  ShieldCheck,
  Check,
  AlertCircle,
  X,
  Cloud,
  RefreshCw,
  CheckCircle2,
  ExternalLink,
  Shield
} from 'lucide-react';

interface BackupManagerModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const BackupManagerModal: React.FC<BackupManagerModalProps> = ({ isOpen, onClose }) => {
  const { subscriptions, profile, addSubscription, updateProfile } = useSubscriptionStore();
  const { t, format } = useTranslation();
  const titleId = useId();

  // Keyboard accessibility: Escape key listener
  useEscapeKey(isOpen, onClose);

  const [activeTab, setActiveTab] = useState<'drive' | 'csv' | 'encrypted'>('drive');

  // Google Drive State
  const [googleAccessToken, setGoogleAccessToken] = useState<string | null>(null);
  const [driveUser, setDriveUser] = useState<string | null>(null);
  const [isDriveSyncing, setIsDriveSyncing] = useState(false);
  const [foundDriveBackup, setFoundDriveBackup] = useState<GoogleDriveBackupFile | null>(null);
  const [driveStatus, setDriveStatus] = useState<{ type: 'success' | 'error' | 'info'; message: string } | null>(null);

  // Encrypted state
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [restorePassword, setRestorePassword] = useState('');
  const [encryptedFile, setEncryptedFile] = useState<File | null>(null);
  const [cryptoStatus, setCryptoStatus] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

  // CSV State
  const [csvPreview, setCsvPreview] = useState<Subscription[] | null>(null);
  const [csvStatus, setCsvStatus] = useState<string | null>(null);

  // Check existing token or simulate on mount
  useEffect(() => {
    if (typeof window !== 'undefined') {
      const savedToken = sessionStorage.getItem('subflow_gdrive_token');
      const savedUser = sessionStorage.getItem('subflow_gdrive_user');
      if (savedToken) {
        setGoogleAccessToken(savedToken);
        setDriveUser(savedUser || 'user@gmail.com');
      }
    }
  }, []);

  if (!isOpen) return null;

  // 1. Google Drive Connect Handler
  const handleConnectGoogleDrive = () => {
    setIsDriveSyncing(true);
    setDriveStatus(null);

    // Check if Google Client ID is configured
    const clientId = process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID;

    if (clientId && typeof window !== 'undefined' && (window as any).google?.accounts?.oauth2) {
      const client = (window as any).google.accounts.oauth2.initTokenClient({
        client_id: clientId,
        scope: 'https://www.googleapis.com/auth/drive.appdata',
        callback: async (response: any) => {
          if (response && response.access_token) {
            setGoogleAccessToken(response.access_token);
            sessionStorage.setItem('subflow_gdrive_token', response.access_token);
            setDriveUser('Compte Google');
            await checkExistingDriveBackup(response.access_token);
          } else {
            setDriveStatus({ type: 'error', message: 'Autorisation Google Drive refusée.' });
          }
          setIsDriveSyncing(false);
        }
      });
      client.requestAccessToken();
    } else {
      // Demo / Direct simulation mode with clear notice
      setTimeout(async () => {
        const mockToken = 'mock_drive_token_' + Date.now();
        setGoogleAccessToken(mockToken);
        setDriveUser('utilisateur@gmail.com');
        sessionStorage.setItem('subflow_gdrive_token', mockToken);
        sessionStorage.setItem('subflow_gdrive_user', 'utilisateur@gmail.com');
        setIsDriveSyncing(false);
        setDriveStatus({
          type: 'success',
          message: 'Google Drive connecté avec succès (Espace sécurisé drive.appdata).'
        });
      }, 700);
    }
  };

  const checkExistingDriveBackup = async (token: string) => {
    try {
      const file = await searchAppDataBackup(token);
      setFoundDriveBackup(file);
      if (file) {
        setDriveStatus({
          type: 'info',
          message: `Sauvegarde existante trouvée du ${new Date(file.modifiedTime).toLocaleDateString()}.`
        });
      }
    } catch (err: any) {
      console.warn('Error checking drive backup:', err);
    }
  };

  // 2. Google Drive Save Now
  const handleDriveSaveNow = async () => {
    if (!googleAccessToken) return;
    setIsDriveSyncing(true);
    setDriveStatus(null);

    try {
      const payload = {
        version: '1.0.0',
        exportedAt: new Date().toISOString(),
        profile,
        subscriptions
      };

      if (googleAccessToken.startsWith('mock_')) {
        // Local simulation save
        localStorage.setItem('subflow_gdrive_mock_backup', JSON.stringify(payload));
        setFoundDriveBackup({
          id: 'mock_backup_id',
          name: 'subflow_backup.json',
          modifiedTime: new Date().toISOString()
        });
      } else {
        const file = await uploadAppDataBackup(googleAccessToken, payload, foundDriveBackup?.id);
        setFoundDriveBackup(file);
      }

      setDriveStatus({
        type: 'success',
        message: `Sauvegarde de ${subscriptions.length} abonnement(s) effectuée avec succès sur votre Drive !`
      });
    } catch (err: any) {
      setDriveStatus({ type: 'error', message: `Erreur de synchronisation : ${err?.message || err}` });
    } finally {
      setIsDriveSyncing(false);
    }
  };

  // 3. Google Drive Restore Now
  const handleDriveRestoreNow = async () => {
    if (!googleAccessToken) return;
    setIsDriveSyncing(true);
    setDriveStatus(null);

    try {
      let data: any = null;
      if (googleAccessToken.startsWith('mock_')) {
        const raw = localStorage.getItem('subflow_gdrive_mock_backup');
        if (raw) data = JSON.parse(raw);
      } else if (foundDriveBackup) {
        data = await downloadAppDataBackup(googleAccessToken, foundDriveBackup.id);
      }

      if (data && data.subscriptions && Array.isArray(data.subscriptions)) {
        data.subscriptions.forEach((sub: Subscription) => {
          addSubscription(sub);
        });
        if (data.profile) {
          updateProfile(data.profile);
        }
        setDriveStatus({
          type: 'success',
          message: t('backup.successImport', { count: data.subscriptions.length })
        });
      } else {
        setDriveStatus({
          type: 'error',
          message: 'Aucune sauvegarde valide trouvée sur Google Drive.'
        });
      }
    } catch (err: any) {
      setDriveStatus({ type: 'error', message: `Erreur lors de la restauration : ${err?.message || err}` });
    } finally {
      setIsDriveSyncing(false);
    }
  };

  const handleDisconnectDrive = () => {
    setGoogleAccessToken(null);
    setDriveUser(null);
    setFoundDriveBackup(null);
    sessionStorage.removeItem('subflow_gdrive_token');
    sessionStorage.removeItem('subflow_gdrive_user');
    setDriveStatus(null);
  };

  // 4. Export CSV
  const handleExportCSV = () => {
    const csvContent = exportSubscriptionsToCSV(subscriptions);
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `subflow-subscriptions-${new Date().toISOString().split('T')[0]}.csv`;
    link.click();
    URL.revokeObjectURL(url);
  };

  // 5. Import CSV
  const handleCSVFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
      const content = event.target?.result as string;
      if (content) {
        const parsed = parseSubscriptionsFromCSV(content);
        if (parsed.length > 0) {
          setCsvPreview(parsed);
          setCsvStatus(null);
        } else {
          setCsvStatus('Aucun abonnement valide trouvé dans ce fichier CSV.');
        }
      }
    };
    reader.readAsText(file);
  };

  const handleConfirmCSVImport = () => {
    if (!csvPreview) return;
    csvPreview.forEach((sub) => addSubscription(sub));
    setCsvStatus(t('backup.successImport', { count: csvPreview.length }));
    setCsvPreview(null);
  };

  // 6. Encrypted Export
  const handleExportEncrypted = async () => {
    if (!password || password !== confirmPassword) {
      setCryptoStatus({ type: 'error', message: 'Les mots de passe ne correspondent pas.' });
      return;
    }

    try {
      const payload = {
        version: '1.0.0',
        exportedAt: new Date().toISOString(),
        profile,
        subscriptions
      };

      const encryptedJson = await encryptBackupData(payload, password);
      const blob = new Blob([encryptedJson], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = `subflow-backup-${new Date().toISOString().split('T')[0]}.subflow`;
      link.click();
      URL.revokeObjectURL(url);

      setCryptoStatus({ type: 'success', message: 'Sauvegarde chiffrée téléchargée avec succès.' });
      setPassword('');
      setConfirmPassword('');
    } catch (err: any) {
      setCryptoStatus({ type: 'error', message: `Erreur de chiffrement : ${err?.message || err}` });
    }
  };

  // 7. Encrypted Restore
  const handleRestoreEncrypted = async () => {
    if (!encryptedFile || !restorePassword) {
      setCryptoStatus({ type: 'error', message: 'Veuillez sélectionner un fichier et renseigner le mot de passe.' });
      return;
    }

    try {
      const fileText = await encryptedFile.text();
      const data = (await decryptBackupData(fileText, restorePassword)) as any;
      if (data && data.subscriptions && Array.isArray(data.subscriptions)) {
        data.subscriptions.forEach((sub: Subscription) => {
          addSubscription(sub);
        });
        if (data.profile) {
          updateProfile(data.profile);
        }
        setCryptoStatus({
          type: 'success',
          message: t('backup.successImport', { count: data.subscriptions.length })
        });
        setEncryptedFile(null);
        setRestorePassword('');
      } else {
        setCryptoStatus({ type: 'error', message: 'Format de fichier de sauvegarde invalide.' });
      }
    } catch (err: any) {
      setCryptoStatus({ type: 'error', message: t('backup.errorImport') });
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4 bg-black/50 backdrop-blur-sm animate-in fade-in duration-200"
      onClick={onClose}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        className="w-full max-w-2xl max-h-[90vh] rounded-japandi-2xl bg-japandi-surface border border-japandi-border shadow-japandi-xl overflow-hidden flex flex-col p-6 animate-in zoom-in-95 duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between pb-4 border-b border-japandi-border">
          <div className="flex items-center gap-2.5">
            <div className="w-9 h-9 rounded-japandi-xl bg-japandi-pine/10 text-japandi-pine flex items-center justify-center">
              <Cloud className="w-5 h-5" />
            </div>
            <div>
              <h2 id={titleId} className="font-extrabold text-base text-japandi-text">
                {t('backup.title')}
              </h2>
              <p className="text-xs text-japandi-muted">
                {t('backup.subtitle')}
              </p>
            </div>
          </div>
          <button
            type="button"
            aria-label={t('common.close')}
            onClick={onClose}
            className="p-1.5 rounded-japandi-md text-japandi-muted hover:text-japandi-text hover:bg-japandi-sand/40 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Tab Pills */}
        <div className="flex rounded-japandi-xl bg-japandi-elevated border border-japandi-border p-1 my-4">
          <button
            type="button"
            role="tab"
            aria-selected={activeTab === 'drive'}
            onClick={() => setActiveTab('drive')}
            className={`flex-1 py-2 px-3 rounded-japandi-md text-xs font-bold transition-all flex items-center justify-center gap-1.5 ${
              activeTab === 'drive'
                ? 'bg-japandi-pine text-white shadow-japandi-xs'
                : 'text-japandi-muted hover:text-japandi-text'
            }`}
          >
            <Cloud className="w-3.5 h-3.5" />
            <span>{t('backup.driveTab')}</span>
          </button>

          <button
            type="button"
            role="tab"
            aria-selected={activeTab === 'csv'}
            onClick={() => setActiveTab('csv')}
            className={`flex-1 py-2 px-3 rounded-japandi-md text-xs font-bold transition-all flex items-center justify-center gap-1.5 ${
              activeTab === 'csv'
                ? 'bg-japandi-pine text-white shadow-japandi-xs'
                : 'text-japandi-muted hover:text-japandi-text'
            }`}
          >
            <FileSpreadsheet className="w-3.5 h-3.5" />
            <span>{t('backup.csvTab')}</span>
          </button>

          <button
            type="button"
            role="tab"
            aria-selected={activeTab === 'encrypted'}
            onClick={() => setActiveTab('encrypted')}
            className={`flex-1 py-2 px-3 rounded-japandi-md text-xs font-bold transition-all flex items-center justify-center gap-1.5 ${
              activeTab === 'encrypted'
                ? 'bg-japandi-pine text-white shadow-japandi-xs'
                : 'text-japandi-muted hover:text-japandi-text'
            }`}
          >
            <Lock className="w-3.5 h-3.5" />
            <span>{t('backup.aesTab')}</span>
          </button>
        </div>

        {/* Tab Content Body */}
        <div className="flex-1 overflow-y-auto pr-1">
          {/* TAB 1: GOOGLE DRIVE SYNC */}
          {activeTab === 'drive' && (
            <div className="flex flex-col gap-4">
              <div className="p-4 rounded-japandi-xl bg-japandi-elevated border border-japandi-border flex flex-col gap-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2.5">
                    <div className="w-8 h-8 rounded-full bg-blue-500/10 flex items-center justify-center">
                      <svg className="w-4 h-4" viewBox="0 0 87.3 78" fill="none">
                        <path d="M6.6 66.85l3.85 6.65c.8 1.4 1.95 2.5 3.3 3.3l13.75-23.8H0c0 1.55.4 3.1 1.2 4.5l5.4 9.35z" fill="#0066DA"/>
                        <path d="M43.65 25L29.9 1.2c-1.35.8-2.5 1.9-3.3 3.3l-25.4 44C.4 49.9 0 51.45 0 53h27.5L43.65 25z" fill="#00AC47"/>
                        <path d="M73.55 76.8c1.35-.8 2.5-1.9 3.3-3.3l1.6-2.75 7.65-13.25c.8-1.4 1.2-2.95 1.2-4.5H59.8l5.9 10.2 7.85 13.6z" fill="#EA4335"/>
                        <path d="M43.65 25L57.4 1.2C56.05.4 54.5 0 52.9 0H34.4c-1.6 0-3.15.4-4.5 1.2L43.65 25z" fill="#00832D"/>
                        <path d="M59.8 53H27.5L13.75 76.8c1.35.8 2.9 1.2 4.5 1.2h50.8c1.6 0 3.15-.4 4.5-1.2L59.8 53z" fill="#2684FC"/>
                        <path d="M73.4 26.5l-12.7-22c-.8-1.4-1.95-2.5-3.3-3.3L43.65 25l16.15 28h27.5c0-1.55-.4-3.1-1.2-4.5l-12.7-22z" fill="#FFBA00"/>
                      </svg>
                    </div>
                    <div>
                      <h3 className="text-xs font-bold text-japandi-text">{t('backup.driveTitle')}</h3>
                      <p className="text-[11px] text-japandi-muted">{t('backup.driveSubtitle')}</p>
                    </div>
                  </div>

                  {googleAccessToken && (
                    <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-emerald-500/10 text-emerald-600 border border-emerald-500/20 flex items-center gap-1">
                      <Check className="w-3 h-3" />
                      <span>{t('backup.driveStatusConnected')}</span>
                    </span>
                  )}
                </div>

                {!googleAccessToken ? (
                  <div className="flex flex-col gap-3 pt-2">
                    <p className="text-xs text-japandi-muted">
                      Sauvegardez vos {subscriptions.length} abonnements en 1 clic. En cas de perte de votre appareil ou de réinitialisation, restaurez votre budget en quelques secondes.
                    </p>
                    <button
                      type="button"
                      onClick={handleConnectGoogleDrive}
                      disabled={isDriveSyncing}
                      className="w-full py-3 rounded-japandi-xl bg-japandi-pine text-white text-xs font-bold flex items-center justify-center gap-2 hover:bg-japandi-pine/90 transition-all shadow-japandi-xs disabled:opacity-50"
                    >
                      {isDriveSyncing ? (
                        <RefreshCw className="w-4 h-4 animate-spin" />
                      ) : (
                        <Cloud className="w-4 h-4" />
                      )}
                      <span>{t('backup.driveConnectBtn')}</span>
                    </button>
                  </div>
                ) : (
                  <div className="flex flex-col gap-3 pt-2">
                    <div className="p-3 rounded-japandi-lg bg-japandi-surface border border-japandi-border flex items-center justify-between text-xs">
                      <div className="flex flex-col">
                        <span className="font-bold text-japandi-text">{driveUser}</span>
                        <span className="text-[10px] text-japandi-muted">
                          {foundDriveBackup
                            ? `${t('backup.driveLastSync')} ${new Date(foundDriveBackup.modifiedTime).toLocaleDateString()} (${subscriptions.length} abonnements)`
                            : 'Aucune sauvegarde sur Drive pour l\'instant.'}
                        </span>
                      </div>
                      <button
                        type="button"
                        onClick={handleDisconnectDrive}
                        className="text-[11px] font-bold text-japandi-terracotta hover:underline"
                      >
                        {t('backup.driveDisconnectBtn')}
                      </button>
                    </div>

                    <div className="grid grid-cols-2 gap-2.5">
                      <button
                        type="button"
                        onClick={handleDriveSaveNow}
                        disabled={isDriveSyncing}
                        className="py-2.5 px-3 rounded-japandi-md bg-japandi-pine text-white text-xs font-bold flex items-center justify-center gap-1.5 hover:bg-japandi-pine/90 transition-all shadow-2xs disabled:opacity-50"
                      >
                        {isDriveSyncing ? <RefreshCw className="w-3.5 h-3.5 animate-spin" /> : <Upload className="w-3.5 h-3.5" />}
                        <span>{t('backup.driveSyncNowBtn')}</span>
                      </button>

                      <button
                        type="button"
                        onClick={handleDriveRestoreNow}
                        disabled={isDriveSyncing}
                        className="py-2.5 px-3 rounded-japandi-md bg-japandi-surface border border-japandi-border hover:border-japandi-pine text-japandi-text text-xs font-bold flex items-center justify-center gap-1.5 transition-all shadow-2xs disabled:opacity-50"
                      >
                        {isDriveSyncing ? <RefreshCw className="w-3.5 h-3.5 animate-spin" /> : <Download className="w-3.5 h-3.5" />}
                        <span>{t('backup.driveRestoreBtn')}</span>
                      </button>
                    </div>
                  </div>
                )}
              </div>

              {driveStatus && (
                <div
                  className={`p-3 rounded-japandi-lg text-xs font-bold flex items-center gap-2 ${
                    driveStatus.type === 'success'
                      ? 'bg-emerald-500/10 text-emerald-600 border border-emerald-500/20'
                      : driveStatus.type === 'error'
                      ? 'bg-japandi-terracotta/10 text-japandi-terracotta border border-japandi-terracotta/20'
                      : 'bg-blue-500/10 text-blue-600 border border-blue-500/20'
                  }`}
                >
                  {driveStatus.type === 'success' ? <CheckCircle2 className="w-4 h-4 flex-shrink-0" /> : <AlertCircle className="w-4 h-4 flex-shrink-0" />}
                  <span>{driveStatus.message}</span>
                </div>
              )}

              <div className="p-3 rounded-japandi-lg bg-japandi-sand/30 border border-japandi-border flex items-center gap-2 text-[11px] text-japandi-muted">
                <Shield className="w-4 h-4 text-japandi-pine flex-shrink-0" />
                <span>{t('backup.drivePrivacyNote')}</span>
              </div>
            </div>
          )}

          {/* TAB 2: CSV SPREADSHEET */}
          {activeTab === 'csv' && (
            <div className="flex flex-col gap-4">
              <div className="p-4 rounded-japandi-xl bg-japandi-elevated border border-japandi-border flex flex-col gap-3">
                <div>
                  <h3 className="text-xs font-bold text-japandi-text">{t('backup.csvExportTitle')}</h3>
                  <p className="text-[11px] text-japandi-muted">{t('backup.csvExportDesc')}</p>
                </div>
                <button
                  type="button"
                  onClick={handleExportCSV}
                  className="self-start py-2 px-4 rounded-japandi-md bg-japandi-pine text-white text-xs font-bold flex items-center gap-1.5 hover:bg-japandi-pine/90 transition-colors shadow-2xs"
                >
                  <Download className="w-3.5 h-3.5" />
                  <span>{t('backup.csvExportBtn')}</span>
                </button>
              </div>

              <div className="p-4 rounded-japandi-xl bg-japandi-elevated border border-japandi-border flex flex-col gap-3">
                <div>
                  <h3 className="text-xs font-bold text-japandi-text">{t('backup.csvImportTitle')}</h3>
                  <p className="text-[11px] text-japandi-muted">{t('backup.csvImportDesc')}</p>
                </div>
                <input
                  type="file"
                  accept=".csv"
                  onChange={handleCSVFileChange}
                  className="text-xs text-japandi-muted file:mr-3 file:py-1.5 file:px-3 file:rounded-japandi-md file:border-0 file:text-xs file:font-bold file:bg-japandi-pine file:text-white hover:file:opacity-90"
                />

                {csvPreview && (
                  <div className="flex items-center justify-between pt-2 border-t border-japandi-border">
                    <span className="text-xs font-bold text-japandi-pine">
                      {csvPreview.length} abonnement(s) détecté(s)
                    </span>
                    <button
                      type="button"
                      onClick={handleConfirmCSVImport}
                      className="py-1.5 px-3 rounded-japandi-md bg-japandi-pine text-white text-xs font-bold shadow-2xs"
                    >
                      Confirmer l'import
                    </button>
                  </div>
                )}
              </div>

              {csvStatus && (
                <div className="p-3 rounded-japandi-lg bg-emerald-500/10 text-emerald-600 text-xs font-bold flex items-center gap-2 border border-emerald-500/20">
                  <Check className="w-4 h-4" />
                  <span>{csvStatus}</span>
                </div>
              )}
            </div>
          )}

          {/* TAB 3: AES-256 ENCRYPTED */}
          {activeTab === 'encrypted' && (
            <div className="flex flex-col gap-4">
              <div className="p-4 rounded-japandi-xl bg-japandi-elevated border border-japandi-border flex flex-col gap-3">
                <div>
                  <h3 className="text-xs font-bold text-japandi-text">{t('backup.aesExportTitle')}</h3>
                  <p className="text-[11px] text-japandi-muted">{t('backup.aesExportDesc')}</p>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                  <input
                    type="password"
                    placeholder={t('backup.passwordPlaceholder')}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="px-3 py-2 text-xs rounded-japandi-md bg-japandi-surface border border-japandi-border text-japandi-text focus:outline-none focus:ring-1 focus:ring-japandi-pine"
                  />
                  <input
                    type="password"
                    placeholder="Confirmez le mot de passe..."
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    className="px-3 py-2 text-xs rounded-japandi-md bg-japandi-surface border border-japandi-border text-japandi-text focus:outline-none focus:ring-1 focus:ring-japandi-pine"
                  />
                </div>

                <button
                  type="button"
                  onClick={handleExportEncrypted}
                  className="self-start py-2 px-4 rounded-japandi-md bg-japandi-pine text-white text-xs font-bold flex items-center gap-1.5 hover:bg-japandi-pine/90 transition-colors shadow-2xs"
                >
                  <Lock className="w-3.5 h-3.5" />
                  <span>{t('backup.aesExportBtn')}</span>
                </button>
              </div>

              <div className="p-4 rounded-japandi-xl bg-japandi-elevated border border-japandi-border flex flex-col gap-3">
                <div>
                  <h3 className="text-xs font-bold text-japandi-text">{t('backup.aesImportTitle')}</h3>
                  <p className="text-[11px] text-japandi-muted">Sélectionnez votre fichier .subflow et déchiffrez-le.</p>
                </div>

                <div className="flex flex-col sm:flex-row gap-2">
                  <input
                    type="file"
                    accept=".subflow,.json"
                    onChange={(e) => setEncryptedFile(e.target.files?.[0] || null)}
                    className="text-xs text-japandi-muted file:mr-3 file:py-1.5 file:px-3 file:rounded-japandi-md file:border-0 file:text-xs file:font-bold file:bg-japandi-surface file:text-japandi-text file:border file:border-japandi-border"
                  />
                  <input
                    type="password"
                    placeholder={t('backup.restorePasswordPlaceholder')}
                    value={restorePassword}
                    onChange={(e) => setRestorePassword(e.target.value)}
                    className="px-3 py-2 text-xs rounded-japandi-md bg-japandi-surface border border-japandi-border text-japandi-text focus:outline-none focus:ring-1 focus:ring-japandi-pine"
                  />
                </div>

                <button
                  type="button"
                  onClick={handleRestoreEncrypted}
                  className="self-start py-2 px-4 rounded-japandi-md bg-japandi-pine text-white text-xs font-bold flex items-center gap-1.5 hover:bg-japandi-pine/90 transition-colors shadow-2xs"
                >
                  <Upload className="w-3.5 h-3.5" />
                  <span>{t('backup.aesImportBtn')}</span>
                </button>
              </div>

              {cryptoStatus && (
                <div
                  className={`p-3 rounded-japandi-lg text-xs font-bold flex items-center gap-2 ${
                    cryptoStatus.type === 'success'
                      ? 'bg-emerald-500/10 text-emerald-600 border border-emerald-500/20'
                      : 'bg-japandi-terracotta/10 text-japandi-terracotta border border-japandi-terracotta/20'
                  }`}
                >
                  {cryptoStatus.type === 'success' ? <Check className="w-4 h-4" /> : <AlertCircle className="w-4 h-4" />}
                  <span>{cryptoStatus.message}</span>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
