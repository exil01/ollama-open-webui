#!/usr/bin/env bash

# make sure models dir exists
mkdir -p /app/backend/data/models

# launch Ollama server in background
/bin/ollama serve &

# wait until Ollama is listening on 11434
until (echo > /dev/tcp/localhost/11434) >/dev/null 2>&1; do
  echo "Waiting for Ollama service to start..."
  sleep 1
done

# pull default model if needed
if ! ollama list | grep -q "$DEFAULT_MODEL"; then
  echo "Pulling default model: $DEFAULT_MODEL"
  ollama pull "$DEFAULT_MODEL"
fi

# change to script folder
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd "$SCRIPT_DIR" || exit 1

# secret‑key setup
KEY_FILE=.webui_secret_key
PORT="${PORT:-8080}"

if test "$WEBUI_SECRET_KEY $WEBUI_JWT_SECRET_KEY" = " "; then
  echo "No WEBUI_SECRET_KEY provided"
  if ! [ -e "$KEY_FILE" ]; then
    echo "Generating WEBUI_SECRET_KEY"
    head -c 12 /dev/random | base64 > $KEY_FILE
  fi
  WEBUI_SECRET_KEY=$(cat $KEY_FILE)
  echo "Loaded WEBUI_SECRET_KEY"
fi

# finally launch the FastAPI UI
WEBUI_SECRET_KEY="$WEBUI_SECRET_KEY" \
exec uvicorn main:app --host 0.0.0.0 --port "$PORT" --forwarded-allow-ips '*'
