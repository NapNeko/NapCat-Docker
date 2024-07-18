FROM mlikiowa/napcat-docker:base

WORKDIR /usr/src/app
RUN wget https://github.com/NapNeko/NapCatQQ/releases/latest/download/NapCat.linux.x64.zip && \
    wget https://github.com/NapNeko/NapCatQQ/releases/latest/download/NapCat.linux.arm64.zip

#COPY NapCat.linux.arm64.zip NapCat.linux.x64.zip entrypoint.sh .
COPY entrypoint.sh .
# 安装Linux QQ
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    curl -o linuxqq.deb https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.10_25765_${arch}_01.deb && \
    dpkg -i --force-depends linuxqq.deb && rm linuxqq.deb && \
    chmod +x entrypoint.sh
VOLUME /usr/src/app/napcat/config
VOLUME /root/.config/QQ

ENTRYPOINT ["bash", "entrypoint.sh"]
