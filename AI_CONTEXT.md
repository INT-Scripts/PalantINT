# PalantINT — Dossier Technique Exhaustif (Deep AI Context)

Dernière mise à jour : 2024-03-04 (Cycle de Vie Idempotent & Volume Unifié)

## 👁️ Mission & Vision
**PalantINT** est une plateforme de renseignement interne (OSINT) conçue pour le campus **IMT-BS / Télécom SudParis**. Son but est d'unifier des sources de données disparates (Trombinoscope, ADE, BDE, Logements) dans une interface unique, rapide et immersive.

Le projet suit une esthétique "Cyber-Espionnage" :
- **OSINT**: Open Source Intelligence (recherche en sources ouvertes).
- **Automation**: Synchronisation périodique intelligente avec les SI de l'école.
- **Interactivité**: Cartographie thermique (Thermal Radar) de la résidence Maisel.

---

## 🏗️ Architecture Technique Profonde

### 🐍 Backend : FastAPI High-Performance
- **Architecture**: REST API Asynchrone (FastAPI + Pydantic v2).
- **Docker**:
  - `Dockerfile`: Mode **Développement** (Uvicorn + `--reload` + Host volume mount).
  - `Dockerfile.prod`: Mode **Production** (Multi-workers, pas de reload, image optimisée).
- **ORM**: SQLModel (fusion de SQLAlchemy et Pydantic).
- **Base de données**: PostgreSQL.
- **Migrations**: Alembic (utilisé en production pour le versioning du schéma).
- **Sécurité**:
  - Authentification par jeton **JWT** (python-jose).
  - Hashage de mot de passe **Bcrypt**.
- **Gestionnaire**: `uv` (remplaçant pip/poetry pour une vitesse d'installation fulgurante).

### ⚛️ Frontend : Next.js 15 (Edge Ready)
- **Framework**: Next.js 15 avec l'architecture **App Router**.
- **Moteur de rendu**: React 19 (Client-side logic with backend API).
- **Docker**:
  - `Dockerfile`: Mode **Développement** (`npm run dev` + Host volume mount).
  - `Dockerfile.prod`: Mode **Production** (Static export `next export` ⮕ **Nginx** pour servir les fichiers statiques).
- **Stylisme**: Tailwind CSS 4 (Configuration asymétrique, Glassmorphism).
- **Lancer**: `npm run dev` pour le développement local.
- **Icônes**: Lucide React.
- **Client API**: `lib/api.ts` centralise la gestion du token JWT, le refresh automatique et la gestion des erreurs 401.

---

## 🗃️ Structure du Système de Fichiers (Sitemap Code)

### 📂 `/backend` (Le Cerveau)
- `app/main.py`: Point d'entrée, montage des routes et des dossiers statiques (`/assets`).
- `app/db/models.py`: Définition unique de la vérité (SQLModel).
- `app/api/routers/`: Organisation modulaire :
  - `api_students.py`: Recherche unaccentuée, profils, logements.
  - `api_clubs.py`: Gestion des assos et membres.
  - `api_media.py`: Gestion des uploads (Images/Vidéos/Notes).
  - `api_agenda.py`: Calcul et service des emplois du temps (via calendar_ids).
  - `api_relationships.py`: Graphe social.

### 📂 `/scripts` (L'Usine à Données)
- `scrape_all.py`: Orchestrateur "Rich" (Dashboard CLI temps réel). 
  - **Séquence**: Seed Relationships ⮕ Clubs ⮕ Trombi ⮕ Backfill ⮕ Agenda ⮕ Fix Images.
- `scrape_trombint/`: Automate extraction ⮕ Upsert DB.
- `scrape_clubs/`: Extraction des descriptifs et logos depuis le portail BDE.
- `import_agenda/`: Parsing des fichiers `.json` d'ADE.
- `backfill_students/`: Enrichissement via recherche (École et Filière précises).
- `svg_processor/`: Algorithme OpenCV pour le Thermal Radar.
- `portability.sh`: Script "Save & Load" pour migrer/backup le projet.

### 📂 `/data` (La Persistance Unifiée)
*Note : Ce dossier est monté en tant que volume Docker.*
- `/assets/profiles/`: Câche des photos d'étudiants.
- `/assets/plans/`: Cartes traitées (SVG) et plans originaux (PNG).
- `/assets/media/`: Contenu généré par les utilisateurs.
- `/scraps/`: Stockage des JSON bruts et fichiers sources.

---

## 🗃️ Modèle de Données (Détails)

| Modèle | Description | Champs Clés |
|--------|-------------|-------------|
| `User` | Comptes admin | `username`, `hashed_password`, `is_admin` |
| `Student` | Cœur du système | `trombint_id` (Unique ID), `first_name`, `last_name`, `email`, `ecole`, `promo`, `apartment` |
| `Club` | Entités sociales | `association_of_origin` (BDE/BDA/ASINT), `slug`, `color_primary` |
| `StudentClub` | Appartenance | `student_id`, `club_id`, `role`, `is_mandat` |
| `AgendaEvent` | Calendrier | `event_ref_id` (UID ADE), `calendar_id`, `start_time`, `room`, `professors` |
| `Relationship` | Graphe Social | `student_a_id`, `student_b_id`, `relationship_type_id` |
| `RelationshipType`| Catégories | `Amis` (Bleu), `En couple` (Rose), `Ex` (Rouge) |
| `Media` | Extensions profil| `IMAGE`, `VIDEO`, `NOTE`, `author_name`, `content` |

---

## 🗺️ Logiques Spécifiques Importantes

### 1. Cycle de Vie Idempotent (Smart Sync)
Nous n'utilisons plus la purge automatique (`drop_all`) par défaut.
- **Upsert PostgreSQL**: Le scraper utilise `ON CONFLICT (trombint_id) DO UPDATE`. Les données sont rafraîchies mais les relations (`Media`, `SocialLinks`) ne sont jamais rompues.
- **Image Check**: `scrape_trombint.py` vérifie si `{trombint_id}.jpg` existe sur le disque avant de re-télécharger.

### 2. Le "Thermal Radar" (Interactivité Cartographique)
Le script `process_svgs.py` exécute les étapes suivantes :
1. **Rasterisation**: Les murs du SVG sont dessinés sur une image NumPy (OpenCV).
2. **Identification**: Le script cherche les labels de texte (ex: "7523").
3. **Flood Fill**: À partir du centre du texte, on remplit la zone jusqu'aux murs détectés.
4. **Vectorisation**: Le contour de la zone remplie est converti en `<polygon>` avec une classe CSS `room-area`.
5. **Injection HTML**: Le polygone est entouré d'un lien `<a>` avec `data-room="7523"` pour le frontend.

### 3. Gestion des Médias
Les fichiers média sont enregistrés dans `data/assets/media/`. La base de données stocke le chemin relatif.
- Le backend sert ces fichiers via un point de montage statique `/assets` définit dans `app/main.py`.

---

## 📟 Manuel d'Exploitation (CLI)

### Déploiement Local (Développement)
```bash
# Lance l'environnement avec hot-reload (via compose.override.yaml)
docker compose up --watch
```
*Le portail est accessible sur http://localhost. Les services utilisent un port unique (FE: 80, BE: 3000) orchestrés par un Nginx unifié.*

### Déploiement Production (Simulation)
```bash
# Utilise les Dockerfiles de production et Nginx statique
docker compose -f compose.yaml -f compose.prod.yaml up --build
```

### Script de Portabilité (Backup/Migrate)
```bash
# Sauvegarder (Archive DB + /data)
./scripts/portability.sh save mon_backup.tar.gz

# Restaurer (Wipe actuel et remplace par archive)
./scripts/portability.sh load mon_backup.tar.gz
```

### Gestion des Administrateurs
```bash
# Créer ou mettre à jour un admin
uv run python scripts/create_admin/create_admin.py mon_pseudo mon_password
```

### Maintenance Database (Alembic)
```bash
cd backend
# Voir les instructions dans backend/alembic/README.md
uv run alembic upgrade head
```