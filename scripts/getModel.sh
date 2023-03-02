#! /bin/bash

MODEL_DIRECTORY=/home/user/.cache/whisper
echo "DOWNLOADING A GIVEN MODEL..."

if [ "x$TARGET_MODEL" == "xlarge" ] || [ "x$TARGET_MODEL" == "xlarge-v2" ] || [ -z ${TARGET_MODEL+x} ]; then
    curl -L -o ${MODEL_DIRECTORY}/large-v2.pt \
        https://openaipublic.azureedge.net/main/whisper/models/81f7c96c852ee8fc832187b0132e569d6c3065a3252ed18e56effd0b6a73e524/large-v2.pt
elif [ "x$TARGET_MODEL" == "xlarge-v1" ]; then
    curl -L -o ${MODEL_DIRECTORY}/large-v1.pt \
        https://openaipublic.azureedge.net/main/whisper/models/e4b87e7e0bf463eb8e6956e646f1e277e901512310def2c24bf0e11bd3c28e9a/large-v1.pt
elif [ "x$TARGET_MODEL" == "xmedium" ]; then
    curl -L -o ${MODEL_DIRECTORY}/medium.pt \
        https://openaipublic.azureedge.net/main/whisper/models/345ae4da62f9b3d59415adc60127b97c714f32e89e936602e85993674d08dcb1/medium.pt
elif [ "x$TARGET_MODEL" == "xmedium.en" ]; then
    curl -L -o ${MODEL_DIRECTORY}/medium.en.pt  \
        https://openaipublic.azureedge.net/main/whisper/models/d7440d1dc186f76616474e0ff0b3b6b879abc9d1a4926b7adfa41db2d497ab4f/medium.en.pt 
elif [ "x$TARGET_MODEL" == "xsmall" ]; then
    curl -L -o ${MODEL_DIRECTORY}/small.pt \
        https://openaipublic.azureedge.net/main/whisper/models/9ecf779972d90ba49c06d968637d720dd632c55bbf19d441fb42bf17a411e794/small.pt
elif [ "x$TARGET_MODEL" == "xsmall.en" ]; then
    curl -L -o ${MODEL_DIRECTORY}/small.en.pt \
        https://openaipublic.azureedge.net/main/whisper/models/f953ad0fd29cacd07d5a9eda5624af0f6bcf2258be67c92b79389873d91e0872/small.en.pt
elif [ "x$TARGET_MODEL" == "xbase" ]; then
    curl -L -o ${MODEL_DIRECTORY}/base.pt \
        https://openaipublic.azureedge.net/main/whisper/models/ed3a0b6b1c0edf879ad9b11b1af5a0e6ab5db9205f891f668f8b0e6c6326e34e/base.pt
elif [ "x$TARGET_MODEL" == "xbase.en" ]; then
    curl -L -o ${MODEL_DIRECTORY}/base.en.pt \
        https://openaipublic.azureedge.net/main/whisper/models/25a8566e1d0c1e2231d1c762132cd20e0f96a85d16145c3a00adf5d1ac670ead/base.en.pt
elif [ "x$TARGET_MODEL" == "xtiny" ]; then
    curl -L -o ${MODEL_DIRECTORY}/tiny.pt \
        https://openaipublic.azureedge.net/main/whisper/models/65147644a518d12f04e32d6f3b26facc3f8dd46e5390956a9424a650c0ce22b9/tiny.pt
elif [ "x$TARGET_MODEL" == "xtiny.en" ]; then
    curl -L -o ${MODEL_DIRECTORY}/tiny.en.pt \
        https://openaipublic.azureedge.net/main/whisper/models/d3dd57d32accea0b295c96e26691aa14d8822fac7d9d27d5dc00b4ca2826dd03/tiny.en.pt
else
    echo "TARGET_MODEL: $TARGET_MODEL"
    echo "ERROR, PLEASE ALLOCATE APPROPRIATE MODEL NAME"
    exit 1
fi