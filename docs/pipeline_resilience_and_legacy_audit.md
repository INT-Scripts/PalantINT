# PalantINT Agenda System: Legacy Audit & Pipeline Resilience Report

This document provides a comprehensive technical audit of the agenda system's legacy components, analyzes the cascading failures that occur if the internal SRNI academic groups scraper (`groupes.py` pointing to `srni.telecom-sudparis.eu`) becomes inaccessible, and proposes minimal-effort architectural fallbacks to ensure PalantINT remains fully operational.

---

## 1. Audit of Legacy Agenda Components

During our refactoring of the calendar and relational cohort models, we identified several legacy elements that previously constrained the scalability of the application:

### A. Static Promotion Calendar Fallbacks (`get_implicit_calendar_ids`)
* **Legacy Design:** Located in `backend/src/api/api_agenda.py`. It contained a hardcoded Python dictionary mapping student academic `promo` strings (e.g. `"Ingénieur 1ère année"`) and `ecole` to static calendar code IDs (e.g. `"PRJ67059"`).
* **The Constraint:** This blind fallback returned the *entire* promotion's schedules. It completely lacked the ability to filter down to specific class divisions (e.g. Gr 2a vs. Gr 2b), language sections, or elective choices, causing massive schedule clutter.

### B. Group Abuse of the `Club` Table
* **Legacy Design:** Historically, the database schema lacked a `ClassGroup` table. The old `agenda.py` loader was forced to write academic group mappings (like `"Gp-EI1-G2a"`) directly into the `Club` (student association) table.
* **The Constraint:** This severely polluted the student organization directory in the UI, making academic cohorts appear as clubs and complicating queries.

### C. Missing Junction Tables
* **Legacy Design:** `AgendaEvent` had a foreign key pointing to `Club` but possessed no structural link to academic segments. Additionally, the `StudentAgendaEvent` junction was left completely unpopulated during the synchronization loop.
* **The Constraint:** Without direct database relationships, the system could not relate academic events to students cleanly, requiring fragile parsing fallbacks on every API call.

---

## 2. Pipeline Failure Analysis: Losing access to SRNI (`srni.xxx`)

The academic groups scraper (`scripts/src/palantint_scripts/scrapers/groupes.py`) harvests class membership structures from the internal campus indicator portal:
`https://srni.telecom-sudparis.eu/indicators/groupes.html`

If this URL is decommissioned, blockaded, or CAS authentication permissions change, the pipeline breaks in a cascading fashion:

```
[SRNI Link Inaccessible] 
       │
       ▼
1. groupes.json Scraping Fails (manifest becomes empty/missing)
       │
       ▼
2. loaders/groupes.py Synced Tables (ClassGroup & StudentClassGroup) Are Left Empty
       │
       ▼
3. Identity Mapping Breaks in loaders/agenda.py
   (id_objet_to_student_id lookup is empty; cannot map USR41574.json to Dimitri Fajal)
       │
       ▼
4. StudentAgendaEvent Table Populates 0 Links
       │
       ▼
5. Deduplicated Timetable API Returns 0 Calendar Events for Logged-in Users
```

---

## 3. Least-Effort Fallback Strategies for Offline Resilience

To ensure PalantINT remains robustly functional even when the internal group mapping portal is completely offline or inaccessible, three "least effort" strategies are proposed:

### Strategy A: The Cached Static Topology Snapshot (Zero Code Changes)
* **How it works:** Since student class cohort memberships (e.g., who is registered in Gr 2a or Gr 2b) are highly static and rarely change after the first two weeks of the semester, we can commit a **pre-populated, packaged snapshot of `groupes.json`** directly to the repository (e.g. inside a `/data/scraps/cache/` directory).
* **Ingestion Modification:** If the CAS scraper fails to reach SRNI, the loader falls back to reading the cached copy.
* **Effort Required:** **Zero coding effort.** Simply backup the successfully generated `groupes.json` file inside the repository.

### Strategy B: Direct Manual Class/Calendar Selector in User Profiles
* **How it works:** Rather than dynamically scraping CAS groups to guess which calendar file (`USRxxxxx.json`) belongs to which logged-in LDAP username, we place a simple setting input in the user profile page.
* **UI Integration:** Prompt the student once on registration/login:
  * *"Select your class group"* (e.g. dropdown populated with standard sections like `Gp-EI1-G2a`, `Gp-EI1-G2b`).
  * *"Enter your personal calendar URL/ID"* (e.g. pasting their ADE calendar code `41574`).
* **Database Updates:** When saved, the backend directly updates `StudentClassGroup` and creates a single persistent link inside `StudentAgendaEvent`.
* **Effort Required:** **Minimal.** Bypasses all LDAP scraping entirely.

### Strategy C: Programmatic LDAP Username to Object ID Mapper
* **How it works:** If we only have access to TrombINT (`students.json` scraped from the public student registry), we can query the public student registry dynamically.
* **The Method:** The public TrombINT portal directory or CAS login callback itself often yields the student's internal object ID / reference ID. If we store this ID directly inside the `Student` table (e.g. `Student.ldap_id` or similar), `agenda.py` can immediately resolve `USRxxxxx.json` by matching `xxxxx` directly to the logged-in user without reading `groupes.json`.
* **Effort Required:** **Low.** A single column migration.
