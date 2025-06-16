#!/bin/bash

# Prefect環境設定用のエントリーポイントスクリプト

# パッケージインストール（必要に応じて）
install_packages() {
    echo "必要なパッケージをインストール中..."
    apt-get update -qq > /dev/null 2>&1
    apt-get install -y curl jq > /dev/null 2>&1
    echo "パッケージインストール完了"
}

# APIの設定を待機
wait_for_server() {
    echo "Prefect Serverの起動を待機中..."
    while ! curl -s http://prefect-server:4200/api/health > /dev/null 2>&1; do
        sleep 5
    done
    echo "Prefect Serverが利用可能になりました"
}

# 初期設定
setup_prefect() {
    echo "Prefectの初期設定を実行中..."
    
    # API URLの設定
    prefect config set PREFECT_API_URL="http://prefect-server:4200/api"
    
    # ワークプールの作成（エラーを無視）
    prefect work-pool create --type process default 2>/dev/null || true
    
    echo "Prefectの設定が完了しました"
}

# メイン処理
case "$1" in
    "prefect")
        case "$2" in
            "server")
                # パッケージインストール
                install_packages
                echo "Prefect Serverを起動中..."
                exec "$@"
                ;;
            "agent")
                # パッケージインストール
                install_packages
                wait_for_server
                setup_prefect
                echo "Prefect Agentを起動中..."
                exec "$@"
                ;;
            *)
                # パッケージインストール
                install_packages
                wait_for_server
                setup_prefect
                exec "$@"
                ;;
        esac
        ;;
    *)
        # パッケージインストール
        install_packages
        exec "$@"
        ;;
esac