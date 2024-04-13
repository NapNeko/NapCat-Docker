FROM initialencounter/napcat:base

COPY NapCat.linux.zip /tmp/NapCat.linux.zip
COPY config.txt entrypoint.sh /root/

# 安装Linux QQ
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    curl -o /root/linuxqq.deb https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.7_240410_{arch}_01.deb && \
    ls -lh /root && \
    dpkg -i --force-depends /root/linuxqq.deb && rm /root/linuxqq.deb && \

    # 安装 napcat
    unzip /tmp/NapCat.linux.zip -d /root/ && \
    rm /tmp/NapCat.linux.zip && \

    chmod +x /root/napcat.sh && \
    chmod +x /root/entrypoint.sh && \

    echo "[supervisord]" > /etc/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisord.conf && \
    echo "[program:napcat]" >> /etc/supervisord.conf && \
    echo "command=COMMAND" >> /etc/supervisord.conf

WORKDIR "/root"

ENTRYPOINT ["/root/entrypoint.sh"]

