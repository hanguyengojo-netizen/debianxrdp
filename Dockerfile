FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    xrdp \
    xfce4 \
    xfce4-goodies \
    xorg \
    dbus-x11 \
    sudo \
    curl \
    wget \
    nano \
    net-tools \
    policykit-1 \
    pulseaudio \
    pulseaudio-utils \
    wine \
    wine32 \
    firefox-esr && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set root password
RUN echo "root:root" | chpasswd

# Allow Xorg to run from XRDP
RUN if [ -f /etc/X11/Xwrapper.config ]; then \
        sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config; \
    else \
        printf 'allowed_users=anybody\n' > /etc/X11/Xwrapper.config; \
    fi

# XFCE session for root
RUN printf '%s\n' '#!/bin/sh' 'exec startxfce4' > /root/.xsession && \
    chmod 700 /root/.xsession

# Generate machine-id for dbus
RUN mkdir -p /var/lib/dbus /var/run/dbus && \
    if [ ! -s /var/lib/dbus/machine-id ]; then \
        dbus-uuidgen > /var/lib/dbus/machine-id; \
    fi

# XRDP settings
RUN sed -i 's/^crypt_level=.*/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/^security_layer=.*/security_layer=rdp/' /etc/xrdp/xrdp.ini && \
    printf '%s\n' '#!/bin/sh' 'unset DBUS_SESSION_BUS_ADDRESS' 'unset XDG_RUNTIME_DIR' 'exec startxfce4' > /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh && \
    adduser xrdp ssl-cert

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
