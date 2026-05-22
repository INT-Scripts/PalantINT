# Agendint Upgrade Proposals

This document outlines strategic and technical upgrades for the `agendint` library to improve performance, resiliency, and developer experience.

## 1. Resiliency & Network Upgrades

### Implement Session Persistence
Currently, every invocation of the CLI triggers a full CAS login flow.
- **Upgrade**: Serialize the `httpx.Cookies` to a secure local file (e.g., `~/.agendint/session.json`). On boot, attempt to load these cookies and perform a lightweight ping. Only trigger the heavy `casint` login if the session is expired or invalid.
- **Benefit**: Vastly speeds up rapid CLI executions and reduces load on the IMT CAS servers.

### Automatic Retries (`tenacity`)
The SI Ecoles SAML bridges and agenda endpoints are notorious for sporadic timeouts and HTTP 500s.
- **Upgrade**: Wrap network calls (especially `get_event_details`) with the `tenacity` library to automatically retry on `httpx.ReadTimeout` or 50x errors with exponential backoff.
- **Benefit**: Prevents a 500-event hydration job from crashing at 99% due to a single dropped packet.

## 2. Architecture & Parsing

### Async Generators (Streaming)
Currently, `get_events` and `get_event_details_batch` build massive arrays in memory and return them all at once.
- **Upgrade**: Refactor these to be `async def` generators that `yield` events as they are parsed.
- **Benefit**: Allows the CLI to stream exports to a file incrementally, drastically reducing memory footprint for multi-year queries and providing instant feedback.

### Parser Abstraction
The HTML parsing logic (regex, `BeautifulSoup`) is deeply intertwined with the HTTP logic in `api.py`.
- **Upgrade**: Extract parsing into isolated classes or functions (e.g., `parse_agenda_grid(html: str) -> List[Event]`).
- **Benefit**: Makes the codebase testable. You can save raw HTML payloads as test fixtures and write `pytest` suites to ensure regex changes don't break extraction.

## 3. Storage & Caching Layer

### Request/Response Caching
When hydrating details, many events share the same underlying data or might be requested repeatedly across different runs.
- **Upgrade**: Integrate `Hishel` or a simple `SQLite`/`diskcache` layer into `SIClient` to cache HTTP `GET` responses based on their URL and parameters (respecting TTLs like 1 hour for historical data, shorter for future data).
- **Benefit**: Lightning-fast re-runs and reduced bandwidth.

## 4. Developer Experience & CLI

### Enhanced Rich Integration
The CLI currently uses basic `print` statements mixed with a `rich` progress bar that is only dynamically imported.
- **Upgrade**: Fully embrace `rich` for the entire CLI. Use `rich.table` for the `list` command, `rich.panel` for displaying individual event details, and `rich.console` for colored, structured logging instead of standard `print`.

### strict `mypy` and Schema Validation
- **Upgrade**: Enforce strict `mypy` type checking across the library. 
- **Upgrade**: Use Pydantic's `@field_validator` in `models.py` to strictly normalize things like date formats (`YYYY-MM-DD`) and times (`HH:MM`) upon instantiation, rather than handling string parsing manually down the line in exporters.
