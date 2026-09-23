<div align="center">

# 🌿 SubFlow

**Suivi clair des abonnements et prélèvements récurrents**

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Security](https://img.shields.io/badge/Local--First-Privacy-success?style=for-the-badge)

**Anticipez ce qui revient, visualisez les prochaines échéances et simulez vos économies.**

[Fonctionnalités](#-features) • [Application](https://subflowapp.vercel.app) • [Qualification](docs/QUALIFICATION_SUBFLOW.md)

</div>

---

## 🎯 About SubFlow

**SubFlow** est une application locale par défaut consacrée aux abonnements et prélèvements récurrents. Elle permet de suivre les échéances, de comparer le coût mensuel équivalent au montant réellement prélevé et de simuler des économies sans modifier les données réelles.

## ✨ Features

### 🌸 **Serene Japandi UI/UX**
- Calming earth tones and minimalist typography
- Wabi-Sabi progress rings & mindful milestone celebrations
- Smooth micro-animations and zero clutter

### ⚡ **1-Tap Frictionless Entry**
- Single-view subscription creation modal
- Catalogue régional avec montants illustratifs à vérifier avant enregistrement
- Automatic cycle and category detection

### 🔮 **Simulation d’économies**
- Selectively exclude subscriptions to see instant real-time savings
- Visualize impact on monthly buffer and annual commitments

### 🔒 **Local storage & portable backups**
- Web data lives in browser storage, without application-level encryption. Protect your device and export backups.
- CSV exports and password-encrypted backup files; local data deletion is separate from cloud backup deletion.
- Optional TrueLayer integration with state and PKCE; real provider authorization still requires deployment validation.

---

## 🚀 Getting Started

### Web — prérequis

- Node.js et pnpm 9

### Installation

1. **Installer les dépendances**
   ```bash
   pnpm install
   ```

2. **Exécuter les tests**
   ```bash
   pnpm test
   ```

3. **Démarrer le web**
   ```bash
   pnpm --filter @subflow/web dev
   ```

L’implémentation Flutter à la racine est distincte du web. Elle exige Flutter 3.x, `flutter pub get` et `flutter test` avant toute livraison native.

---

## 🌐 Live Web Application

- **Live URL**: [https://subflowapp.vercel.app](https://subflowapp.vercel.app)

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for details.
