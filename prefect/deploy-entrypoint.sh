#!/bin/bash

# Prefect自動デプロイメント登録スクリプト

echo "=== 自動デプロイメント登録を開始 ==="

# 必要なパッケージのインストール
install_packages() {
    echo "必要なパッケージをインストール中..."
    apt-get update -qq > /dev/null 2>&1
    apt-get install -y curl jq > /dev/null 2>&1
    echo "パッケージインストール完了"
}

# Prefect Serverの起動を待機
wait_for_server() {
    echo "Prefect Serverの起動を待機中..."
    max_attempts=30
    attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s http://prefect-server:4200/api/health > /dev/null 2>&1; then
            echo "Prefect Serverが利用可能になりました"
            return 0
        fi
        
        attempt=$((attempt + 1))
        echo "待機中... (${attempt}/${max_attempts})"
        sleep 10
    done
    
    echo "エラー: Prefect Serverの起動待機がタイムアウトしました"
    exit 1
}

# Prefect設定
setup_prefect() {
    echo "Prefectの設定中..."
    
    # API URLの設定
    prefect config set PREFECT_API_URL="http://prefect-server:4200/api"
    
    # ワークプールの作成（エラーを無視）
    prefect work-pool create --type process default 2>/dev/null || true
    
    # デプロイメント保存用ディレクトリ作成
    mkdir -p /opt/prefect/deployments
    
    echo "Prefectの設定が完了しました"
}

# フローのテスト実行
test_flows() {
    echo "フローのテスト実行中..."
    
    cd /opt/prefect
    
    # echo "-> Hello World Flow テスト"
    # python -m flows.hello_world_flow || {
    #     echo "警告: Hello World Flow のテスト実行に失敗しました"
    # }

    echo "-> Create Data Flow テスト"
    python -m flows.create_data_flow || {
        echo "警告: Create Data Flow のテスト実行に失敗しました"
    }
    
    # echo "-> Download File Flow テスト"
    # python -m flows.download_file_flow || {
    #     echo "警告: Download File Flow のテスト実行に失敗しました"
    # }

    echo "-> Get Data Flow テスト"
    python -m flows.get_data_flow || {
        echo "警告: Get Data Flow のテスト実行に失敗しました"
    }
    
    
    echo "フローテストが完了しました"
}

# デプロイメントの作成
create_deployments() {
    echo "デプロイメントの作成中..."
    
    cd /opt/prefect
    
    # # Hello World Flow
    # echo "-> Hello World Flow デプロイメント作成"
    # prefect deployment build flows/hello_world_flow.py:hello_world_flow \
    #     --name "Hello World Deployment" \
    #     --description "シンプルなモックワークフロー" \
    #     --version "1.0.0" \
    #     --pool "default" \
    #     --output deployments/hello_world_deployment.yaml \
    #     --apply || {
    #     echo "エラー: Hello World Deployment の作成に失敗しました"
    #     exit 1
    # }
    

    # Create Data Flow  
    echo "-> Create Data Flow デプロイメント作成"
    prefect deployment build flows/create_data_flow.py:create_data_flow \
        --name "Create Data Deployment" \
        --description "データ作成のモックワークフロー" \
        --version "1.0.0" \
        --pool "default" \
        --output deployments/create_data_flow_deployment.yaml \
        --apply || {
        echo "エラー: Create Data Deployment の作成に失敗しました"
        exit 1
    }
    
    
    # # Download File Flow
    # echo "-> Download File Flow デプロイメント作成"
    # prefect deployment build flows/download_file_flow.py:download_file_flow \
    #     --name "Download File Deployment" \
    #     --description "ファイルダウンロードのモックワークフロー" \
    #     --version "1.0.0" \
    #     --pool "default" \
    #     --output deployments/download_file_deployment.yaml \
    #     --apply || {
    #     echo "エラー: Download File Deployment の作成に失敗しました"
    #     exit 1
    # }

    # Get Data Flow  
    echo "-> Get Data Flow デプロイメント作成"
    prefect deployment build flows/get_data_flow.py:get_data_flow \
        --name "Get Data Deployment" \
        --description "データ作成のモックワークフロー" \
        --version "1.0.0" \
        --pool "default" \
        --output deployments/get_data_flow_deployment.yaml \
        --apply || {
        echo "エラー: Get Data Deployment の作成に失敗しました"
        exit 1
    }

    
    echo "すべてのデプロイメントが作成されました"
    echo "デプロイメントファイル保存場所: /opt/prefect/deployments/"
}

# デプロイメント一覧表示
show_deployments() {
    echo "登録されたデプロイメント一覧:"
    prefect deployment ls || {
        echo "警告: デプロイメント一覧の取得に失敗しました"
    }
    
    echo ""
    echo "作成されたデプロイメントファイル:"
    ls -la /opt/prefect/deployments/ || {
        echo "警告: デプロイメントファイル一覧の取得に失敗しました"
    }
    
    echo ""
    echo "デプロイメント詳細確認:"
    for yaml_file in /opt/prefect/deployments/*.yaml; do
        if [ -f "$yaml_file" ]; then
            echo "=== $(basename $yaml_file) ==="
            if command -v yq >/dev/null 2>&1; then
                yq eval '.flow_name, .name, .version' "$yaml_file" 2>/dev/null || grep -E "(flow_name|name|version):" "$yaml_file"
            else
                grep -E "(flow_name|name|version):" "$yaml_file"
            fi
            echo ""
        fi
    done
}

# メイン処理
main() {
    install_packages
    wait_for_server
    setup_prefect
    test_flows
    create_deployments
    show_deployments
    
    echo ""
    echo "=== 自動デプロイメント登録完了 ==="
    echo ""
    echo "🎉 すべてのデプロイメントが自動で登録されました!"
    echo ""
    echo "📊 Prefect UI: http://localhost:4200"
    echo ""
    echo "🚀 利用可能なデプロイメント:"
    echo "   - Create Data Flow/Create Data Deployment"
    echo "   - Get Data Flow/Get Data Deployment"
    echo ""
    echo "📁 デプロイメントファイル保存場所:"
    echo "   /opt/prefect/deployments/ (ローカル: ./prefect/deployments/)"
    echo ""
    echo "💡 Agentも自動で起動され、ワークフローを実行する準備が整いました"
}

# スクリプト実行
main