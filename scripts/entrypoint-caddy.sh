#!/bin/sh
set -e

echo "Starting Caddy-based webserver..."

# Ensure the GIT_REPO environment variable is set.
if [ -z "$GIT_REPO" ]; then
  echo "Error: GIT_REPO environment variable is not set. Exiting."
  exit 1
fi

# Create the website directory.
mkdir -p /web

# If a PAT is provided, modify the GIT_REPO URL accordingly.
if [ -n "$GIT_PAT" ]; then
  echo "Using GitHub Personal Access Token for authentication..."
  if echo "$GIT_REPO" | grep -q "^https://"; then
    GIT_REPO="https://${GIT_PAT}@${GIT_REPO#https://}"
  else
    echo "Error: When using GIT_PAT, GIT_REPO must be an HTTPS URL."
    exit 1
  fi
fi

# Clone or update the repository.
if [ ! -d "/web/.git" ]; then
  echo "Cloning repository: $GIT_REPO"
  git clone --depth=1 "$GIT_REPO" /web
else
  echo "Repository already cloned, updating..."
  cd /web && git pull
fi

# Ensure that the DOMAIN environment variable is provided.
if [ -z "$DOMAIN" ]; then
  echo "Error: DOMAIN environment variable is not set."
  exit 1
fi

# Create a dynamic Caddyfile with auto HTTPS enabled.
cat <<EOF > /etc/caddy/Caddyfile
$DOMAIN {
    root * /web
    file_server

    # Block access to the .git folder
    @denyGit {
        path_regexp ^/\.git
    }
    handle @denyGit {
        respond "Access Denied" 403
    }
}
EOF

echo "Generated Caddyfile:"
cat /etc/caddy/Caddyfile

# Optionally, set up a background loop to auto-update the repository.
if [ -n "$UPDATE_TIMER" ]; then
  (
    while true; do
      sleep "${UPDATE_TIMER}"
      echo "Auto-updating repository in /web..."
      cd /web && git pull
    done
  ) &
fi

echo "Starting Caddy..."
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
