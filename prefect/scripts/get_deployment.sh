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

# 全デプロイメント取得
get_all_deployments() {
    curl -s -X POST "${PREFECT_API_URL}/deployments/filter" \
        -H "Content-Type: application/json" \
        -d '{
            "limit": 100
        }'
}

# フロー情報を取得してマップ作成
get_flows_map() {
    local flows_response=$(curl -s -X POST "${PREFECT_API_URL}/flows/filter" \
        -H "Content-Type: application/json" \
        -d '{"limit": 200}')
    
    echo "$flows_response" | jq -r '.[] | "\(.id)|\(.name)"'
}

# メイン処理
echo "デプロイメント取得中..."

DEPLOYMENTS=$(get_all_deployments)

if [ -z "$DEPLOYMENTS" ] || [ "$DEPLOYMENTS" = "[]" ]; then
    echo "デプロイメントが見つかりません"
    exit 1
fi

echo "フロー情報取得中..."
FLOWS_MAP=$(get_flows_map)

# 件数表示
COUNT=$(echo "$DEPLOYMENTS" | jq 'length')
echo "取得件数: $COUNT件"
echo

# 詳細表示
echo "=== デプロイメント一覧 ==="
echo

# 各デプロイメントに対してフロー名を解決
echo "$DEPLOYMENTS" | jq -r '.[] | "\(.flow_id)|\(.id)|\(.name)|\(.is_schedule_active)|\(.created)"' | \
while IFS='|' read -r flow_id deployment_id deployment_name is_active created; do
    # フロー名を検索
    flow_name=$(echo "$FLOWS_MAP" | grep "^$flow_id|" | cut -d'|' -f2)
    
    if [ -z "$flow_name" ]; then
        flow_name="不明"
    fi
    
    # ステータス変換
    if [ "$is_active" = "true" ]; then
        status="アクティブ"
    else
        status="非アクティブ"
    fi
    
    echo "ID: $deployment_id"
    echo "フロー名: $flow_name"
    echo "デプロイメント名: $deployment_name"
    echo "ステータス: $status"
    echo "作成日: $created"
    echo "---"
done