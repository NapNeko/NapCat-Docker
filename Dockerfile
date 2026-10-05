FROM mlikiowa/napcat-docker:base

RUN useradd --no-log-init -d /app napcat

WORKDIR /app

COPY NapCat.Shell.zip entrypoint.sh templates /app/

# 安装Linux QQ 3.2.32-52194（带重试，外网可能不稳定）
# 腾讯会下架旧版本的下载链接，官方 CDN 下不到时改从 GitHub 上的镜像下载
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    QQ_FILE="QQ_3.2.32_260812_${arch}_01.deb" && \
    for QQ_URL in "https://qqdl.gtimg.cn/qqfile/QQNT/9.9.33/release/3f89efc5/${QQ_FILE}" \
                  "https://github.com/Rodert/qq-versions/releases/download/qq-packages-20260813-1d08f1d4/${QQ_FILE}"; do \
        echo "Downloading QQ from: ${QQ_URL}"; \
        for i in 1 2 3; do \
            curl --retry 3 --retry-delay 5 --connect-timeout 30 --max-time 300 -fL -o linuxqq.deb "${QQ_URL}" && break || \
            (rm -f linuxqq.deb; echo "Attempt $i failed, retrying in 10s..." && sleep 10); \
        done; \
        test -f linuxqq.deb && break; \
    done && \
    test -f linuxqq.deb && dpkg -i --force-depends linuxqq.deb && rm linuxqq.deb

RUN chmod +x entrypoint.sh && \
    echo "(async () => {await import('file:///app/napcat/napcat.mjs');})();" > /opt/QQ/resources/app/loadNapCat.js && \
    sed -i 's|"main": "[^"]*"|"main": "./loadNapCat.js"|' /opt/QQ/resources/app/package.json

VOLUME /app/napcat/config
VOLUME /app/.config/QQ

ENTRYPOINT ["bash", "entrypoint.sh"]

