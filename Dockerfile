ARG BASEIMAGE
ARG BASETAG

# nvidia/cuda:11.6.1-devel-ubuntu22.04

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
	pip3 install $(cat /tmp/pydeps.txt) \
    && rm -rf /tmp/*

RUN \
    mkdir /root/workspace \
    && mkdir -p /root/.cache/whisper \
    && curl -L -O -C - \
        https://openaipublic.azureedge.net/main/whisper/models/e4b87e7e0bf463eb8e6956e646f1e277e901512310def2c24bf0e11bd3c28e9a/large.pt \
        > /root/.cache/whisper/large.pt \
    && curl -L -O -C - \
        https://openaipublic.azureedge.net/main/whisper/models/345ae4da62f9b3d59415adc60127b97c714f32e89e936602e85993674d08dcb1/medium.pt \
        > /root/.cache/whisper/medium.pt \
    && curl -L -O -C - \
        https://openaipublic.azureedge.net/main/whisper/models/9ecf779972d90ba49c06d968637d720dd632c55bbf19d441fb42bf17a411e794/small.pt \
        > /root/.cache/whisper/small.pt \
    && curl -L -O -C - \
        https://openaipublic.azureedge.net/main/whisper/models/65147644a518d12f04e32d6f3b26facc3f8dd46e5390956a9424a650c0ce22b9/tiny.pt \
        > /root/.cache/whisper/tiny.pt \

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

WORKDIR /root/workspace

LABEL title="Whisper-Container"
LABEL version="0.0.1"

CMD [ "/usr/local/bin/entrypoint.sh" ]

# DOCKER_BUILDKIT=1 \
# docker build --no-cache \
# --build-arg BASEIMAGE=nvidia/cuda \
# --build-arg BASETAG=11.6.1-devel-ubuntu22.04 \
# -t kestr3l/whisper-container:0.0.1 \
# -f Dockerfile .

# docker run -it --rm --gpus all \
# -v /home/merlin/test.m4a:/root/workspace/test.m4a \
# kestr3l/whisper-container:0.0.1
