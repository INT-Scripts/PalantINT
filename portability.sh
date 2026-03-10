#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# PalantINT — Portability Script (Simplified)
# Archive the entire data/ folder (containing DB dump + assets).
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
DEFAULT_ARCHIVE="palantint-data-$(date +%Y%m%d).tar.gz"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
err()   { echo -e "${RED}[ERR]${NC}   $*" >&2; }

detect_db_container() {
    local container
    container=$(docker compose ps --format '{{.Name}}' 2>/dev/null | grep -i db || true)
    if [ -z "$container" ]; then
        container=$(docker ps --format '{{.Names}}' | grep -i postgres | head -1 || true)
    fi
    echo "$container"
}

do_save() {
    local archive="${1:-$DEFAULT_ARCHIVE}"
    local db_container
    db_container=$(detect_db_container)

    info "Starting export to $archive..."

    # Ensure data dir exists
    mkdir -p "$DATA_DIR"

    # 1. Database Dump (into data/ for simple archival)
    if [ -n "$db_container" ]; then
        info "Dumping database from $db_container..."
        docker exec "$db_container" pg_dump -U postgres -d palantint --clean --if-exists > "$DATA_DIR/database.sql"
        ok "Database exported: $(du -sh "$DATA_DIR/database.sql" | cut -f1)"
    else
        warn "Postgres container not found. Skipping DB dump."
    fi

    # 2. Archive the entire data folder
    info "Archiving $DATA_DIR..."
    tar -czf "$archive" data/
    
    # 3. Cleanup DB dump from local data/
    rm -f "$DATA_DIR/database.sql"

    ok "Export complete! File: $archive ($(du -sh "$archive" | cut -f1))"
}

do_load() {
    local archive="${1:-}"
    if [ -z "$archive" ] || [ ! -f "$archive" ]; then
        err "Usage: ./portability.sh load <archive.tar.gz>"
        exit 1
    fi

    info "Starting import from $archive..."

    # 1. Restore data/ folder
    if [ -d "$DATA_DIR" ]; then
        local bak="data.bak.$(date +%s)"
        warn "Existing data/ found. Moving to $bak"
        mv "$DATA_DIR" "$SCRIPT_DIR/$bak"
    fi

    info "Extracting archive..."
    tar -xzf "$archive" -C "$SCRIPT_DIR"
    ok "Data folder restored."

    # 2. Restore Database if dump exists
    if [ -f "$DATA_DIR/database.sql" ]; then
        local db_container
        db_container=$(detect_db_container)
        
        if [ -z "$db_container" ]; then
            info "Starting database container..."
            docker compose up -d db
            sleep 3
            db_container=$(detect_db_container)
        fi

        if [ -n "$db_container" ]; then
            info "Restoring database into $db_container..."
            docker exec -i "$db_container" psql -U postgres -d palantint < "$DATA_DIR/database.sql" > /dev/null
            ok "Database restored."
            # Cleanup
            rm -f "$DATA_DIR/database.sql"
        else
            err "Database container still not found. Please restore manually from data/database.sql"
        fi
    fi

    ok "Import complete!"
}

case "${1:-}" in
    save) do_save "${2:-}" ;;
    load) do_load "${2:-}" ;;
    *)
        echo "Usage:"
        echo "  ./portability.sh save [archive.tar.gz]"
        echo "  ./portability.sh load <archive.tar.gz>"
        exit 1
        ;;
esac
