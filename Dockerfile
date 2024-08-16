FROM mlikiowa/napcat-docker:base

WORKDIR /usr/src/app

COPY NapCat.Shell.zip entrypoint.sh ./
# 设置时区
ENV TZ=Asia/Shanghai 
RUN echo "${TZ}" > /etc/timezone \ 
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \ 
    && apt update \ 
    && apt install -y tzdata \ 
    && rm -rf /var/lib/apt/lists/*

# 安装Linux QQ
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    curl -o linuxqq.deb https://dldir1.qq.com/qqfile/qq/QQNT/2b82dc28/linuxqq_3.2.12-26909_${arch}.deb && \
    dpkg -i --force-depends linuxqq.deb && rm linuxqq.deb && \
    chmod +x entrypoint.sh && \
    echo "(async () => {await import('file:///usr/src/app/napcat/napcat.mjs');})();" > /opt/QQ/resources/app/app_launcher/index.js
VOLUME /usr/src/app/napcat/config
VOLUME /root/.config/QQ

ENTRYPOINT ["bash", "entrypoint.sh"]

