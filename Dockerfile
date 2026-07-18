# ============================================================
# Cloud Android Runner - Dockerfile
# Multi-stage build for a lightweight Android Docker image
# ============================================================
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_VERSION=${ANDROID_VERSION:-14}

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    openjdk-17-jdk \
    python3 \
    python3-pip \
    curl \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/android-sdk/cmdline-tools && \
    cd /opt/android-sdk/cmdline-tools && \
    wget -q "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" -O tools.zip && \
    unzip -q tools.zip && \
    mv cmdline-tools latest && \
    rm tools.zip

ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

RUN yes | sdkmanager --licenses > /dev/null 2>&1 || true && \
    sdkmanager --install \
        "platform-tools" \
        "platforms;android-34" \
        "build-tools;34.0.0" \
        "system-images;android-34;google_apis;arm64-v8a" \
    | grep -v "^\[" || true

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
ENV DISPLAY=:0
ENV SCREEN_WIDTH=${SCREEN_WIDTH:-1080}
ENV SCREEN_HEIGHT=${SCREEN_HEIGHT:-1920}

RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jre-headless \
    curl \
    wget \
    unzip \
    locales \
    xfvb \
    xvfb \
    fluxbox \
    x11vnc \
    novnc \
    python3 \
    python3-numpy \
    adb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

COPY --from=builder /opt/android-sdk /opt/android-sdk
COPY --from=builder /usr/bin/python3 /usr/bin/python3

RUN mkdir -p /opt/android-runtime /workspace
WORKDIR /workspace

COPY entrypoint.sh /opt/android-runtime/entrypoint.sh
RUN chmod +x /opt/android-runtime/entrypoint.sh

EXPOSE 6080 5555

ENTRYPOINT ["/opt/android-runtime/entrypoint.sh"]
