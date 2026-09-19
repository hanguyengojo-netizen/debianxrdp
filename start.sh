#!/bin/bash
set -e

mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# Start dbus if available
service dbus start || true

# Start PulseAudio in system mode for XRDP audio
pulseaudio --start --system --disallow-exit --disable-shm || true

# Start XRDP
service xrdp start

# Keep container alive and show useful XRDP logs
tail -F /var/log/xrdp.log /var/log/xrdp-sesman.log
