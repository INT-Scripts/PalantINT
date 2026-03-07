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
