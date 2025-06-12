#!/bin/bash

# Prefectデプロイメント登録スクリプト（手動実行用）

echo "=== Prefectデプロイメントの登録を開始 ==="

# Prefect Serverの起動確認
echo "Prefect Serverの稼働確認中..."
if ! curl -s http://localhost:4200/api/health > /dev/null 2>&1; then
    echo "エラー: Prefect Serverが起動していません"
    echo "先に 'docker compose up -d' を実行してください"
    exit 1
fi

echo "Prefect Serverが稼働中です"

# デプロイメント保存ディレクトリ作成
echo "デプロイメント保存ディレクトリを作成中..."
mkdir -p prefect/deployments

# フローのテスト実行
echo ""
echo "フローのテスト実行中..."
docker compose run --rm prefect-cli bash -c "
    cd /opt/prefect && \
    echo 'Hello World Flow テスト:' && \
    python -m flows.hello_world_flow && \
    echo '' && \
    echo 'Create File Flow テスト:' && \
    python -m flows.create_file_flow && \
    echo '' && \
    echo 'Download File Flow テスト:' && \
    python -m flows.download_file_flow
"

# デプロイメントの作成
echo ""
echo "デプロイメントの作成中..."
docker compose run --rm prefect-cli bash -c "
    cd /opt/prefect && \
    
    # deployments ディレクトリ作成
    mkdir -p deployments && \
    
    echo 'Hello World Flow デプロイメント作成:' && \
    prefect deployment build flows/hello_world_flow.py:hello_world_flow \
        --name 'Hello World Deployment' \
        --description 'シンプルなモックワークフロー' \
        --output deployments/hello_world_deployment.yaml \
        --apply && \
    echo '' && \
    
    echo 'Create File Flow デプロイメント作成:' && \
    prefect deployment build flows/create_file_flow.py:create_file_flow \
        --name 'Create File Deployment' \
        --description 'ファイル作成のモックワークフロー' \
        --output deployments/create_file_deployment.yaml \
        --apply && \
    echo '' && \
    
    echo 'Download File Flow デプロイメント作成:' && \
    prefect deployment build flows/download_file_flow.py:download_file_flow \
        --name 'Download File Deployment' \
        --description 'ファイルダウンロードのモックワークフロー' \
        --output deployments/download_file_deployment.yaml \
        --apply && \
    
    echo '' && \
    echo 'デプロイメントファイル一覧:' && \
    ls -la deployments/
"

# デプロイメント一覧表示
echo ""
echo "登録されたデプロイメント一覧:"
docker compose run --rm prefect-cli prefect deployment ls

echo ""
echo "=== デプロイメント登録完了 ==="
echo ""
echo "🎉 すべてのデプロイメントが正常に登録されました!"
echo ""
echo "📁 デプロイメントファイル保存場所:"
echo "   ./prefect/deployments/ (ローカル)"
echo "   /opt/prefect/deployments/ (コンテナ内)"
echo ""
echo "📊 Prefect UI: http://localhost:4200"
echo ""
echo "🚀 デプロイメント実行方法:"
echo "   # UI経由:"
echo "   ブラウザで http://localhost:4200 -> Deployments -> 実行したいデプロイメント選択 -> Run"
echo ""
echo "   # CLI経由:"
echo "   docker compose run --rm prefect-cli prefect deployment run 'Hello World Flow/Hello World Deployment'"
echo "   docker compose run --rm prefect-cli prefect deployment run 'Create File Flow/Create File Deployment'"
echo "   docker compose run --rm prefect-cli prefect deployment run 'Download File Flow/Download File Deployment'"
echo ""
echo "   # API経由:"
echo "   curl -X POST http://localhost:5000/flows/run -H 'Content-Type: application/json' \\"
echo "     -d '{\"flow_name\":\"Hello World Flow\",\"deployment_name\":\"Hello World Deployment\"}'"