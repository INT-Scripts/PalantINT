#!/usr/bin/env bash
set -e

cat <<EOF > .env
# PalantINT Environment Variables

# ── Campus CAS Credentials (Scrapers & Ingest Pipeline) ─────────────────────
CAS_USERNAME=
CAS_PASSWORD=

# ── Database ────────────────────────────────────────────────────────────────
POSTGRES_DB=palantint
POSTGRES_USER=postgres
POSTGRES_PASSWORD=$(openssl rand -hex 24)

# ── Backend Security ────────────────────────────────────────────────────────
# Secret key used for JWT signing.
SECRET_KEY=$(openssl rand -hex 48)

# MCP Configuration (Internal credentials for AI agent tool access)
MCP_SERVICE_TOKEN=$(openssl rand -hex 24)
EOF

echo ".env file generated successfully!"
