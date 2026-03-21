FROM node:24.14.0

# 手动写入阿里云 Debian bookworm 源（使用传统 sources.list 格式）
RUN echo "deb https://mirrors.aliyun.com/debian/ bookworm main non-free non-free-firmware" > /etc/apt/sources.list && \
    echo "deb https://mirrors.aliyun.com/debian-security/ bookworm-security main non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.aliyun.com/debian/ bookworm-updates main non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.aliyun.com/debian/ bookworm-backports main non-free non-free-firmware" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y git python3 python3-dev python3-pip python3-venv build-essential && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip && \
    rm -rf /var/lib/apt/lists/*

RUN npm config set registry https://registry.npmmirror.com && \
    npm install -g openclaw@latest

VOLUME /data
EXPOSE 3000 8080 18789
CMD ["openclaw", "gateway"]

# sudo docker build -t openclaw-dev .