FROM mlikiowa/napcat-docker:base

RUN useradd --no-log-init -d /app napcat

WORKDIR /app

COPY NapCat.Shell.zip entrypoint.sh /app/
COPY qqnt.json /app/

# 安装Linux QQ
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    curl -o linuxqq.deb https://dldir1.qq.com/qqfile/qq/QQNT/0256c948/linuxqq_3.2.12-28418_${arch}.deb && \
    dpkg -i --force-depends linuxqq.deb && rm linuxqq.deb && \
    chmod +x entrypoint.sh && \
    rm -rf /opt/QQ/resources/app/package.json && \
    echo "(async () => {await import('file:///app/napcat/napcat.mjs');})();" > /opt/QQ/resources/app/loadNapCat.js && \
    mv /app/qqnt.json /opt/QQ/resources/app/package.json

VOLUME /app/napcat/config
VOLUME /app/.config/QQ

ENTRYPOINT ["bash", "entrypoint.sh"]

