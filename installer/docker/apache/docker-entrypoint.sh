#!/usr/bin/env sh

set -e

WEBROOT="/var/www/html"
HTTP_PORT="${HTTP_PORT:-8080}"

if [ -z "${MODX_VERSION:-}" ]; then
    echo "ERROR: MODX_VERSION is required."
    exit 1
fi

install_htaccess_files() {

    echo "Checking MODX ht.access files..."

    HTACCESS_FILES="
${WEBROOT}/ht.access
${WEBROOT}/core/ht.access
${WEBROOT}/manager/ht.access
"

    for SOURCE in $HTACCESS_FILES; do

        TARGET="$(dirname "$SOURCE")/.htaccess"

        if [ -f "$TARGET" ]; then
            continue
        fi

        if [ -f "$SOURCE" ]; then
            mv "$SOURCE" "$TARGET"
            echo "✔ $(dirname "$SOURCE")/.htaccess"
        fi

    done

}

if [ -f "${WEBROOT}/core/config/config.inc.php" ]; then
    echo "MODX is already installed in ${WEBROOT}. Skipping download."
    install_htaccess_files
    exec "$@"
fi

if [ -f "${WEBROOT}/setup/index.php" ] || [ -f "${WEBROOT}/index.php" ]; then
    echo "MODX files already exist in ${WEBROOT}. Skipping download."
    install_htaccess_files
    exec "$@"
fi

MODX_DOWNLOAD_URL="https://modx.com/download/direct/modx-${MODX_VERSION}.zip"

echo "MODX Download URL: ${MODX_DOWNLOAD_URL}"

rm -rf /tmp/modx-download /tmp/modx.zip
mkdir -p /tmp/modx-download

MAX_ATTEMPTS=3
ATTEMPT=1
DOWNLOAD_SUCCESS=0

while [ "$ATTEMPT" -le "$MAX_ATTEMPTS" ]; do
    echo "Downloading MODX ${MODX_VERSION} (attempt ${ATTEMPT}/${MAX_ATTEMPTS})..."

    if curl -fsSL "${MODX_DOWNLOAD_URL}" -o /tmp/modx.zip; then
        DOWNLOAD_SUCCESS=1
        break
    fi

    ATTEMPT=$((ATTEMPT + 1))

    if [ "$ATTEMPT" -le "$MAX_ATTEMPTS" ]; then
        echo "Download failed. Retrying..."
        sleep 2
    fi
done

if [ "$DOWNLOAD_SUCCESS" -ne 1 ]; then
    echo ""
    echo "===================================================="
    echo "ERROR"
    echo "===================================================="
    echo ""
    echo "Failed to download MODX ${MODX_VERSION} after ${MAX_ATTEMPTS} attempts."
    echo "Please check that the MODX_VERSION value is valid."
    echo ""
    echo "===================================================="
    exit 1
fi

echo "Extracting MODX..."
unzip -q /tmp/modx.zip -d /tmp/modx-download

MODX_DIR="$(find /tmp/modx-download -mindepth 1 -maxdepth 1 -type d | head -n 1)"

if [ -z "$MODX_DIR" ]; then
    echo "ERROR: Could not find extracted MODX directory."
    exit 1
fi

echo "Copying MODX files to ${WEBROOT}..."
cp -a "${MODX_DIR}/." "${WEBROOT}/"

install_htaccess_files

chown -R www-data:www-data "${WEBROOT}"

rm -rf /tmp/modx-download /tmp/modx.zip

get_public_ip() {
    curl -fsS --max-time 2 https://api.ipify.org 2>/dev/null || true
}

get_install_url() {
    PUBLIC_IP="$(get_public_ip)"

    if [ -n "$PUBLIC_IP" ]; then
        echo "http://${PUBLIC_IP}:${HTTP_PORT}"
        return
    fi

    echo "http://localhost:${HTTP_PORT}"
}

INSTALL_URL="$(get_install_url)"

echo ""
echo "===================================================="
echo "              MODXIUM INSTALLER"
echo "===================================================="
echo ""
echo "✔ MODX ${MODX_VERSION} downloaded and extracted."
echo ""
echo "Your MODX Installer is now ready."
echo ""
echo "Depending on your environment and whether you're using a reverse proxy"
echo "(such as Coolify, Caddy or Nginx Proxy Manager), you can access it here:"
echo ""
echo "-    http://localhost:${HTTP_PORT}/setup"
echo "-    ${INSTALL_URL}/setup"
echo "-    https://<YOUR_DOMAIN>/setup"
echo ""
echo "Happy MODXing!"
echo ""
echo "===================================================="
echo ""

exec "$@"