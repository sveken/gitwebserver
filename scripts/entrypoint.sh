#!/bin/sh
set -e

echo "Starting web server as $(whoami)..."

# Ensure the GIT_REPO environment variable is set.
if [ -z "$GIT_REPO" ]; then
  echo "Error: GIT_REPO environment variable is not set."
  exit 1
fi

# If /web does not contain a git repo, clone it. Otherwise, update it.
if [ ! -d "/web/.git" ]; then
  echo "Cloning repository from $GIT_REPO into /web..."
  git clone "$GIT_REPO" /web
else
  echo "Repository already exists in /web. Pulling latest changes..."
  cd /web && git pull
fi

# Start a background loop to update the repository every hour.
( while true; do
    sleep "$UPDATE_TIMER:-3600"
    echo "Auto-updating repository in /web..."
    cd /web && git pull
  done ) &

echo "Starting Lighttpd..."
exec lighttpd -D -f /etc/lighttpd/lighttpd.conf
