FROM nvidia/cuda:13.0.0-cudnn-devel-ubuntu24.04

COPY ./clash /clash

RUN apt-get update && apt-get install -y \
		python3  \
        python3-dev \
        git \
        ffmpeg \
        python3.12-venv \
        curl

EXPOSE 8188
