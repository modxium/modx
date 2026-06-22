#!/usr/bin/env sh

set -eu

WEBROOT="${WEBROOT:-/var/www/html}"
APP_GIT_BRANCH="${APP_GIT_BRANCH:-main}"
APP_GIT_CLEAR_CACHE="${APP_GIT_CLEAR_CACHE:-true}"
APP_GIT_ALLOW_PROTECTED_PATHS="${APP_GIT_ALLOW_PROTECTED_PATHS:-false}"

if [ "${APP_GIT_ENABLED:-false}" != "true" ]; then
    echo "Git sync disabled. Set APP_GIT_ENABLED=true to enable."
    exit 0
fi

if [ -z "${APP_GIT_REPO:-}" ]; then
    echo "ERROR: APP_GIT_REPO is required when APP_GIT_ENABLED=true."
    exit 1
fi

mkdir -p "$WEBROOT"
cd "$WEBROOT"

normalise_repo_url() {
    REPO="$1"

    case "$REPO" in
        https://*)
            printf '%s\n' "$REPO"
            ;;
        http://*)
            printf '%s\n' "$REPO"
            ;;
        git@*)
            printf '%s\n' "$REPO"
            ;;
        *)
            printf 'https://%s\n' "$REPO"
            ;;
    esac
}

REPO_URL="$(normalise_repo_url "$APP_GIT_REPO")"

setup_git_auth() {
    if [ -z "${APP_GIT_TOKEN:-}" ]; then
        return 0
    fi

    ASKPASS_FILE="/tmp/modxium-git-askpass.sh"

    cat > "$ASKPASS_FILE" <<'ASKPASS'
#!/usr/bin/env sh
case "$1" in
    *Username*) printf '%s\n' "x-access-token" ;;
    *Password*) printf '%s\n' "$APP_GIT_TOKEN" ;;
    *) printf '\n' ;;
esac
ASKPASS

    chmod 700 "$ASKPASS_FILE"

    export GIT_ASKPASS="$ASKPASS_FILE"
    export GIT_TERMINAL_PROMPT=0
}

ensure_default_gitignore() {
    if [ -f .gitignore ]; then
        return 0
    fi

    cat > .gitignore <<'GITIGNORE'
# MODX core/runtime folders
/core/
/manager/
/connectors/
/setup/

# Runtime assets/uploads
/assets/*
!/assets/.gitkeep

# MODX config/cache
/core/config/config.inc.php
/core/cache/

# Git webhook endpoint copied by the container
/git-webhook.php
GITIGNORE
}

ensure_git_repo() {
    if [ ! -d .git ]; then
        echo "Initialising Git repository in $WEBROOT..."
        git init >/dev/null
    fi

    git config --global --add safe.directory "$WEBROOT" >/dev/null 2>&1 || true

    if git remote get-url origin >/dev/null 2>&1; then
        git remote set-url origin "$REPO_URL"
    else
        git remote add origin "$REPO_URL"
    fi
}

check_protected_paths() {
    if [ "$APP_GIT_ALLOW_PROTECTED_PATHS" = "true" ]; then
        return 0
    fi

    PROTECTED_MATCHES="$(git ls-tree -r --name-only "origin/${APP_GIT_BRANCH}" 2>/dev/null | grep -E '^(core|manager|connectors|setup|assets)/' || true)"

    if [ -n "$PROTECTED_MATCHES" ]; then
        echo "ERROR: The Git branch contains protected MODX/runtime paths:"
        echo "$PROTECTED_MATCHES"
        echo ""
        echo "Remove these paths from the repo, or set APP_GIT_ALLOW_PROTECTED_PATHS=true to override."
        exit 1
    fi
}

clear_modx_cache() {
    if [ "$APP_GIT_CLEAR_CACHE" != "true" ]; then
        return 0
    fi

    if [ -d "$WEBROOT/core/cache" ]; then
        echo "Clearing MODX cache..."
        find "$WEBROOT/core/cache" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
    fi
}

LOCK_DIR="/tmp/modxium-git-sync.lock"

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    echo "Another Git sync is already running."
    exit 1
fi

cleanup() {
    rm -rf "$LOCK_DIR" /tmp/modxium-git-askpass.sh 2>/dev/null || true
}
trap cleanup EXIT INT TERM

echo ""
echo "===================================================="
echo "              MODXIUM GIT SYNC"
echo "===================================================="
echo ""
echo "Webroot: $WEBROOT"
echo "Branch:  $APP_GIT_BRANCH"
echo "Repo:    $REPO_URL"
echo ""

setup_git_auth
ensure_default_gitignore
ensure_git_repo

echo "Fetching latest changes..."
git fetch --prune origin "$APP_GIT_BRANCH"

check_protected_paths

BEFORE="$(git rev-parse --short HEAD 2>/dev/null || true)"

echo "Applying origin/${APP_GIT_BRANCH}..."
git reset --hard "origin/${APP_GIT_BRANCH}"

AFTER="$(git rev-parse --short HEAD 2>/dev/null || true)"

clear_modx_cache

chown -R www-data:www-data "$WEBROOT" 2>/dev/null || true

echo ""
echo "Git sync complete."
echo "Before: ${BEFORE:-none}"
echo "After:  ${AFTER:-unknown}"
echo ""
echo "===================================================="
echo ""
