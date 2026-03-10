# PalantINT — Documentation Technique Complète (Deep AI Context)

Dernière mise à jour : 2026-03-10 (Architecture Vault, 3D WebGL & Purge du Jargon)

## 👁️ Objectifs & Vision
**PalantINT** est une plateforme de visualisation de données de campus pour **IMT-BS / Télécom SudParis**. Elle unifie des sources de données disparates (Trombi, Emplois du temps, Clubs, Logements) dans une interface unique, performante et esthétique.

Le projet suit un standard de **Luxe Professionnel Brutaliste** :
- **Data-First**: Visualisation haute densité via des grilles de données (DataGrid).
- **Asynchrone**: Pipeline de synchronisation asynchrone ultra-rapide via `httpx` et `asyncio`.
- **Interactivité**: Jumeau numérique 3D (BuildingModel) via Three.js et manipulation directe du DOM pour les plans SVG.

---

## 🏗️ Architecture Technique

### 🐍 Backend : FastAPI & SQLModel
- **Architecture**: REST API Asynchrone.
- **Modèles**: SQLModel (SQLAlchemy + Pydantic v2). Centralisés dans `src/db/models.py`.
- **Migrations**: Alembic pour le versioning du schéma PostgreSQL.
- **Sécurité**: 
  - Authentification JWT avec rôles (Admin/User).
  - Chiffrement symétrique **Fernet (AES-128)** pour le stockage sécurisé des identifiants CAS.

### ⚛️ Frontend : Next.js 15
- **Moteur**: React 19 + App Router.
- **WebGL**: Three.js pour le rendu 3D des bâtiments résidentiels.
- **Style**: Tailwind CSS 4. Glassmorphism sombre sur fond Zinc-950.
- **Optimisation**: Bypasse le cycle de rendu React pour les interactions de carte (DOM Refs + setAttribute) afin d'assurer 60FPS.

### 🛠️ Scripts : Pipeline de Synchronisation (ETL)
- **Harvest (Scrapers)**: Extraient les données brutes (Trombi, Agenda, MiNET) vers JSON dans `data/scraps/`. *Indépendants de la base de données.*
- **Ingest (Loaders)**: Synchronisent les JSON vers PostgreSQL. Gèrent la fusion (Merge) des données web avec les identités locales.
- **Vault (Backup)**: Système de sauvegarde portable dans `data/exports/`. Archive la recherche manuelle (Relations, Socials, Notes) et les calibrations de cartes.
- **TUI**: Interface interactive via `questionary` et `rich`.

---

## 🗃️ Modèle de Données & Lifecycles

### 1. Hard Infrastructure (Maps)
- **Table**: `MapMetadata`. Coordonnées de calibration 2-Pilliers.
- **Handling**: Source de vérité DB. Exportée vers `maps.json`. Restaurée en premier pour l'ancrage spatial.

### 2. Human Intelligence (OSINT Research)
- **Tables**: `SocialLink`, `StudentRelationship`, `Media` (Comms Log).
- **Handling**: Données créées par l'utilisateur. **Cruciales.** Protégées par le Vault. Ne sont jamais écrasées par un scrape automatisé.

### 3. External Subjects (Directory)
- **Tables**: `Student`, `Club`, `StudentClub`.
- **Handling**: Données issues du web. Hydratation (Upsert). Si un sujet disparaît du web, il est marqué `is_active: false` pour préserver ses notes OSINT.

---

## 📟 Manuel d'Exploitation (Normal Language focus)

### Installation
```bash
# Dans PalantINT/scripts
uv sync
uv run palantint # Interactive UI
```

### Mandat de Langage
Toute interaction avec l'utilisateur (Web ou CLI) doit utiliser un **Langage Naturel Professionnel**. 
- ❌ "Deploy Operative", "Extraction Velocity", "ID_REF"
- ✅ "Ajouter un membre", "Vitesse de téléchargement", "Identifiant"

---

## 📂 Structure des Dossiers
- `/backend`: Logique API et Schémas.
- `/frontend`: Interface Brutaliste et Moteur 3D.
- `/scripts`: Outils de maintenance et pipeline de synchronisation.
- `/data/exports`: Le **Vault**. Contient les fichiers JSON de sauvegarde à commiter.
