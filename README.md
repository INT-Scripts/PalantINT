<div align="center">

# 🔮 PalantINT

**High-Performance Data Visualization Platform for IMT-BS / Télécom SudParis**

*A refined, brutalist data interface for the modern campus.*

[![Backend](https://img.shields.io/badge/Backend-FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://github.com/INT-Scripts/palantint-backend)
[![Frontend](https://img.shields.io/badge/Frontend-Next.js_15-000000?style=for-the-badge&logo=next.js&logoColor=white)](https://github.com/INT-Scripts/palantint-frontend)
[![Scripts](https://img.shields.io/badge/Scripts-Python_3.13-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://github.com/INT-Scripts/palantint-scripts)
[![DB](https://img.shields.io/badge/Database-PostgreSQL_18-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)

</div>

---

## About PalantINT

PalantINT unifies disparate campus data sources — student directories, schedules, club listings, and housing maps — into a single, immersive professional interface.

Built with a **Dark Luxury & Brutalist** aesthetic: glassmorphism on abyssal zinc backgrounds, sharp geometry, and high-density data grids.

### Key Features

| Feature | Description |
|---------|-------------|
| 👤 **Student Profiles** | Comprehensive identities with photos, schedules, relationships, and media. |
| 🗺️ **Housing Map** | Interactive SVG building plans with room-level resident lookup. |
| 📅 **Schedule Sync** | Real-time timetable cross-referencing for students and rooms. |
| 🏛️ **Club Directory** | BDE/BDA/ASINT club listings with full member rosters. |
| 🔗 **Social Graph** | Relationship mapping (friends, couples, ex) between students. |
| 📸 **Media Gallery** | Per-student image, video, and note attachments. |

---

## 🏗️ Architecture

The platform is built using a decentralized **Extract, Transform, Load (ETL)** pipeline and independent submodules.

```text
PalantINT/
├── backend/       ← 🐍 FastAPI + DB Models & Alembic
├── frontend/      ← ⚛️  Next.js 15 App Router
├── scripts/       ← 🛠️ ETL Pipeline & Maintenance Tools
├── int-libraries/ ← 📚 Shared SDKs (trombint, casint) [submodule]
├── data/          ← 📦 Persistent volume (assets, scraps)
├── compose.yaml   ← 🐳 Docker Compose (base)
└── nginx.conf     ← 🌐 Reverse proxy config
```

### Component Roles

| Component | Tech Stack | Role |
|-----------|------------|------|
| **Backend** | FastAPI · SQLModel | REST API & Central Database logic. |
| **Frontend** | Next.js 15 · Tailwind 4 | Brutalist glassmorphism interface. |
| **Scripts** | Python · Questionary TUI | Data ingestion & system maintenance. |
| **int-libraries** | HTTPX · BeautifulSoup | Standalone generic campus SDKs. |

---

## 🚀 Getting Started

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) & [Docker Compose](https://docs.docker.com/compose/)
- [uv](https://github.com/astral-sh/uv) (for running scripts)

### Clone

```bash
git clone --recurse-submodules https://github.com/INT-Scripts/PalantINT.git
cd PalantINT
```

### Development (Hot-Reload)

```bash
docker compose up --watch
```

The app is served at **http://localhost** via Nginx.

---

## 🛠️ Data Pipeline (ETL)

The **scripts** directory contains an interactive ETL pipeline for scraping and synchronizing data sources.

```bash
cd scripts/
uv run palantint-scrape         # Launch the interactive setup wizard
```

### Operation Modes

*   **Extraction Phase**: Pure web scraping. Connects to school servers and saves raw data as JSON in `data/scraps/`. *No DB required.*
*   **Load Phase**: Synchronizes JSON files into PostgreSQL. *No internet required.*
*   **Database Modes**: Incremental (default), Hydrate (re-verify), or Purge (wipe).
*   **Speed Modes**: Stealth (1s delay), Normal, or Aggressive (0s delay).

### System Tools

```bash
uv run palantint-admin <user> <pass>   # Create an admin account
uv run palantint-svg                   # Process building SVG plans
uv run palantint-print list-webprint   # Check campus printers
```

---

## 🔐 Account Setup

Once the database is populated, create an administrator account:

```bash
cd scripts/
uv run palantint-admin admin yourpassword
```

Navigate to **http://localhost/account** to manage your profile and access the **Admin Dashboard**.

---

## 📜 License

This project is private and intended for internal use within the INT-Scripts organization.

---

<div align="center">
<sub>Built with 🖤 by the PalantINT Team</sub>
</div>
