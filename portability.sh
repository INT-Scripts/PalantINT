#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# PalantINT — Portability Script
# Transfer database + assets between machines.
#
# Usage:
#   ./portability.sh save [archive_name.tar.gz]   # Export everything
#   ./portability.sh load [archive_name.tar.gz]    # Import everything
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
DATA_DIR="$PROJECT_DIR/data"
DEFAULT_ARCHIVE="palantint-transfer-$(date +%Y%m%d-%H%M%S).tar.gz"
DB_CONTAINER_NAME=""  # Will be detected automatically

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
err()   { echo -e "${RED}[ERR]${NC}   $*" >&2; }

# ── Detect the running Postgres container ────────────────────────────────────
detect_db_container() {
    DB_CONTAINER_NAME=$(docker compose ps --format '{{.Name}}' 2>/dev/null | grep -i db || true)
    if [ -z "$DB_CONTAINER_NAME" ]; then
        # Fallback: try any postgres container
        DB_CONTAINER_NAME=$(docker ps --format '{{.Names}}' | grep -i postgres | head -1 || true)
    fi
}

# ── SAVE ─────────────────────────────────────────────────────────────────────
do_save() {
    local archive="${1:-$DEFAULT_ARCHIVE}"
    local tmp_dir
    tmp_dir=$(mktemp -d)
    
    info "Starting PalantINT export..."
    echo ""

    # 1. Database dump
    detect_db_container
    if [ -n "$DB_CONTAINER_NAME" ]; then
        info "Dumping PostgreSQL from container: $DB_CONTAINER_NAME"
        docker exec "$DB_CONTAINER_NAME" \
            pg_dump -U postgres -d palantint --clean --if-exists \
            > "$tmp_dir/database.sql" 2>/dev/null
        ok "Database dump: $(du -sh "$tmp_dir/database.sql" | cut -f1)"
    else
        warn "No running Postgres container found. Skipping DB dump."
        warn "Start the stack first: docker compose up -d db"
        echo ""
        read -rp "Continue without database? [y/N] " ans
        if [[ ! "$ans" =~ ^[Yy]$ ]]; then
            rm -rf "$tmp_dir"
            exit 1
        fi
    fi

    # 2. Assets & scraps
    if [ -d "$DATA_DIR" ]; then
        info "Copying data/ directory..."
        cp -r "$DATA_DIR" "$tmp_dir/data"
        ok "Data directory: $(du -sh "$tmp_dir/data" | cut -f1)"
    else
        warn "No data/ directory found. Skipping."
    fi

    # 3. Create archive
    info "Creating archive: $archive"
    tar -czf "$archive" -C "$tmp_dir" .
    rm -rf "$tmp_dir"

    echo ""
    ok "Export complete!"
    echo ""
    info "Archive: $(realpath "$archive")"
    info "Size:    $(du -sh "$archive" | cut -f1)"
    echo ""
    info "Transfer this file to the other machine, then run:"
    echo "  ./portability.sh load $archive"
}

# ── LOAD ─────────────────────────────────────────────────────────────────────
do_load() {
    local archive="${1:-}"
    
    if [ -z "$archive" ] || [ ! -f "$archive" ]; then
        err "Usage: ./portability.sh load <archive.tar.gz>"
        exit 1
    fi

    local tmp_dir
    tmp_dir=$(mktemp -d)
    
    info "Starting PalantINT import from: $archive"
    echo ""

    # 1. Extract
    info "Extracting archive..."
    tar -xzf "$archive" -C "$tmp_dir"
    ok "Extracted."

    # 2. Restore data/
    if [ -d "$tmp_dir/data" ]; then
        info "Restoring data/ directory..."
        if [ -d "$DATA_DIR" ]; then
            warn "Existing data/ found. Backing up to data.bak/"
            mv "$DATA_DIR" "$PROJECT_DIR/data.bak.$(date +%s)"
        fi
        mv "$tmp_dir/data" "$DATA_DIR"
        ok "Data restored: $(du -sh "$DATA_DIR" | cut -f1)"
    else
        warn "No data/ in archive. Skipping."
    fi

    # 3. Restore database
    if [ -f "$tmp_dir/database.sql" ]; then
        info "Restoring PostgreSQL database..."
        
        detect_db_container
        if [ -z "$DB_CONTAINER_NAME" ]; then
            warn "No running Postgres container. Starting stack..."
            docker compose up -d db
            info "Waiting for Postgres to be ready..."
            sleep 5
            detect_db_container
        fi

        if [ -n "$DB_CONTAINER_NAME" ]; then
            docker exec -i "$DB_CONTAINER_NAME" \
                psql -U postgres -d palantint \
                < "$tmp_dir/database.sql" > /dev/null 2>&1
            ok "Database restored."
        else
            err "Could not find Postgres container. Import the SQL manually:"
            err "  docker exec -i <container> psql -U postgres -d palantint < database.sql"
        fi
    else
        warn "No database.sql in archive. Skipping DB restore."
    fi

    rm -rf "$tmp_dir"

    echo ""
    ok "Import complete!"
    info "You can now start the stack: docker compose up --watch"
}

# ── CLI ──────────────────────────────────────────────────────────────────────
case "${1:-}" in
    save)
        do_save "${2:-}"
        ;;
    load)
        do_load "${2:-}"
        ;;
    *)
        echo ""
        echo "PalantINT Portability Tool"
        echo ""
        echo "Usage:"
        echo "  ./portability.sh save [archive.tar.gz]    Export DB + assets"
        echo "  ./portability.sh load <archive.tar.gz>    Import DB + assets"
        echo ""
        echo "What gets transferred:"
        echo "  • PostgreSQL database dump (all tables)"
        echo "  • data/assets/profiles/   (student photos)"
        echo "  • data/assets/plans/      (processed SVG maps)"
        echo "  • data/assets/media/      (user-uploaded content)"
        echo "  • data/scraps/            (raw JSON scraps, input SVGs)"
        echo ""
        exit 1
        ;;
esac
