FROM mlikiowa/napcat-docker:base

RUN useradd --no-log-init -d /app napcat

WORKDIR /app

COPY NapCat.Shell.zip entrypoint.sh templates /app/

# 安装Linux QQ（带重试，外网可能不稳定）
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    QQ_URL="https://dldir1v6.qq.com/qqfile/qq/QQNT/7516007c/linuxqq_3.2.25-45758_${arch}.deb" && \
    echo "Downloading QQ from: ${QQ_URL}" && \
    for i in 1 2 3 4 5; do \
        curl --retry 3 --retry-delay 5 --connect-timeout 30 --max-time 300 -fL -o linuxqq.deb "${QQ_URL}" && break || \
        (echo "Attempt $i failed, retrying in 10s..." && sleep 10); \
    done && \
    test -f linuxqq.deb && dpkg -i --force-depends linuxqq.deb && rm linuxqq.deb

RUN chmod +x entrypoint.sh && \
    echo "(async () => {await import('file:///app/napcat/napcat.mjs');})();" > /opt/QQ/resources/app/loadNapCat.js && \
    sed -i 's|"main": "[^"]*"|"main": "./loadNapCat.js"|' /opt/QQ/resources/app/package.json

VOLUME /app/napcat/config
VOLUME /app/.config/QQ

ENTRYPOINT ["bash", "entrypoint.sh"]

