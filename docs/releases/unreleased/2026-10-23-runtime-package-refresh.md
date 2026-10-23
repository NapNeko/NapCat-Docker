---
type: fix
scope: runtime
audience: developer
summary: Refresh Ubuntu packages in release images and omit unused development headers
breaking: false
demo_ready: false
tests:
  - "docker buildx build --platform linux/amd64 --load -t local/napcat-upstream-base:20261023 base: passed"
  - "docker buildx build --platform linux/amd64 --load -t local/napcat-upstream:20261023-lf .: passed"
  - "bash tests/runtime-smoke.sh local/napcat-upstream:20261023-lf: passed"
  - "Trivy 0.76.1, database updated 2026-10-23: 0 Critical / 0 High in the final image"
  - "bash -n tests/runtime-smoke.sh and git diff --check: passed"
artifacts:
  - Dockerfile
  - base/Dockerfile
  - tests/runtime-smoke.sh
  - README.md
---

## What changed

The final image refreshes installed Ubuntu packages before installing QQ, installs QQ's declared `xdg-utils` dependency, and removes unused kernel/development headers inherited from older base images. The base recipe uses the GLib runtime package instead of its development package. The README documents `--pull --no-cache` for security rebuilds so they pick up available package updates even when the application archive is unchanged; release automation must invoke those options when rebuilding a cached application archive.

## Why it matters

The application and its separately published base have different update cadences. A new application release could otherwise retain old system packages and unused development headers. This applies package maintenance to the final artifact while keeping the current QQ version, entrypoint, environment variables and persistent directories unchanged. It does not treat system package updates as a fix for an embedded Electron/Node vulnerability.

## Demo posture / limitations

Linux amd64 builds passed for both the fresh base and the final image built from the existing published base. The final image is `sha256:36706fc67f0d2b52f918bdfa5d9821e74901017f913ae4bf906f9cd0844839f7`; the fresh base is `sha256:2955d405688b60b671facba26555e41c41c6e5c94b1156cf3e1749ebcab0e661`. Validation used the public NapCat `v4.18.41` archive (SHA-256 `6801f93e533846cea05f4f531874a0e84371ab2331c5585b57cd7e3b869cf96b`) and the Dockerfile's existing QQ `3.2.34-53644` download. Both images have the required runtime packages and no installed `linux-libc-dev` or `libglib2.0-dev`; the final image passed package audit, QQ shared-library resolution and no-network WebUI startup (HTTP 200).

Trivy's database timestamp was `2026-10-23T01:18:09Z`. It reported no High/Critical findings in 446 OS packages and the detected Node package metadata; this is scanner coverage, not proof that every component in the QQ/Electron executable is fixed. Arm64 builds, real QQ login, messaging, plugins, reconnect behavior and Electron sandboxing remain separate checks. No account/configuration directory was mounted for testing, and the tests removed only their own disposable containers. This source change has not published an upstream image or changed a deployed service.
