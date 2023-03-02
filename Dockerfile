# Build Arguments
## BASEIMAGE   : Base image for the build
## BASETAG     : Tag of base image for the build
ARG BASEIMAGE
ARG BASETAG

# ----->>>>> STAGE FOR CACHING APT PACKAGE LIST <<<<<-----
FROM ${BASEIMAGE}:${BASETAG} as stage_apt

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# SET LOCALE AND MAKE SHELL TO BE NONINTERACTIVE
ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# UPDATE APT REPOSITORY CACHE FOR USE IN LATER STAGES
RUN \
    rm -rf /etc/apt/apt.conf.d/docker-clean \
	&& echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache \
	&& apt-get update


# ----->>>>> STAGE FOR INSTALLING APT & PYTHON DEPENDENCIES <<<<<-----
FROM ${BASEIMAGE}:${BASETAG} as stage_deps

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# COPY LIST OF DEPENDENCIES AVAILABLE FROM APT
COPY deps/aptdeps.txt /tmp/aptdeps.txt

# INSTALL APT DEPENDENCIES USING CACHE OF stage_apt
RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
	apt-get install --no-install-recommends -y $(cat /tmp/aptdeps.txt) \
    && rm -rf /tmp/*

# COPY LIST OF DEPENDENCIES AVAILABLE FROM PIP
COPY deps/pydeps.txt /tmp/pydeps.txt

# INSTALL PYTHON DEPENDENCIES
RUN \
	pip3 install $(cat /tmp/pydeps.txt) \
    && rm -rf /tmp/*

# ADD NON-ROOT USER user FOR RUNNING THE WHISPER
RUN \
    groupadd user \
    && useradd -ms /bin/zsh user -g user \
    && usermod -a -G sudo user

# UNCOMMENT TO SET YOUR PASSWORD FOR user
## YOU ALSO NEED TO PLACE auth.txt UNDER deps DIRECTORY
## THEN, ADD FOLLOWING STATEMENT FOR THE BUILD COMMAND:
## --secret id=auth,src=deps/auth.txt
# RUN \
#     --mount=type=secret,id=auth,uid=1000,required \
#     echo "user:$(cat /run/secrets/auth)" | chpasswd

# SET user AND /home/user AS DEFAULT RUNNING TAGET
USER user
WORKDIR /home/user


# ----->>>>> STAGE FOR BUILDING APPLICATION CONTAINER <<<<<-----
FROM stage_deps as stage_app

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Build Argument
## TARGET_MODEL : TARGET OPENAI WHISPER MODEL TO DOWNLOAD
## CHECK https://github.com/openai/whisper/blob/main/whisper/__init__.py
ARG TARGET_MODEL

ENV \
    DEBIAN_FRONTEND=noninteractive \
    FORCE_CUDA=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    LD_LIBRARY_PATH=/usr/local/cuda-11.7/lib64:$LD_LIBRARY_PATH \
    PATH=/usr/local/cuda-11.7/bin:$PATH \
    TORCH_CUDA_ARCH_LIST="6.0;6.1;6.2;7.0;7.2;7.5;8.0;8.6"

# COPY MODEL DOWNLOADER WITH PROPER PERMISSION AND OWNERSHIP
COPY --chmod=775 --chown=user:sudo scripts/getModel.sh /tmp/getModel.sh

# MAKE DIRECTORY FOR WHISPER MODELS AND DOWNLOAD A TARGET MODEL
RUN \
    mkdir /home/user/workspace \
    && mkdir -p /home/user/.cache/whisper \
    && /tmp/getModel.sh \
    && rm -rf /tmp/*

# COPY ENTRYPOINT WITH PROPER PERMISSION AND OWNERSHIP
COPY --chmod=775 --chown=user:sudo scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

# SET DEFAULT DIRCTORY AS /home/user/workspace
WORKDIR /home/user/workspace

# APPLY LABELS TO THIS CONTAINER IMAGE
LABEL title="Whisper-Container"
LABEL version="0.0.3"
LABEL description="Dockerized OpenAI Whisper container image"

# SET INTIALIZATION SCRIPT AS DEFAULT CMD
CMD [ "/usr/local/bin/entrypoint.sh" ]

# ---------- BUILD COMMAND ----------
# DOCKER_BUILDKIT=1 \
# docker build --no-cache \
# --build-arg BASEIMAGE=nvidia/cuda \
# --build-arg BASETAG=11.7.1-devel-ubuntu22.04 \
# --build-arg TARGET_MODEL=large-v2 \
# -t kestr3l/whisper-container:0.0.3-large-v2 \
# -f Dockerfile .

# ----------- RUN COMMAND -----------
# docker run -it --rm \
# -e LANG=LANGUAGE_YOU_WANT \
# -v DIR/TO/TARGET/FILES:/home/user/workspace \
# --gpus all \
# kestr3l/whisper-container:0.0.3-large-v2


# docker run -it --rm \
# -e LANG=ja \
# -v /home/merlin/gitcodes/whisper-container/test:/home/user/workspace \
# --gpus all \
# kestr3l/whisper-container:0.0.3-large-v2