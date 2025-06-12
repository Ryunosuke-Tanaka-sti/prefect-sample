"""
Get Data Flow - データ取得のモックワークフロー
"""
from prefect import flow, task


@task
def mock_fetch_data(source: str) -> list:
    """データ取得をモック"""
    print(f"データを取得中: {source}")
    return [f"data_item_{i+1}" for i in range(5)]


@task
def mock_process_data(data: list) -> list:
    """データ処理をモック"""
    print(f"{len(data)} 件のデータを処理中...")
    return [f"processed_{item}" for item in data]


@task
def mock_store_data(data: list, destination: str) -> str:
    """データ保存をモック"""
    print(f"データを保存中: {destination}")
    return f"Stored {len(data)} items to {destination}"


@flow(name="Get Data Flow", description="データ取得のモックワークフロー")
def get_data_flow(
    source: str = "http://example.com/api/data",
    destination: str = "/opt/prefect/data/processed_data.json"
):
    """
    データ取得ワークフロー（モック版）
    
    Args:
        source: データ取得元のURLやパス
        destination: 保存先のパス
    """
    print("=== Get Data Flow 開始 ===")
    
    # データ取得（モック）
    fetched_data = mock_fetch_data(source)
    
    # データ処理（モック）
    processed_data = mock_process_data(fetched_data)
    
    # データ保存（モック）
    store_result = mock_store_data(processed_data, destination)
    
    print("=== Get Data Flow 完了 ===")
    
    return {
        "fetched_data": fetched_data,
        "processed_data": processed_data,
        "store_result": store_result
    }


if __name__ == "__main__":
    # ローカル実行用
    result = get_data_flow(
        source="http://test.com/api/mock_data",
        destination="/tmp/processed_data.json"
    )
    print(f"実行結果: {result}")
