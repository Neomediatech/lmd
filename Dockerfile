FROM clamav/clamav:latest_base

# LMD release pinned by version + sha256 (bump both to upgrade)
ARG LMD_VERSION=2.0.1
ARG LMD_SHA256=26674c72208a4c32ae4ed8770a2b5c036b35c0894a4812450df11c5a53d7d8e5
ENV LMD_VERSION=${LMD_VERSION} \
    SERVICE=lmd

LABEL maintainer="docker-dario@neomediatech.it" \
      org.opencontainers.image.title="lmd" \
      org.opencontainers.image.description="Linux Malware Detect (LMD) with ClamAV, on Alpine" \
      org.opencontainers.image.version="${LMD_VERSION}" \
      org.opencontainers.image.source="https://github.com/Neomediatech/lmd" \
      org.label-schema.version="${LMD_VERSION}" \
      org.label-schema.vcs-type=Git \
      org.label-schema.vcs-url="https://github.com/Neomediatech/lmd" \
      org.label-schema.maintainer=Neomediatech

# LMD 2.x no longer needs perl; GNU grep/sed/awk are required by its scan engine
RUN apk add --no-cache bash curl ca-certificates coreutils findutils util-linux \
        grep sed gawk procps inotify-tools bind-tools && \
    mkdir /tmp/lmd-src && cd /tmp/lmd-src && \
    curl -fsSL -o lmd.tar.gz \
        "https://github.com/rfxn/linux-malware-detect/releases/download/v${LMD_VERSION}/maldet-${LMD_VERSION}.tar.gz" && \
    echo "${LMD_SHA256}  lmd.tar.gz" | sha256sum -c - && \
    tar -xzf lmd.tar.gz && \
    cd maldet-* && \
    bash install.sh && \
    cd / && rm -rf /tmp/lmd-src && \
    mkdir -p /var/run/clamav && \
    chown clamav:clamav /var/run/clamav && \
    BASE_URL="https://raw.githubusercontent.com/extremeshok/clamav-unofficial-sigs/master" && \
    curl --fail --show-error --location --output /clamav-unofficial-sigs.sh -- ${BASE_URL}/clamav-unofficial-sigs.sh && \
    chmod +x /clamav-unofficial-sigs.sh && \
    mkdir -p /etc/clamav-unofficial-sigs /usr/local/sbin && \
    cd /etc/clamav-unofficial-sigs && \
    curl --fail --show-error --location --output master.conf -- ${BASE_URL}/config/master.conf && \
    curl --fail --show-error --location --output user.conf   -- ${BASE_URL}/config/user.conf

COPY conf/os.conf /etc/clamav-unofficial-sigs/
COPY bin/entrypoint-lmd2.sh /entrypoint.sh

# In a container LMD scans mounted dirs, often owned by root: do not skip root-owned files
RUN chmod +x /entrypoint.sh && \
    sed -i 's/^scan_ignore_root=.*/scan_ignore_root="0"/' /usr/local/maldetect/conf.maldet

ENTRYPOINT ["/entrypoint.sh"]
