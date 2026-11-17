#!/usr/bin/env bash
#
# publish.sh — lädt public/ auf den Server und schaltet die Homepage beim ersten Mal frei.
#
#   ./publish.sh            hochladen (rsync, löscht auf dem Server, was lokal fehlt)
#   ./publish.sh --dry-run  nur anzeigen, was sich ändern würde
#
# Ziel: SSH-Alias learn-hema (~/.ssh/config), Ordner /opt/homepage/public. Caddy liefert ihn
# unter https://learn-hema.de aus (Volume ../homepage/public → /srv/homepage im App-Compose).
# Beim ersten Lauf legt das Skript /opt/hema/deploy/sites/homepage.caddy an und lädt Caddy neu;
# danach genügt das Hochladen, Caddy liest die Dateien bei jedem Aufruf frisch.
#
set -euo pipefail

HOST="${HOST:-learn-hema}"
DEST="/opt/homepage/public"
DOMAIN="${DOMAIN:-learn-hema.de}"
DRY=""
[[ "${1:-}" == "--dry-run" ]] && DRY="--dry-run"

cd "$(dirname "$0")"

# Sicherheitsnetz: keine Entwurfskästen oder Platzhalter veröffentlichen.
if grep -lE 'class="todo"|\{\{[A-Z_]+\}\}' public/*.html; then
  echo "↑ Diese Dateien enthalten noch TODO-Kästen oder {{Platzhalter}}. Abbruch." >&2
  exit 1
fi

ssh "$HOST" "mkdir -p $DEST"
rsync -avz --delete --chmod=D755,F644 $DRY public/ "$HOST:$DEST/"
[[ -n "$DRY" ]] && { echo "(Probelauf, nichts geändert)"; exit 0; }

# Einmalig: Caddy-Block anlegen und Caddy neu laden.
ssh "$HOST" "DOMAIN='$DOMAIN' bash -s" <<'REMOTE'
set -euo pipefail
SITE=/opt/hema/deploy/sites/homepage.caddy
if [[ ! -f "$SITE" ]]; then
  cat > "$SITE" <<EOF
# Homepage — angelegt von homepage/publish.sh
${DOMAIN} {
	import hema_log
	root * /srv/homepage
	file_server
	encode gzip
	header {
		Strict-Transport-Security "max-age=31536000; includeSubDomains"
		X-Content-Type-Options "nosniff"
		X-Frame-Options "SAMEORIGIN"
		Referrer-Policy "strict-origin-when-cross-origin"
		-Server
	}
}

www.${DOMAIN} {
	redir https://${DOMAIN}{uri} permanent
}
EOF
  echo "Caddy-Block angelegt: $SITE"
  cd /opt/hema
  if docker compose ps --status running --services 2>/dev/null | grep -qx caddy; then
    docker compose exec -T caddy caddy reload --config /etc/caddy/Caddyfile
    echo "Caddy neu geladen."
  else
    echo "Caddy läuft noch nicht; der Block wird beim nächsten 'docker compose up -d' aktiv."
  fi
fi
REMOTE

echo "✓ Veröffentlicht: https://$DOMAIN"
