#!/bin/sh
set -e

echo "Starting Caddy-based webserver..."

# If a Git repository is provided, clone or update the website files.
if [ -n "$GIT_REPO" ]; then
  # Ensure /web exists (it was created in Dockerfile, but for safety)
  mkdir -p /web
  if [ ! -d "/web/.git" ]; then
    echo "Cloning repository: $GIT_REPO"
    git clone --depth=1 "$GIT_REPO" /web
  else
    echo "Repository already cloned, updating..."
    cd /web && git pull
  fi
fi

# Check that the required DOMAIN variable is set.
if [ -z "$DOMAIN" ]; then
  echo "Error: DOMAIN environment variable is not set."
  exit 1
fi

# Create a dynamic Caddyfile with https.
cat <<EOF > /etc/caddy/Caddyfile
$DOMAIN {
    root * /web
    file_server
    # Caddy auto-manages HTTPS certificates for valid public domains.
}
EOF

echo "Generated Caddyfile:"
cat /etc/caddy/Caddyfile

# Set update timer, default is 1 hour.
if [ -n "${UPDATE_TIMER:-3600}" ]; then
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
