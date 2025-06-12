# Prefect プロジェクト

## 概要

このプロジェクトは、Prefect を使用してデータフローやワークフローを管理するためのものです。  
提供されたスクリプトや構成ファイルを使用して、Prefect Server のセットアップ、フローのデプロイメント、エージェントの起動を自動化します。

## セットアップ手順

`compose.yml` を使用して、Prefect Server や関連サービスを起動します。

```bash
docker-compose -f compose.yml up -d
```

Prefect UI は以下の URL でアクセス可能です。

```
http://localhost:4200
```

## ディレクトリ構造

```
/home/ryu/product/iij/prefect/
├── prefect/                     # Prefect関連スクリプトと設定
│   ├── deploy-entrypoint.sh     # デプロイメント登録スクリプト
│   ├── entrypoint.sh            # 環境設定用エントリーポイントスクリプト
│   ├── flows/                   # フロー定義ディレクトリ
│   └── deployments/             # デプロイメントファイル保存ディレクトリ
├── compose.yml                  # Docker Compose構成ファイル
└── README.md                    # このファイル
```

## 使用方法

### フローのテスト実行

`deploy-entrypoint.sh` スクリプト内で、以下のフローがテスト実行されます。

- Hello World Flow
- Create File Flow
- Download File Flow

### デプロイメントの作成

`deploy-entrypoint.sh` スクリプトを使用して、以下のデプロイメントが自動的に作成されます。

- Hello World Deployment
- Create File Deployment
- Download File Deployment

デプロイメントファイルは `/opt/prefect/deployments/` に保存されます。

### Prefect Agent の起動

`entrypoint.sh` スクリプトを使用して、Prefect Agent が起動されます。  
エージェントはデフォルトのワークプール `default` に接続されます。

## 注意事項

- `compose.yml` 内の環境変数やポート設定を必要に応じて変更してください。
- Prefect Server が起動するまでに時間がかかる場合があります。`deploy-entrypoint.sh` スクリプトは自動的に待機します。
