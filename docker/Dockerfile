# Lightweight "doorbell device" image: Alpine + Asterisk
FROM alpine:3.20

# Install Asterisk + needed extras (no heavy DBs, no web UI)
RUN apk add --no-cache \
    asterisk \
    asterisk-sounds-en \
    asterisk-sounds-moh \
    bash \
    tcpdump \
    tzdata

# Create runtime dirs and ensure asterisk user can write
RUN mkdir -p /var/spool/asterisk/monitor \
             /var/spool/asterisk/voicemail \
             /var/log/asterisk \
    && chown -R asterisk:asterisk /var/spool/asterisk /var/log/asterisk /etc/asterisk

# Copy configuration (overlay)
COPY configs/ /etc/asterisk/

# Copy sounds (greetings/prompts)
COPY sounds/ /var/lib/asterisk/sounds/

# Copy entrypoint
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# SIP + RTP media ports
EXPOSE 5060/udp 5060/tcp 10000-10100/udp

# Run as asterisk user
USER asterisk

ENTRYPOINT ["/entrypoint.sh"]