# Microsoft公式のPython devcontainerイメージを使用
FROM mcr.microsoft.com/devcontainers/python:3.11

# 追加のシステムパッケージをインストール（必要に応じて）
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Pythonパッケージのアップグレード
RUN pip install --upgrade pip

# 作業ディレクトリの設定
WORKDIR /workspace