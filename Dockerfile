# 使用最新的Alpine基础镜像
FROM alpine:latest

# 设置构建参数和环境变量
ARG TARGETARCH
ARG SING_BOX_VERSION=1.13.12

ENV TARGETARCH=${TARGETARCH} \
    SING_BOX_VERSION=${SING_BOX_VERSION} \
    TZ=Asia/Shanghai

# 安装必要的工具和库
RUN apk update && \
    apk add --no-cache ca-certificates wget bash coreutils grep gawk tzdata libc6-compat libgcc && \
    rm -rf /var/cache/apk/* && \
    echo "TARGETARCH=${TARGETARCH}" && \
    which wget

# 下载并安装sing-box
RUN mkdir -p /tmp/sing-box && \
    cd /tmp/sing-box && \
    echo "Downloading sing-box for ${TARGETARCH}..." && \
    SING_BOX_URL="https://github.com/SagerNet/sing-box/releases/download/v${SING_BOX_VERSION}/sing-box-${SING_BOX_VERSION}-linux-${TARGETARCH}.tar.gz" && \
    echo "URL: ${SING_BOX_URL}" && \
    wget -q "${SING_BOX_URL}" -O sing-box.tar.gz && \
    tar -xzf sing-box.tar.gz && \
    find . -name "sing-box" -type f -exec cp {} /usr/local/bin/sing-box \; && \
    chmod +x /usr/local/bin/sing-box && \
    /usr/local/bin/sing-box version && \
    rm -rf /tmp/sing-box

# 下载并安装cloudflared
RUN mkdir -p /tmp/cloudflared && \
    cd /tmp/cloudflared && \
    echo "Downloading cloudflared for ${TARGETARCH}..." && \
    CLOUDFLARED_URL="https://github.com/cloudflare/cloudflared/releases/download/2026.5.0/cloudflared-linux-${TARGETARCH}" && \
    echo "URL: ${CLOUDFLARED_URL}" && \
    wget -q "${CLOUDFLARED_URL}" -O cloudflared && \
    chmod +x cloudflared && \
    cp cloudflared /usr/local/bin/ && \
    /usr/local/bin/cloudflared --version && \
    rm -rf /tmp/cloudflared

# 设置工作目录
WORKDIR /app

# 复制启动脚本
COPY init.sh .

# 给启动脚本添加执行权限
RUN chmod +x init.sh

# 设置入口点
ENTRYPOINT ["/bin/bash", "./init.sh"]
