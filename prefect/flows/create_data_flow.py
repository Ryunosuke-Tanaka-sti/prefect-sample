"""
Create Data Flow - データ作成のモックワークフロー
"""
from prefect import flow, task


@task
def mock_initialize_data() -> str:
    """データ初期化をモック"""
    print("データ初期化を実行中...")
    return "Initialized data"


@task
def mock_generate_data(data_type: str, count: int) -> list:
    """データ生成をモック"""
    print(f"{data_type} データを {count} 件生成中...")
    return [f"{data_type}_data_{i+1}" for i in range(count)]


@task
def mock_validate_data(data: list) -> str:
    """データ検証をモック"""
    print(f"{len(data)} 件のデータを検証中...")
    return f"Validated {len(data)} data items successfully"


@task
def mock_save_data(data: list, output_path: str) -> str:
    """データ保存をモック"""
    print(f"データを保存中: {output_path}")
    return f"Saved {len(data)} items to {output_path}"


@flow(name="Create Data Flow", description="データ作成のモックワークフロー")
def create_data_flow(
    data_type: str = "sample",
    count: int = 10,
    output_path: str = "/opt/prefect/data/output.json"
):
    """
    データ作成ワークフロー（モック版）
    
    Args:
        data_type: 生成するデータの種類
        count: 生成するデータの件数
        output_path: 保存先のパス
    """
    print("=== Create Data Flow 開始 ===")
    
    # データ初期化（モック）
    init_result = mock_initialize_data()
    
    # データ生成（モック）
    generated_data = mock_generate_data(data_type, count)
    
    # データ検証（モック）
    validation_result = mock_validate_data(generated_data)
    
    # データ保存（モック）
    save_result = mock_save_data(generated_data, output_path)
    
    print("=== Create Data Flow 完了 ===")
    
    return {
        "initialization": init_result,
        "generated_data": generated_data,
        "validation": validation_result,
        "save_result": save_result
    }


if __name__ == "__main__":
    # ローカル実行用
    result = create_data_flow(data_type="test", count=5, output_path="/tmp/test_output.json")
    print(f"実行結果: {result}")