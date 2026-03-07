# PalantINT — Documentation Technique Complète (Deep AI Context)

Dernière mise à jour : 2026-03-07 (Architecture ETL Décentralisée & Purge du Jargon)

## 👁️ Objectifs & Vision
**PalantINT** est une plateforme de visualisation de données de campus pour **IMT-BS / Télécom SudParis**. Elle unifie des sources de données disparates (Trombinoscope, Emplois du temps, Clubs, Logements) dans une interface unique, performante et esthétique.

Le projet suit un standard de **Luxe Professionnel Brutaliste** :
- **Data-First**: Visualisation haute densité via des grilles de données (DataGrid).
- **Asynchrone**: Pipeline ETL asynchrone ultra-rapide via `httpx` et `asyncio`.
- **Interactivité**: Cartographie du logement étudiant (Housing Map) via OpenCV.

---

## 🏗️ Architecture Technique

### 🐍 Backend : FastAPI & SQLModel
- **Architecture**: REST API Asynchrone.
- **Modèles**: SQLModel (SQLAlchemy + Pydantic v2). Le backend contient désormais les modèles de données et la logique de base de données (anciennement dans `core`).
- **Migrations**: Alembic pour le versioning du schéma PostgreSQL.
- **Sécurité**: 
  - Authentification JWT.
  - Chiffrement symétrique **Fernet (AES-128)** pour le stockage sécurisé des identifiants CAS des utilisateurs.

### ⚛️ Frontend : Next.js 15
- **Moteur**: React 19 + App Router.
- **Style**: Tailwind CSS 4. Glassmorphism sombre sur fond Zinc-950.
- **Composants Clés**:
  - `Admin Dashboard`: Grille d'édition en direct (Excel-like).
  - `Account Page`: Vue centralisée de l'identité de l'utilisateur et de son emploi du temps (Schedule).

### 🛠️ Scripts : Pipeline ETL
- **Extracteurs (`extractors/`)**: Scrapers purs (TrombINT, Agenda, Backfill). Sauvegardent les données brutes en JSON dans `data/scraps/`. *Indépendants de la DB.*
- **Chargeurs (`loaders/`)**: Synchronisent les fichiers JSON vers PostgreSQL. *Indépendants d'Internet.*
- **TUI**: Wizard interactif via `questionary` (navigation au clavier).

---

## 🗃️ Structure du Système (Sitemap)

### 📂 `/backend`
- `src/db/models.py`: Source de vérité unique (Students, Clubs, Events, Users, etc).
- `src/api/routes.py`: Endpoints administratifs et utilisateurs.
- `src/core/auth.py`: Logique JWT et Chiffrement Fernet.

### 📂 `/scripts`
- `src/palantint_scripts/scrape_all.py`: Orchestrateur ETL interactive.
- `src/palantint_scripts/extractors/`: Logique de scraping vers JSON.
- `src/palantint_scripts/loaders/`: Logique de synchronisation JSON ⮕ DB.

### 📂 `/int-libraries` (Submodule)
- SDKs autonomes et génériques : `casint`, `agendint`, `trombint`, `laverint`, `tsprint`.

---

## 🗃️ Modèle de Données (Résumé)

| Modèle | Description |
|--------|-------------|
| `User` | Comptes applicatifs. Stocke `cas_username` et `encrypted_cas_password`. |
| `Student` | Identités étudiantes (trombint_id, email, logement, ecole). |
| `Club` | Organisations associatives et rosters. |
| `AgendaEvent`| Événements d'emplois du temps synchronisés. |
| `Relationship`| Graphe social entre étudiants. |

---

## 📟 Manuel d'Exploitation (uv focus)

### Installation & Sync
```bash
# Dans PalantINT/scripts
uv sync
uv run palantint-scrape
```

### Développement
```bash
docker compose up --watch
```

### Chiffrement CAS
Les mots de passe CAS sont chiffrés en base de données. La clé est gérée par la variable d'environnement `FERNET_KEY`.
