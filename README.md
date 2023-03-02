# OpenAI Whisper Packed in a Docker Container with Model

## 1. Build

- **Build process is not necessary for using a docker container.**
  - You can download a prebuilt image from the [docker hub](https://hub.docker.com/r/kestr3l/whisper-container).
- **If you want to build your own image, you can set `user`\'s password on your own**.
  - Write a password you want for `user` on `deps/auth.txt`.
  - Add `--secret id=auth,src=deps/auth.txt` to the build statement.

```shell
DOCKER_BUILDKIT=1 \
docker build --no-cache \
--build-arg BASEIMAGE=nvidia/cuda \
--build-arg BASETAG=11.7.1-devel-ubuntu22.04 \
--build-arg TAGET_MODEL=large-v2 \
-t kestr3l/whisper-container:0.0.3-large-v2 \
-f Dockerfile .
```

## 2. Run

- Example run script using `large-v2` model

```shell
docker run -it --rm \
-e LANG=LANGUAGE_YOU_WANT \
-v DIR/TO/TARGET/FILES:/home/user/workspace \
--gpus all
kestr3l/whisper-container:0.0.3-large-v2
```

## 3. To-Do List

- Better `entrypoint.sh`
  - Make it to only work on media files on mapped directory
  - Use inotify to watch media files to transcribe
- More settable options using environment variables
- Make gradio WebUI for better usability
- Improved documentations by `README.md`

## 4. References

1. [Install Docker Engine on Ubuntu - docker docs](https://docs.docker.com/engine/install/ubuntu/)
2. [Install the Compose standalone - docker docs](https://docs.docker.com/compose/install/other/)