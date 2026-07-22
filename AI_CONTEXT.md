# PalantINT & INT Portal — Technical Architecture & Deep AI Context

Dernière mise à jour : 2026-07-22 (Architecture bicipale : PalantINT Private OSINT vs. INT Portal Public Space)

---

## 👁️ Vision & Architecture à Deux Espaces

Le projet unifie deux applications distinctes partageant un backend FastAPI et une base de données PostgreSQL commune :

```
                        ┌─────────────────────────────────────────┐
                        │              Nginx Proxy                │
                        └────┬───────────────────────────────┬────┘
                             │                               │
                /api/private │                               │ /api/public & /assets
                             ▼                               ▼
       ┌───────────────────────────────┐           ┌───────────────────────────────┐
       │   PalantINT (Espace Privé)    │           │    INT Portal (Espace Public)  │
       ├───────────────────────────────┤           ├───────────────────────────────┤
       │ • Dashboard OSINT & Annuaire  │           │ • Live Laundry Telemetry      │
       │ • Carte 3D & Occupation Room  │           │ • Housing Pricing & Specs     │
       │ • Trombinoscope & Social Log  │           │ • Accredited Clubs & Orgs     │
       │ • Theme: Brutalist Zinc-950   │           │ • Theme: Warm Ivory & Sand    │
       └───────────────────────────────┘           └───────────────────────────────┘
```

---

## 🏛️ 1. INT Portal (Espace Public)

### Rôle & Public
Le portail citoyen tout-en-un accessible librement par tous les étudiants, intervenants et visiteurs du campus sans authentification.

### Design System & Esthétique
* **Palette** : Warm Ivory & Sand (`bg-stone-50` / `bg-stone-900` en mode sombre).
* **Fond dynamique** : Motif pointillé vectoriel discret (`radial-gradient`) superposé à un dégradé doux d'arrière-plan.
* **Header & Shell** : Barre sticky translucide avec logo d'icône `Layers`, basculeur de thème persistent (`ThemeToggle`), et footer minimaliste à filigrane géant `INT PORTAL`.
* **Zero Flash SSR** : Script bloquant synchrone injecté dans le `<head>` de `layout.tsx` empêchant tout clignotement de thème lors du rendu côté serveur.

### Modules Publics Principaux
1. **Accueil (`/`)** : Hero section épurée avec grille éditoriale en 3 colonnes égales (Clubs, Logements, Laverie).
2. **Moniteur de Laverie (`/laundry`)** : Suivi télémetrique en temps réel des machines à laver (mal) et séchoirs (sl) sur les bâtiments U3 à U7 via `/api/laundry/{building}`.
3. **Répertoire du Logement (`/apartments`)** : Catalogue interactif des chambres Maisel (surfaces en m², tarifs de base, calculs boursier/non-boursier, critères PMR) via `/api/students/apartments/details`.
4. **Annuaire des Associations (`/clubs`)** : Répertoire classé par association parente (BDE, BDA, ASINT...) avec tiroir modal de détails et bouclier de protection de la vie privée (`ShieldAlert`).

---

## 👁️ 2. PalantINT (Espace Privé OSINT)

### Rôle & Public
Plateforme d'analyse, d'administration et de cartographie haute précision réservée aux opérateurs et administrateurs autorisés.

### Design System & Esthétique
* **Palette** : Luxe Professionnel Brutaliste (Zinc-950, néons sombres, DataGrids haute densité).
* **Composants** : Jumeau numérique 3D (`BuildingModel`) via Three.js, cartographie vectorielle interactive SVG avec bypass de cycle React pour 60FPS.

### Modules Privés Principaux
1. **Annuaire Etudiant & Trombinoscope** : Recherche globale avec photos de profil (`/students/{id}/image`).
2. **Occupants des Logements (`/palantint/apartments`)** : Cartographie nominative associant chaque numéro de chambre à l'identité de son étudiant occupant (`/students/apartments/occupied`).
3. **Graph & Relations (`/palantint/network`)** : Graphe des liens d'amitié, promo et associations.
4. **Système de Notifications (`/notifications/laundry/subscribe`)** : Alarmes automatiques de libération de machines.
5. **Panneau Administration (`/palantint/admin`)** : Ingestion de données, gestion du Vault et calibrations de cartes.

---

## 🛡️ Séparation Strictement Imposée Backend (Public / Private)

Le backend FastAPI (`backend/src/main.py`) sépare hermétiquement les deux contextes :

### Routes Publics (`public_router`, pas d'auth)
* **Endpoints** : `/clubs`, `/class-groups`, `/laundry/{building}`, `/students/apartments/details`, `/assets/*`.
* **Garantie** : Protégés par rate-limiting (`rate_limit_dep`). **Aucune PII (Personally Identifiable Information)** n'est retournée. Les listes de membres, photos d'étudiants et informations nominatives en sont strictement exclues.

### Routes Privées (`private_router`, auth requise)
* **Endpoints** : `/private/users/*`, `/private/students/occupied`, `/private/notifications/*`, `/private/admin/*`.
* **Garantie** : Injection obligatoire de la dépendance JWT `require_user_query_token`. Chiffrement AES-128 (Fernet) pour les secrets d'accès.

---

## 🏗️ Architecture Technique Global

### 🐍 Backend : FastAPI & SQLModel
* **Moteur** : FastAPI async (`uv`).
* **Base de données** : PostgreSQL 16 + SQLModel (SQLAlchemy + Pydantic v2) + Alembic.
* **Localisation** : `/backend`.

### ⚛️ Frontend : Next.js 15 (App Router)
* **Sous-module Git** : Maintenu dans `/frontend` (`INT-Scripts/palantint-frontend`).
* **Routes App** :
  * `src/app/(portal)` -> INT Portal (Espace Public).
  * `src/app/(palantint)` -> PalantINT (Espace Privé).

### 🛠️ Scripts & Pipeline ETL
* **Scrapers & Loaders** : Fichiers dans `/scripts` alimentant `data/scraps/` et PostgreSQL.
* **Vault Backup** : Fichiers dans `/data/exports/` contenant les sauvegardes à versionner sous Git.

---

## 🗃️ Lifecycles des Données

1. **Hard Infrastructure (Maps)** : `MapMetadata` stocké en base et exporté dans `maps.json`.
2. **Human Intelligence (OSINT)** : `SocialLink`, `StudentRelationship`, `Media` — Données créées par l'utilisateur, protégées par le Vault.
3. **External Subjects (Directory)** : `Student`, `Club` — Données web synchronisées avec marquage `is_active: false` en cas de disparition.
