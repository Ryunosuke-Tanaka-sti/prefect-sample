#!/bin/bash

# jqとcurlのインストール
if ! command -v jq &> /dev/null || ! command -v curl &> /dev/null; then
    echo "jqとcurlが必要です。インストールします..."
    apt-get update -qq > /dev/null 2>&1
    apt-get install -y jq curl > /dev/null 2>&1
    echo "インストール完了"
fi

# 設定
PREFECT_API_URL="http://prefect-server:4200/api"

FLOW_NAME="Create Data Flow"
DEPLOYMENT_NAME="Create Data Deployment"

# デプロイメントID取得
get_deployment_id() {
    local response=$(curl -s -X POST "${PREFECT_API_URL}/deployments/filter" \
        -H "Content-Type: application/json" \
        -d '{
            "deployments": {"name": {"any_": ["'"$DEPLOYMENT_NAME"'"]}},
            "flows": {"name": {"any_": ["'"$FLOW_NAME"'"]}}
        }')
    
    echo "$response" | jq -r '.[0].id // empty'
}

# フロー実行
run_deployment() {
    local deployment_id=$1
    
    curl -s -X POST "${PREFECT_API_URL}/deployments/${deployment_id}/create_flow_run" \
        -H "Content-Type: application/json" \
        -d '{}' | jq -r '.id'
}

# メイン処理
echo "デプロイメントID取得中..."
DEPLOYMENT_ID=$(get_deployment_id)

if [ -z "$DEPLOYMENT_ID" ]; then
    echo "デプロイメントが見つかりません"
    exit 1
fi

echo "デプロイメントID: $DEPLOYMENT_ID"

echo "フロー実行中..."
FLOW_RUN_ID=$(run_deployment "$DEPLOYMENT_ID")

echo "フロー実行ID: $FLOW_RUN_ID"
echo "完了しました。フローの実行が完了するまでしばらくお待ちください。"