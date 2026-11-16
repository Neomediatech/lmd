FROM clamav/clamav:latest_base

LABEL maintainer="docker-dario@neomediatech.it" \
      org.opencontainers.image.title="lmd" \
      org.opencontainers.image.description="Linux Malware Detect (LMD) with ClamAV, on Alpine" \
      org.opencontainers.image.source="https://github.com/Neomediatech/lmd" \
      org.label-schema.vcs-type=Git \
      org.label-schema.vcs-url="https://github.com/Neomediatech/lmd" \
      org.label-schema.maintainer=Neomediatech

# No versions to bump: LMD and clamav-unofficial-sigs are resolved to their latest GitHub release at build time.
# LMD 2.x does not need perl; GNU grep/sed/awk are required by its scan engine; rsync+gnupg by unofficial-sigs.
RUN apk add --no-cache bash curl jq ca-certificates coreutils findutils util-linux \
        grep sed gawk procps inotify-tools bind-tools rsync gnupg && \
    mkdir /tmp/lmd-src && cd /tmp/lmd-src && \
    curl -fsSL https://api.github.com/repos/rfxn/linux-malware-detect/releases/latest -o release.json && \
    LMD_URL=$(jq -r '.assets[] | select(.name | test("^maldet-.*\\.tar\\.gz$")) | .browser_download_url' release.json | head -n1) && \
    LMD_SHA256=$(jq -r '.assets[] | select(.name | test("^maldet-.*\\.tar\\.gz$")) | .digest' release.json | head -n1 | sed 's/^sha256://') && \
    test -n "$LMD_URL" && test -n "$LMD_SHA256" && \
    curl -fsSL -o lmd.tar.gz "$LMD_URL" && \
    echo "${LMD_SHA256}  lmd.tar.gz" | sha256sum -c - && \
    tar -xzf lmd.tar.gz && \
    cd maldet-* && \
    bash install.sh && \
    cd / && rm -rf /tmp/lmd-src && \
    mkdir -p /var/run/clamav && \
    chown clamav:clamav /var/run/clamav && \
    UNOFF_REF=$(curl -fsSL https://api.github.com/repos/extremeshok/clamav-unofficial-sigs/releases/latest | jq -r '.tag_name // empty' || true) && \
    BASE_URL="https://raw.githubusercontent.com/extremeshok/clamav-unofficial-sigs/${UNOFF_REF:-master}" && \
    curl --fail --show-error --location --output /clamav-unofficial-sigs.sh -- ${BASE_URL}/clamav-unofficial-sigs.sh && \
    chmod +x /clamav-unofficial-sigs.sh && \
    mkdir -p /etc/clamav-unofficial-sigs /usr/local/sbin && \
    curl --fail --show-error --location --output /etc/clamav-unofficial-sigs/master.conf -- ${BASE_URL}/config/master.conf

COPY conf/unofficial-sigs.user.conf /etc/clamav-unofficial-sigs/user.conf
COPY conf/os.conf /etc/clamav-unofficial-sigs/
COPY bin/entrypoint-lmd2.sh /entrypoint.sh

# In a container LMD scans mounted dirs, often owned by root: do not skip root-owned files
RUN chmod +x /entrypoint.sh && \
    sed -i 's/^scan_ignore_root=.*/scan_ignore_root="0"/' /usr/local/maldetect/conf.maldet

ENTRYPOINT ["/entrypoint.sh"]
