FROM lsiobase/cloud9:files as builder
FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# add files from c9base
COPY --from=builder /buildout/ /

RUN \
 echo "**** install base packages ****" && \
 apt-get update && \
 apt-get install -y --no-install-recommends \
	curl \
	git \
	gnupg \
	sudo && \
 echo "**** Cleanup and user perms ****" && \
 usermod -aG sudo \
	abc && \
 apt-get autoclean && \
 rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8000
VOLUME /code
