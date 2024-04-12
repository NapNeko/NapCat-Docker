FROM initialencounter/napcat:base

COPY NapCat.linux.x64.zip /tmp/NapCat.linux.x64.zip
COPY config.txt entrypoint.sh /root/

# 安装Linux QQ
RUN curl -o /root/linuxqq.deb https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.7_240410_amd64_01.deb && \
    dpkg -i --force-depends /root/linuxqq.deb && rm /root/linuxqq.deb && \

    # 安装 napcat
    unzip /tmp/NapCat.linux.x64.zip -d /root/ && \
    rm /tmp/NapCat.linux.x64.zip && \

    chmod +x /root/napcat.sh && \
    chmod +x /root/entrypoint.sh && \

    echo "[supervisord]" > /etc/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisord.conf && \
    echo "[program:napcat]" >> /etc/supervisord.conf && \
    echo "command=COMMAND" >> /etc/supervisord.conf

WORKDIR "/root"

ENTRYPOINT ["/root/entrypoint.sh"]

