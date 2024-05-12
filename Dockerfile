FROM mlikiowa/napcat-docker:base

WORKDIR /usr/src/app

COPY NapCat.linux.arm64.zip NapCat.linux.x64.zip entrypoint.sh .

# 安装Linux QQ
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    curl -o linuxqq.deb https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.7_240428_${arch}_01.deb && \
    dpkg -i --force-depends linuxqq.deb && rm linuxqq.deb

# 安装 napcat
RUN rarch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/x64/) && \
    unzip NapCat.linux.${rarch}.zip -d . && \
    mv NapCat.linux.${rarch} napcat && \
    chmod +x napcat/napcat.sh && \
    chmod +x entrypoint.sh

# 配置 supervisord
RUN echo "[supervisord]" > /etc/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisord.conf && \
    echo "[program:napcat]" >> /etc/supervisord.conf && \
    echo "command=COMMAND" >> /etc/supervisord.conf

ENTRYPOINT ["bash", "entrypoint.sh"]

