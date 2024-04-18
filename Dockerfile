FROM mlikiowa/napcat-docker:base

WORKDIR /usr/src/app

COPY NapCat.linux.zip NapCat.linux.zip
COPY config.txt entrypoint.sh ./

# 安装Linux QQ
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    curl -o /root/linuxqq.deb https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.7_240410_${arch}_01.deb && \
    dpkg -i --force-depends /root/linuxqq.deb && rm /root/linuxqq.deb

# 安装 napcat
RUN unzip NapCat.linux.zip && \
    rm NapCat.linux.zip && \
    chmod +x napcat.sh && \
    chmod +x entrypoint.sh

# 配置 supervisord
RUN echo "[supervisord]" > /etc/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisord.conf && \
    echo "[program:napcat]" >> /etc/supervisord.conf && \
    echo "command=COMMAND" >> /etc/supervisord.conf

ENTRYPOINT ["sh", "entrypoint.sh"]

