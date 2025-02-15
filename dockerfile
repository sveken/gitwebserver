FROM debian:bookworm-slim AS builder
ENV DEBIAN_FRONTEND=noninteractive

# Install Git and Lighttpd (only what is needed at runtime)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    lighttpd \
    && rm -rf /var/lib/apt/lists/*

# Stage 2: Final Runtime Image :D
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive

# We make the user we want to use in the container.
RUN useradd -m container

# Copy the Git and Lighttpd binaries from the builder stage so we only have what we neeed.

COPY --from=builder /usr/bin/git /usr/bin/git
COPY --from=builder /usr/sbin/lighttpd /usr/sbin/lighttpd

# Create a directory for the website files and ensure the container user owns it.
RUN mkdir /web && chown container:container /web

# Copy the Lighttpd configuration file. This is set to port 8080 already. 
COPY debscripts/lighttpd.conf /etc/lighttpd/lighttpd.conf

# Copy the entrypoint script.
COPY debscripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown container:container /entrypoint.sh



# Switch to our none root user.
USER container

# Set the containers entrypoint.
ENTRYPOINT ["/entrypoint.sh"]
