# Use the upstream Open‑WebUI image
FROM ghcr.io/open-webui/open-webui:latest

# Switch to root so we can apt‑install
USER root

# Install git (and clean up)
RUN apt-get update \
 && apt-get install -y git \
 && rm -rf /var/lib/apt/lists/*

# Pull in only the ollama CLI binary (so we don't overwrite glibc)
COPY --from=ollama/ollama:latest /bin/ollama /bin/ollama

WORKDIR /app/backend

# Copy your start script and make it executable
COPY start.sh ./
RUN chmod +x start.sh \
    # create an empty git repo so GitPython Repo(".") works
 && git init --initial-branch=main .

# Expose the WebUI port
EXPOSE 8080

# Launch
CMD ["./start.sh"]
