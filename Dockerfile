ARG BASEIMAGE
ARG BASETAG

# nvidia/cuda:11.7.0-devel-ubuntu22.04

FROM ${BASEIMAGE}:${BASETAG} as stage_apt

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN \
    rm -rf /etc/apt/apt.conf.d/docker-clean \
	&& echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache \
	&& apt-get update


FROM ${BASEIMAGE}:${BASETAG} as stage_deps

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

COPY aptdeps.txt /tmp/aptdeps.txt

RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
	apt-get install --no-install-recommends -y $(cat /tmp/aptdeps.txt) \
    && rm -rf /tmp/*


COPY pydeps.txt /tmp/pydeps.txt

RUN \
	python3 -m pip install --user $(cat /tmp/pydeps.txt) \
    && rm -rf /tmp/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

LABEL title="Whisper-Container"
LABEL version="0.0.1"

CMD [ "/usr/local/bin/entrypoint.sh" ]

# DOCKER_BUILDKIT=1 \
# docker build --no-cache \
# -t kestr3l/whisper-container:0.0.1 .