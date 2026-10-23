#!/usr/bin/env bash
set -euo pipefail

image="${1:?Usage: runtime-smoke.sh IMAGE}"

docker run --rm --network none --entrypoint sh "$image" -c '
    set -eu
    test -z "$(dpkg --audit)"
    for package in xdg-utils libglib2.0-0; do
        test "$(dpkg-query -W -f="\${db:Status-Status}" "$package")" = installed
    done
    for package in linux-libc-dev libglib2.0-dev; do
        status=$(dpkg-query -W -f="\${db:Status-Status}" "$package" 2>/dev/null || true)
        test "$status" != installed
    done
    ldd /opt/QQ/qq > /tmp/qq-library-check.txt
    if grep "not found" /tmp/qq-library-check.txt; then exit 1; fi
'

# Disposable anonymous volumes only: no account, config or host socket mounts.
container=$(docker run --rm -d --network none --hostname napcat-ci "$image")
cleanup() {
    docker rm -f "$container" >/dev/null 2>&1 || true
}
trap cleanup EXIT

for ((attempt = 0; attempt < 60; attempt++)); do
    if [ "$(docker inspect --format '{{.State.Running}}' "$container")" != true ]; then
        echo 'Isolated container exited before WebUI startup' >&2
        exit 1
    fi
    status=$(docker exec "$container" curl --max-time 2 -s -o /dev/null \
        -w '%{http_code}' http://127.0.0.1:6099/webui/ || true)
    if [ "$status" = 200 ]; then
        echo 'PASS: package integrity, QQ shared libraries and offline WebUI startup'
        exit 0
    fi
    sleep 1
done

echo 'WebUI startup timeout' >&2
exit 1
