#!/bin/bash
set -e  # エラーで停止

echo "=== デバッグ情報 ==="
echo "現在のディレクトリ: $(pwd)"
echo "ファイル一覧:"
ls -la

# jqとcurlのインストール
if ! command -v jq &> /dev/null || ! command -v curl &> /dev/null; then
    echo "jqとcurlが必要です。インストールします..."
    apt-get update -qq > /dev/null 2>&1
    apt-get install -y jq curl > /dev/null 2>&1
    echo "インストール完了"
else
    echo "jqとcurlは既にインストールされています"
fi

echo "=== prefectディレクトリの確認 ==="
if [ -d "prefect" ]; then
    echo "prefectディレクトリが見つかりました"
    cd prefect
    echo "prefectディレクトリ内:"
    ls -la
    
    # 既存の仮想環境をチェック
    if [ -d ".venv" ]; then
        echo "既存の仮想環境が見つかりました。スキップします。"
        source .venv/bin/activate
    else
        echo "=== 仮想環境の作成 ==="
        python -m venv .venv
        source .venv/bin/activate
        
        echo "=== pipのアップグレード ==="
        pip install --upgrade pip
    fi
    
    echo "=== pipのアップグレード ==="
    pip install --upgrade pip
    
    echo "=== requirements.txtの確認 ==="
    if [ -f "requirements.txt" ]; then
        echo "requirements.txtが見つかりました"
        pip install -r requirements.txt
    else
        echo "requirements.txtが見つかりません"
        echo "ファイル一覧:"
        ls -la
    fi
else
    echo "エラー: prefectディレクトリが見つかりません"
    echo "利用可能なディレクトリ:"
    ls -la
    exit 1
fi