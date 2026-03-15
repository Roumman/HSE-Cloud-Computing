# Устанавливает Plex Media Server на Debian‑систему с логированием, проверяет наличие уже установленной версии (идемпотентность), настраивает зависимости и права доступа к директории медиабиблиотеки (/media/movies)

#!/usr/bin/env bash
# Plex Media Server install script (idempotent).
# Run as root, e.g. from cloud-init.

set -euo pipefail

readonly LOG_FILE="/var/log/plex-install.log"
readonly PLEX_VERSION="1.42.2.10156-f737b826c"
readonly PLEX_DEB="plexmediaserver_${PLEX_VERSION}_amd64.deb"
readonly PLEX_URL="https://downloads.plex.tv/plex-media-server-new/${PLEX_VERSION}/debian/${PLEX_DEB}"
readonly LIBRARY_DIR="/media/movies"

log() {
  echo "[$(date -Iseconds)] $*" | tee -a "$LOG_FILE"
}

log "Plex install script started."

if dpkg -l plexmediaserver &>/dev/null; then
  log "Plex is already installed, skipping."
  mkdir -p "$LIBRARY_DIR"
  chown -R plex:plex "$LIBRARY_DIR"
  chmod -R 755 "$LIBRARY_DIR"
  log "Done (idempotent)."
  exit 0
fi

log "Installing dependencies."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq curl ca-certificates

log "Downloading Plex ${PLEX_VERSION}."
tmp_dir="$(mktemp -d)"
trap "rm -rf ${tmp_dir}" EXIT
curl -fsSL -o "${tmp_dir}/${PLEX_DEB}" "$PLEX_URL"

log "Installing Plex package."
dpkg -i "${tmp_dir}/${PLEX_DEB}" || true
apt-get install -f -y -qq
dpkg -i "${tmp_dir}/${PLEX_DEB}"

log "Creating library directory and setting permissions."
mkdir -p "$LIBRARY_DIR"
chown -R plex:plex "$LIBRARY_DIR"
chmod -R 755 "$LIBRARY_DIR"

log "Plex install finished successfully."
