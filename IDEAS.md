# 💡 PalantINT — Feature Roadmap & Ideas

This document outlines potential high-impact features leveraging the integrated campus SDKs (`casint`, `agendint`, `trombint`, `tsprint`, `laverint`).

---

## 🖨️ Physical-Digital Print Bridge
*Leveraging `tsprint` and academic metadata.*

*   **The "Cheat Sheet" Library**: A community repository of PDFs (exam summaries, admin forms). One-click "Print to Campus" directly from the browser without downloading.
*   **Physical Schedule Generator**: Generate a high-design, minimal PDF of your weekly timetable (personalized with your specific lab groups) and queue it for printing. Includes a profile QR code.
*   **"Remote Release" Map Integration**: Click a building on the Housing Map to see the printer's status. Trigger a job release from your phone when standing at the machine.
*   **Sustainability Dashboard**: Track and visualize your total "Paper Footprint" (trees/water consumed) based on historical page counts. Compare with campus averages.
*   **Peer-to-Peer Credit Hub**: Securely "gift" print jobs to friends or use your own credits to print a document shared by a classmate.
*   **Automated Lab Preparer**: Upload raw data; PalantINT auto-generates a professional cover page (using your profile and course data) and queues the complete report for printing.

## 🧺 Campus Life & Housing
*Leveraging `laverint` and the Housing Map.*

*   **Predictive Laundry Analytics**: A "Best Time to Wash" heatmap based on historical data. Suggests the quietest windows and integrates with your schedule gap analysis.
*   **The "Nudge" Protocol**: An anonymous notification layer. If a machine is finished but occupied, "nudge" the owner. Report leaks or broken machines directly on the Map.
*   **Real-time Occupancy Map**: An animated "Ghost Map" overlay showing campus activity levels based on live schedule data and residential distribution.
*   **Proactive Lost & Found**: Report items on specific rooms in the Map. The system cross-references the room's schedule and notifies students who were physically there just before the report.
*   **Social Wings (Opt-in)**: Choose to "reveal" your profile on your room in the Map. See who lives in your wing, their interests, and their "Current Status" (e.g., "Studying" or "Free").
*   **Virtual Laundry Queue**: Join a digital line when all machines are full. Receive a mobile alert and a 5-minute reservation window when a washer frees up.

## 🕒 Academic Intelligence
*Leveraging `agendint` and the Social Graph.*

*   **Dynamic Study Hub**: Start a study session for a specific course. The system automatically finds an empty classroom and identifies friends/classmates who are currently free to join.
*   **The "Shadow Promo" Algorithm**: Discovers your "Academic Twins"—classmates who share the highest percentage of your schedule but aren't in your social graph yet.
*   **Predictive Room Timelines**: Interactive occupancy bars for every classroom on campus. See exactly how much time is left before the next scheduled lecture starts in a specific room.
*   **Smart Exam Sentinel**: Automatically detects exam slots in the ADE feed. Triggers countdowns, exam-specific resource sharing, and "focus mode" alerts.
*   **Professor Directory**: A consolidated view of all campus faculty, their primary teaching locations, and a list of students currently enrolled in their courses.
*   **Live Academic Context (Opt-in)**: Visualize where your friends are physically located on campus based on their real-time schedule ("Leo is in U1-104").

## 🤖 Automation & System
*Leveraging Backend encryption and Async tasks.*

*   **The Self-Healing ETL**: Background monitors that identify data gaps (missing photos, stale schedules) and trigger targeted micro-scrapes to maintain 100% data integrity.
*   **Unified Proxy Interface**: Perform complex school portal actions (ADE room bookings, PaperCut top-ups) securely through the PalantINT backend proxy.
*   **System-Wide Webhooks**: An internal event bus for features to react to triggers like "Laundry Machine Available," "Schedule Change Detected," or "New Relationship Created."
*   **Automatic Governance Tracking**: Periodic scraping of associative portals to detect and flag new club "Mandat" members and bureau transitions automatically.
*   **The "Aggregate" View**: Support for external iCal imports (Google/Outlook) to merge personal lives with the academic schedule in a single high-performance view.
*   **Resource Sentinel**: Automated cleanup of transient data scraps and orphaned media to ensure database performance remains optimized.

## 📊 Global Analytics & Telemetry
*Leveraging `/admin/telemetry` and internal data density.*

*   **Campus Connectivity Index**: Anonymized network graphs visualizing social hubs and the strength of integration between different promos and schools.
*   **Room Performance Heatmaps**: Data-driven analysis of classroom utility. Identify under-utilized spaces versus high-demand lecture halls.
*   **Social integration Analytics**: Study the flow of relationships across different academic programs to measure campus-wide community health.
*   **ETL Health Dashboard**: Real-time telemetry on scraper success rates, school server latency, and database ingestion performance.
*   **Laundry Throughput Metrics**: Detailed reports on machine "uptime," average wait times per day, and peak utility periods for the Maisel residence.
*   **Global "Pulse" Analysis**: Anonymized keyword frequency from public notes to visualize campus-wide trends (e.g., during exam seasons or events).

---

## 🚀 Strategic implementation
Which features should be implemented first?
1.  **Laundry Radar** (High daily utility)
2.  **Silent Background Sync** (Technical robustness)
3.  **Intersect Meeting Finder** (Social utility)

---

## 🌐 INT Portal — Public Features
*No authentication required. Built from public sources only.*

### 📚 1. Course Catalog Browser
A fully searchable, filterable course module catalog — far more usable than the official scattered PDFs.

- **Data source:** Scrape https://enseignements.telecom-sudparis.eu/ (public, no login) for module codes, titles, ECTS, descriptions, professors, and semester.
- **Curriculum map integration:** Cross-link with the program schema at https://www.telecom-sudparis.eu/SchemaFormation/ to display each module's position in the degree path (which year, which track, prerequisites).
- **Features:** Filter by year (EI1/EI2/EI3), specialization/parcours, ECTS range, professor name, module code prefix. Full-text search on module descriptions.
- **Auto-update:** Periodic public scrape of the teaching catalog — no private access needed.

---

### 🔬 2. Research Lab Directory
A visual explorer for all TSP/IMT-BS research labs, their themes, faculty, and publications.

- **Data source:** Public lab pages on telecom-sudparis.eu and imtbs-tsp.eu, plus HAL open-access API (hal.science) for recent publications by affiliated authors.
- **Features:** Click a lab → see research axes, affiliated professors, recent papers (with DOI links), PhD positions, and industrial partnerships. Filter by theme (networks, AI, security, etc.).
- **Useful for:** Prospective PhD students, industry partners, and students choosing specializations.

---

### 🤝 3. Partner Company Map
A visual world map of the school's industrial and academic partners.

- **Data source:** Public partnership pages on both school sites — company names, logos, and sectors are listed publicly.
- **Features:** Interactive globe/map filtered by sector (telecom, finance, defense, consulting), partnership type (research, internship, hiring), and country. Click a company → see open offers if any.
- **Useful for:** Students targeting internship applications, especially international ones.

---

### 📰 4. News & Events Aggregator
A single unified feed merging all public communications from both schools.

- **Data source:** Public RSS feeds and news pages from telecom-sudparis.eu, imtbs-tsp.eu, association pages, social media (public accounts).
- **Features:** Filter by theme (events, alumni spotlights, research, admin, associations). Timeline view, keyword search, and RSS export for subscribers.
- **Why it matters:** The school runs ~5 separate websites that never appear together. Students miss announcements constantly.

---

### 🌍 5. Exchange Program Browser
An interactive map of partner universities for Erasmus and international exchange.

- **Data source:** Public partner university lists on the school sites (PDF/HTML tables on international pages).
- **Features:** World map pinning each destination, filterable by language of instruction, GPA requirement, semester availability (S1/S2/full year), and region. Student testimonials submitted via a simple form (opt-in, no login needed for reading).
- **Useful for:** 2nd-year students making exchange choices — currently this data is buried in PDFs.

---

### 💼 6. Internship & Job Offers Aggregator
A better UI over the public internship offer listings the school already posts.

- **Data source:** School's public job board / career portal (public listings, no login for reading on most deployments).
- **Features:** Saved searches, email alert subscriptions, offer tagging by domain/duration/location, and direct application link. Mobile-friendly card layout vs the current table-based portal.

---

### 🍽️ 7. Campus Restaurant Menu Viewer
Daily and weekly menus for campus dining with diet filters.

- **Data source:** Crous semi-public API (api.crous-montpellier.fr pattern, or direct HTML scrape of the posted weekly menus). Menus are public.
- **Features:** Weekly view, allergen/diet filters (végétarien, sans gluten, etc.), anonymous dish rating, and a "vote for tomorrow" feature. Optionally notify when a preferred dish is on the menu.
- **Fastest win:** Crous publishes menus publicly — this is a 1-day build with high daily usage.

---

### 🏆 8. Alumni Tracker (Public)
A "where are our alumni now" explorer built from public data.

- **Data source:** School-published alumni spotlights and testimonials (publicly posted on the school site), supplemented by opt-in alumni self-submission form.
- **Features:** Filter by graduation year, sector, company, country. Shows career paths (EI1 → internship → first job → current). No private data — only self-submitted or school-published profiles.

---

### 📊 9. Admissions Stats Dashboard
Historical admissions data visualized for prospective students.

- **Data source:** Public SIGEM rankings data, CPGE acceptance statistics, and school-published class profiles (all public yearly reports).
- **Features:** Charts showing acceptance rate trends by filière (MP, PC, PSI, TSI, etc.), evolution of class median rank, and peer school comparisons. Useful for guidance counselors and applicants assessing realistic targets.

---

### 📅 10. Public Events Calendar
All open campus events in one place.

- **Data source:** Public pages of student associations, school social media (public accounts), and official event announcements.
- **Features:** Filterable unified calendar (career fairs, hackathons, open days, concerts, sports), iCal/Google Calendar export, and an open event submission form for associations to post directly. No private data — entirely community-submitted and publicly sourced.

---

### 🎯 Priority for INT Portal Public Features
| # | Feature | Effort | Daily Impact |
|---|---------|--------|-------------|
| 7 | Campus Restaurant Menu | ⭐ Low | ⭐⭐⭐ High |
| 1 | Course Catalog Browser | ⭐⭐ Med | ⭐⭐⭐ High |
| 9 | Admissions Dashboard | ⭐ Low | ⭐⭐ Med (prospective) |
| 5 | Exchange Program Browser | ⭐⭐ Med | ⭐⭐⭐ High (annual) |
| 4 | News Aggregator | ⭐ Low | ⭐⭐ Med |
| 2 | Research Lab Directory | ⭐⭐ Med | ⭐ Low (niche) |
| 3 | Partner Company Map | ⭐⭐ Med | ⭐⭐ Med |
| 6 | Job Offers Aggregator | ⭐⭐ Med | ⭐⭐ Med |
| 10 | Public Events Calendar | ⭐⭐ Med | ⭐⭐ Med |
| 8 | Alumni Tracker | ⭐⭐⭐ High | ⭐ Low |
