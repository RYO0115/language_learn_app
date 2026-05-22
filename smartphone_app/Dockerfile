FROM ubuntu:22.04

# Flutter バージョン（git tag に対応）
ARG FLUTTER_VERSION=3.22.3

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Tokyo \
    FLUTTER_HOME=/opt/flutter \
    ANDROID_HOME=/opt/android-sdk \
    ANDROID_SDK_ROOT=/opt/android-sdk

ENV PATH="${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}"

# ── システム依存パッケージ ──────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl git unzip xz-utils zip wget ca-certificates \
    openjdk-17-jdk \
    libglu1-mesa clang cmake ninja-build \
    pkg-config libgtk-3-dev liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

# ── Flutter ──────────────────────────────────────────────────────────────────
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} \
        https://github.com/flutter/flutter.git ${FLUTTER_HOME} && \
    flutter config --no-analytics && \
    # Android 以外のプラットフォームキャッシュはスキップ
    flutter precache --no-ios --no-macos --no-web \
                     --no-linux --no-windows --no-fuchsia

# ── Android Command-line Tools ───────────────────────────────────────────────
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    wget -q "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" \
        -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d /tmp/ct && \
    mv /tmp/ct/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
    rm -rf /tmp/cmdline-tools.zip /tmp/ct

# ── Android SDK コンポーネント ────────────────────────────────────────────────
RUN yes | sdkmanager --licenses 2>/dev/null && \
    sdkmanager \
        "platform-tools" \
        "platforms;android-34" \
        "build-tools;34.0.0"

RUN flutter config --android-sdk ${ANDROID_HOME}

# ── pub キャッシュのデフォルト場所を固定 ─────────────────────────────────────
ENV PUB_CACHE=/root/.pub-cache

WORKDIR /app

CMD ["bash"]
