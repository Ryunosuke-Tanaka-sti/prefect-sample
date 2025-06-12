#!/bin/bash

# Prefect環境セットアップスクリプト（オプション）
# 注意: このスクリプトは必須ではありません
# 'docker compose up -d' だけでも完全に動作します

echo "=== Prefect環境のセットアップ（オプション実行） ==="
echo "ℹ️  このスクリプトは必須ではありません"
echo "   'docker compose up -d' を直接実行でも同じ結果が得られます"
echo ""

# 実行確認
read -p "続行しますか？ (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "キャンセルされました"
    echo ""
    echo "💡 代替案:"
    echo "   docker compose up -d  # 直接実行"
    exit 0
fi

# データディレクトリ作成（Docker Composeでも自動作成されますが、明示的に作成）
echo "データディレクトリを準備中..."
mkdir -p prefect/data/downloads

# Docker Composeでサービス起動
echo "Docker Composeでサービスを起動中..."
echo "※ サーバー起動 → デプロイメント自動登録 → エージェント起動の順で処理されます"
docker compose up -d

# 起動状況をモニタリング（オプション）
echo ""
echo "起動状況をモニタリング中..."
echo "（Ctrl+C で中断できます。バックグラウンドで処理は継続されます）"

# サーバーの起動確認
echo ""
echo "1️⃣ Prefect Server起動確認..."
timeout=90
counter=0
while ! curl -s http://localhost:4200/api/health > /dev/null 2>&1; do
    sleep 5
    counter=$((counter + 5))
    if [ $counter -ge $timeout ]; then
        echo "⚠️  Prefect Serverの起動確認がタイムアウトしました"
        echo "   バックグラウンドで起動処理は継続されています"
        echo "   ログ確認: docker compose logs prefect-server"
        break
    fi
    echo "   待機中... (${counter}/${timeout}秒)"
done

if curl -s http://localhost:4200/api/health > /dev/null 2>&1; then
    echo "✅ Prefect Serverが起動しました!"
fi

# デプロイメント登録の確認
echo ""
echo "2️⃣ デプロイメント自動登録確認..."
sleep 5

deployer_status=$(docker compose ps prefect-deployer --format json 2>/dev/null | jq -r '.[0].State // "unknown"' 2>/dev/null || echo "unknown")
if [ "$deployer_status" = "exited" ]; then
    echo "✅ デプロイメント自動登録が完了しました!"
elif [ "$deployer_status" = "running" ]; then
    echo "⏳ デプロイメント登録実行中..."
    timeout=120
    counter=0
    while [ "$(docker compose ps prefect-deployer --format json 2>/dev/null | jq -r '.[0].State // "unknown"' 2>/dev/null || echo "unknown")" = "running" ]; do
        sleep 5
        counter=$((counter + 5))
        if [ $counter -ge $timeout ]; then
            echo "⚠️  デプロイメント登録の確認がタイムアウトしました"
            echo "   バックグラウンドで処理は継続されています"
            echo "   ログ確認: docker compose logs prefect-deployer"
            break
        fi
        echo "   待機中... (${counter}/${timeout}秒)"
    done
    
    final_status=$(docker compose ps prefect-deployer --format json 2>/dev/null | jq -r '.[0].State // "unknown"' 2>/dev/null || echo "unknown")
    if [ "$final_status" = "exited" ]; then
        echo "✅ デプロイメント自動登録が完了しました!"
    fi
else
    echo "⏳ デプロイメント登録はバックグラウンドで実行中です"
    echo "   ログ確認: docker compose logs prefect-deployer"
fi

# エージェント起動確認
echo ""
echo "3️⃣ Prefect Agent起動確認..."
sleep 5

agent_status=$(docker compose ps prefect-agent --format json 2>/dev/null | jq -r '.[0].State // "unknown"' 2>/dev/null || echo "unknown")
if [ "$agent_status" = "running" ]; then
    echo "✅ Prefect Agentが起動しました!"
else
    echo "⏳ Prefect Agentはバックグラウンドで起動中です"
    echo "   ログ確認: docker compose logs prefect-agent"
fi

echo ""
echo "=== セットアップ監視完了 ==="
echo ""
echo "🎉 Prefect環境の起動処理が開始されました!"
echo ""
echo "📊 アクセス情報:"
echo "   Prefect UI: http://localhost:4200"
echo ""
echo "🚀 利用方法:"
echo "   Prefect UIにアクセスして、Deploymentsから実行"
echo "   （デプロイメントの登録完了まで数分かかる場合があります）"
echo ""
echo "🛠 有用なコマンド:"
echo "   docker compose ps                        # サービス状態確認"
echo "   docker compose logs -f prefect-server    # サーバーログ"
echo "   docker compose logs -f prefect-deployer  # デプロイメント登録ログ"
echo "   docker compose logs -f prefect-agent     # エージェントログ"
echo "   docker compose down                      # 環境停止"#!/bin/bash

# Prefect環境セットアップスクリプト

echo "=== Prefect環境のセットアップを開始 ==="

# 権限設定
chmod +x prefect/entrypoint.sh

# データディレクトリ作成
mkdir -p prefect/data/downloads

# Docker Composeでサービス起動
echo "Docker Composeでサービスを起動中..."
docker-compose up -d

# サーバーの起動を待機
echo "Prefect Serverの起動を待機中..."
timeout=60
counter=0
while ! curl -s http://localhost:4200/api/health > /dev/null 2>&1; do
    sleep 5
    counter=$((counter + 5))
    if [ $counter -ge $timeout ]; then
        echo "エラー: Prefect Serverの起動がタイムアウトしました"
        exit 1
    fi
    echo "待機中... (${counter}/${timeout}秒)"
done

echo "Prefect Serverが起動しました!"

# フローの登録
echo "サンプルフローを登録中..."

# CLIコンテナでフローを登録
docker-compose run --rm prefect-cli bash -c "
    cd /opt/prefect && \
    python -m flows.hello_world_flow && \
    python -m flows.create_file_flow && \
    python -m flows.download_file_flow && \
    prefect deployment build flows/hello_world_flow.py:hello_world_flow --name 'Hello World Deployment' --apply && \
    prefect deployment build flows/create_file_flow.py:create_file_flow --name 'Create File Deployment' --apply && \
    prefect deployment build flows/download_file_flow.py:download_file_flow --name 'Download File Deployment' --apply
"

echo ""
echo "=== セットアップ完了 ==="
echo ""
echo "🎉 Prefect環境が正常にセットアップされました!"
echo ""
echo "📊 アクセス情報:"
echo "   Prefect UI: http://localhost:4200"
echo ""
echo "🚀 利用可能なコマンド:"
echo "   docker-compose logs -f prefect-server  # サーバーログ確認"
echo "   docker-compose logs -f prefect-agent   # エージェントログ確認"
echo "   docker-compose run --rm prefect-cli bash  # CLI操作"
echo "   docker-compose down  # 環境停止"
echo ""
echo "📝 登録されたデプロイメント:"
echo "   - Hello World Deployment"
echo "   - Create File Deployment"  
echo "   - Download File Deployment"
echo ""
echo "💡 デプロイメントの実行方法:"
echo "   Prefect UI (http://localhost:4200) からデプロイメントを選択して実行するか、"
echo "   CLI で以下のようにコマンド実行:"
echo "   docker-compose run --rm prefect-cli prefect deployment run 'Hello World Flow/Hello World Deployment'"