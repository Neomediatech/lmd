FROM neomediatech/ubuntu-base:20.04 

ENV VERSION=1.6.4 \
    SERVICE=lmd

LABEL maintainer="docker-dario@neomediatech.it" \ 
      org.label-schema.version=$VERSION \
      org.label-schema.vcs-type=Git \
      org.label-schema.vcs-url=https://github.com/Neomediatech/${SERVICE} \
      org.label-schema.maintainer=Neomediatech

RUN apt-get update && apt-get -y dist-upgrade && \
    apt-get install -y --no-install-recommends curl bash perl wget ca-certificates bsdmainutils vim-tiny \
    clamav clamav-daemon clamdscan && \
    curl http://www.rfxn.com/downloads/maldetect-current.tar.gz | tar -xz && \
    DIR=$(find -iname 'maldet*' | awk -F '/' '{print $2}' | head -1) && \
    cd $DIR && \
    bash install.sh && \
    cd .. && \
    rm -rf $DIR && \
    mkdir -p /var/run/clamav && \
    chown clamav:clamav /var/run/clamav && \
    rm -rf /var/lib/apt/lists* 

COPY bin/entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
