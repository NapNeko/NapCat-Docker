FROM mlikiowa/napcat-docker:base

WORKDIR /usr/src/app

COPY NapCat.linux.arm64.zip NapCat.linux.x64.zip entrypoint.sh .

# 安装Linux QQ
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    curl -o linuxqq.deb https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.10_240715_${arch}_01.deb && \
    dpkg -i --force-depends linuxqq.deb && rm linuxqq.deb && \
    chmod +x entrypoint.sh && \
    sed -i "1i\(async () => {await import('file:///usr/src/app/napcat//napcat/napcat.mjs');})();" /opt/QQ/resources/app/app_launcher/index.js && \
VOLUME /usr/src/app/napcat/config
VOLUME /root/.config/QQ

ENTRYPOINT ["bash", "entrypoint.sh"]

