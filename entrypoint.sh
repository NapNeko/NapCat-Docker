#!/bin/bash

trap "" SIGPIPE
# 安装 napcat
if [ ! -f "napcat/napcat.mjs" ]; then
    unzip -q NapCat.Shell.zip -d ./NapCat.Shell
    cp -rf NapCat.Shell/* napcat/
    rm -rf ./NapCat.Shell
fi
if [ ! -f "napcat/config/napcat.json" ]; then
    unzip -q NapCat.Shell.zip -d ./NapCat.Shell
    cp -rf NapCat.Shell/config/* napcat/config/
    rm -rf ./NapCat.Shell
fi

# 配置 WebUI Token
CONFIG_PATH=/app/napcat/config/webui.json

if [ ! -f "${CONFIG_PATH}" ] && [ -n "${WEBUI_TOKEN}" ]; then
    echo "正在配置 WebUI Token..."
    cat > "${CONFIG_PATH}" << EOF
{
    "host": "0.0.0.0",
    "prefix": "${WEBUI_PREFIX}",
    "port": 6099,
    "token": "${WEBUI_TOKEN}",
    "loginRate": 3
}
EOF
fi

# 删除字符串两端的引号
remove_quotes() {
    local str="$1"
    local first_char="${str:0:1}"
    local last_char="${str: -1}"

    if [[ ($first_char == '"' && $last_char == '"') || ($first_char == "'" && $last_char == "'") ]]; then
        # 两端都是双引号
        if [[ $first_char == '"' ]]; then
            str="${str:1:-1}"
        # 两端都是单引号
        else
            str="${str:1:-1}"
        fi
    fi
    echo "$str"
}

if [ -n "${MODE}" ]; then
    cp /app/templates/$MODE.json /app/napcat/config/onebot11.json
fi

rm -rf "/tmp/.X1-lock"

# 删除容器标识
rm -f "/.dockerenv"
rm -f "/.dockerinit"
rm -f "/run/.containerenv"
rm -f "/run/systemd/container"
rm -f "/dev/.dockerenv"

# Name规范
HOSTNAME_VAL="$(hostname)"
if [[ "${HOSTNAME_VAL}" == *docker* || "${HOSTNAME_VAL}" == *container* || "${HOSTNAME_VAL}" == *lxc* ]] \
   || [[ "${HOSTNAME_VAL}" =~ ^[a-f0-9]{12,}$ ]]; then
    hostname "localhost"
    echo "localhost" > /etc/hostname
fi

# cgroup处理
mkdir -p /tmp/fake_cgroup
FAKE_CGROUP_DIR="/tmp/fake_cgroup"
# /proc/self/cgroup 
# /proc/1/cgroup
for cfile in /proc/self/cgroup /proc/1/cgroup; do
    if [ -f "$cfile" ]; then
        FAKE_CG="$FAKE_CGROUP_DIR/cgroup_$(basename $(dirname $cfile))_$(basename $cfile)"
        cat "$cfile" | sed \
            -e 's|/docker/|/system.slice/|g' \
            -e 's|/docker-|/system.slice/|g' \
            -e 's|/lxc/|/system.slice/|g' \
            -e 's|/podmaster|/system.slice/|g' \
            -e 's|/podman/|/system.slice/|g' \
            -e 's|/kubepods/|/system.slice/|g' \
            -e 's|/containerd/|/system.slice/|g' \
            -e 's|/buildkit/|/system.slice/|g' \
            > "$FAKE_CG"
        mount --bind "$FAKE_CG" "$cfile" 2>/dev/null || true
    fi
done

# DMI
for dmi_file in /sys/class/dmi/id/product_name /sys/class/dmi/id/product_uuid /sys/class/dmi/id/sys_vendor /sys/class/dmi/id/board_vendor /sys/class/dmi/id/board_name; do
    if [ -f "$dmi_file" ]; then
        FAKE_DMI="/tmp/fake_cgroup/$(echo $dmi_file | tr '/' '_')"
        case "$(basename $dmi_file)" in
            product_name)  echo "Standard PC" > "$FAKE_DMI" ;;
            product_uuid)  echo "00000000-0000-0000-0000-000000000000" > "$FAKE_DMI" ;;
            sys_vendor|board_vendor) echo "Intel Corporation" > "$FAKE_DMI" ;;
            board_name)    echo "Default string" > "$FAKE_DMI" ;;
        esac
        mount --bind "$FAKE_DMI" "$dmi_file" 2>/dev/null || true
    fi
done

# Docker Socket
if [ -S /var/run/docker.sock ]; then
    mv /var/run/docker.sock /var/run/.docker.sock.hidden 2>/dev/null || true
fi

# Mount Info
for mfile in /proc/self/mountinfo /proc/1/mountinfo; do
    if [ -f "$mfile" ]; then
        FAKE_MOUNT="$FAKE_CGROUP_DIR/mountinfo_$(basename $(dirname $mfile))_$(basename $mfile)"
        cat "$mfile" | sed \
            -e 's|overlay / |ext4 / |g' \
            -e 's|overlay /|ext4 /|g' \
            -e '/docker/d' \
            -e '/containerd/d' \
            -e '/\.dockerenv/d' \
            -e '/cgroup2.*docker/d' \
            > "$FAKE_MOUNT"
        mount --bind "$FAKE_MOUNT" "$mfile" 2>/dev/null || true
    fi
done

# /proc/1/cmdline
if [ -f /proc/1/cmdline ]; then
    FAKE_CMDLINE="$FAKE_CGROUP_DIR/cmdline_1"
    printf '/sbin/init\0' > "$FAKE_CMDLINE"
    mount --bind "$FAKE_CMDLINE" /proc/1/cmdline 2>/dev/null || true
fi

# /proc/1/sched
if [ -f /proc/1/sched ]; then
    FAKE_SCHED="$FAKE_CGROUP_DIR/sched_1"
    head -1 /proc/1/sched | sed 's|([^)]*)|(1, #threads=1)|' > "$FAKE_SCHED"
    tail -n +2 /proc/1/sched >> "$FAKE_SCHED"
    sed -i 's/^[a-zA-Z0-9_-]*\s/systemd /' "$FAKE_SCHED"
    mount --bind "$FAKE_SCHED" /proc/1/sched 2>/dev/null || true
fi

# /proc/1/environ
if [ -f /proc/1/environ ]; then
    FAKE_ENVIRON="$FAKE_CGROUP_DIR/environ_1"
    cat /proc/1/environ | tr '\0' '\n' | \
        grep -v -i 'container=docker\|container=lxc\|container=podman\|container=containerd' | \
        tr '\n' '\0' > "$FAKE_ENVIRON"
    mount --bind "$FAKE_ENVIRON" /proc/1/environ 2>/dev/null || true
fi

# /proc/1/status & /proc/self/status (NSpid)
for sfile in /proc/1/status /proc/self/status; do
    if [ -f "$sfile" ]; then
        FAKE_STATUS="$FAKE_CGROUP_DIR/status_$(basename $(dirname $sfile))_$(basename $sfile)"
        cat "$sfile" | sed 's/^NSpid:.*/NSpid:\t1/' > "$FAKE_STATUS"
        mount --bind "$FAKE_STATUS" "$sfile" 2>/dev/null || true
    fi
done

# /proc/1/stat
if [ -f /proc/1/stat ]; then
    FAKE_STAT="$FAKE_CGROUP_DIR/stat_1"
    cat /proc/1/stat | sed 's/^\([0-9]*\) ([-a-zA-Z0-9_]*)/\1 (systemd)/' > "$FAKE_STAT"
    mount --bind "$FAKE_STAT" /proc/1/stat 2>/dev/null || true
fi

# /etc/hosts
if [ -f /etc/hosts ]; then
    FAKE_HOSTS="$FAKE_CGROUP_DIR/hosts"
    cat /etc/hosts | grep -v "$(hostname)" > "$FAKE_HOSTS" 2>/dev/null
    grep -q '^127\.0\.0\.1.*localhost' "$FAKE_HOSTS" || echo "127.0.0.1\tlocalhost" >> "$FAKE_HOSTS"
    grep -q '^::1.*localhost' "$FAKE_HOSTS" || echo "::1\tlocalhost ip6-localhost ip6-loopback" >> "$FAKE_HOSTS"
    mount --bind "$FAKE_HOSTS" /etc/hosts 2>/dev/null || true
fi

# /sys/hypervisor/type
if [ -f /sys/hypervisor/type ]; then
    FAKE_HYPER="$FAKE_CGROUP_DIR/hypervisor_type"
    echo "" > "$FAKE_HYPER"
    mount --bind "$FAKE_HYPER" /sys/hypervisor/type 2>/dev/null || true
fi

# /proc/self/mounts
if [ -f /proc/self/mounts ]; then
    FAKE_MOUNTS="$FAKE_CGROUP_DIR/mounts_self"
    cat /proc/self/mounts | sed \
        -e 's|overlay / |ext4 / |g' \
        -e 's|overlay /|ext4 /|g' \
        -e '/docker/d' \
        -e '/containerd/d' \
        > "$FAKE_MOUNTS"
    mount --bind "$FAKE_MOUNTS" /proc/self/mounts 2>/dev/null || true
fi

# /proc/self/cpuset
if [ -f /proc/self/cpuset ]; then
    FAKE_CPUSET="$FAKE_CGROUP_DIR/cpuset_self"
    cat /proc/self/cpuset | sed \
        -e 's|/docker/|/|g' \
        -e 's|/docker-[^/]*/|/|g' \
        -e 's|/kubepods/|/|g' \
        -e 's|/containerd/|/|g' \
        > "$FAKE_CPUSET"
    mount --bind "$FAKE_CPUSET" /proc/self/cpuset 2>/dev/null || true
fi

: ${NAPCAT_GID:=0}
: ${NAPCAT_UID:=0}
usermod -o -u ${NAPCAT_UID} napcat
groupmod -o -g ${NAPCAT_GID} napcat
usermod -g ${NAPCAT_GID} napcat
chown -R ${NAPCAT_UID}:${NAPCAT_GID} /app

gosu napcat Xvfb :1 -screen 0 1080x760x16 +extension GLX +render > /dev/null 2>&1 &
sleep 2

export FFMPEG_PATH=/usr/bin/ffmpeg
export DISPLAY=:1
cd /app/napcat
if [ -n "${ACCOUNT}" ]; then
    gosu napcat /opt/QQ/qq --no-sandbox -q $ACCOUNT
else
    gosu napcat /opt/QQ/qq --no-sandbox
fi
