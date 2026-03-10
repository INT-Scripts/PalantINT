<div align="center">

<img src="frontend/public/palantint.svg" width="200" alt="PalantINT Logo" />

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
| 🏰 **3D Digital Twin** | WebGL structural wireframes of residence buildings with zero-lag interaction. |
| 🛡️ **OSINT Vault** | Portable backup system for manual research, social graphs, and map calibrations. |
| 📅 **Schedule Sync** | Real-time timetable cross-referencing for students and rooms. |
| 🏛️ **Organization Hub** | Branded club profiles with full member rosters and event logs. |
| 📸 **Comms Log** | Unified student-specific intelligence gallery for images, videos, and notes. |

---

## 🏗️ Architecture

The platform is built using a decentralized **Extract, Transform, Load (ETL)** pipeline and independent submodules.

```text
PalantINT/
├── backend/       ← 🐍 FastAPI + DB Models & REST API
├── frontend/      ← ⚛️  Next.js 15 + Three.js WebGL Engine
├── scripts/       ← 🛠️  Synchronization Pipeline & Vault Tools
├── int-libraries/ ← 📚  Shared SDKs (trombint, casint) [submodule]
├── data/          ← 📦  Persistent volume (assets, vault, scraps)
├── compose.yaml   ← 🐳  Docker Compose (base)
└── nginx.conf     ← 🌐  Reverse proxy config
```

### Component Roles

| Component | Tech Stack | Role |
|-----------|------------|------|
| **Backend** | FastAPI · SQLModel | REST API & Central Database logic. |
| **Frontend** | Next.js 15 · Three.js | Brutalist interface & 3D visualization. |
| **Scripts** | Python · Rich TUI | Data synchronization & vault management. |
| **int-libraries** | HTTPX · BeautifulSoup | Standalone generic campus SDKs. |

---

## 🛠️ Data Synchronization

The **scripts** directory contains the interactive command center for synchronizing data sources and managing the vault.

```bash
cd scripts/
uv run palantint         # Launch the Unified Command Center
```

### Operational Lifecycle

*   **Scraping Phase**: Harvesting raw web data into `data/scraps/`. *Offline-safe once complete.*
*   **Loading Phase**: Hydrating the database from local scraps and the OSINT vault.
*   **Vault Phase**: Automatic snapshots of manual research into `data/exports/`.
*   **Strategies**: 
    *   **Incremental**: Add new data while preserving all existing records.
    *   **Refresh**: Deep-update of all subjects from the web.
    *   **Wipe & Reload**: Full database reset (Vault restore ensures research persistence).

---

## 🔐 Deployment

### Prerequisites
- [Docker](https://docs.docker.com/get-docker/) & [Docker Compose](https://docs.docker.com/compose/)
- [uv](https://github.com/astral-sh/uv) (for pipeline execution)

### Setup
```bash
git clone --recurse-submodules https://github.com/INT-Scripts/PalantINT.git
docker compose up -d
cd scripts/
uv run palantint-admin admin mypassword # Create root access
```

---

## 📜 License

This project is private and intended for internal use within the INT-Scripts organization.

---

<div align="center">
<sub>Built with 🖤 by the PalantINT Team</sub>
</div>
