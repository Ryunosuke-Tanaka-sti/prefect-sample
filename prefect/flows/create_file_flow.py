"""
Create File Flow - ファイル作成のモックワークフロー
"""
from prefect import flow, task


@task
def mock_create_directory(dir_path: str) -> str:
    """ディレクトリ作成をモック"""
    print(f"ディレクトリを作成: {dir_path}")
    return f"Created: {dir_path}"


@task
def mock_generate_data() -> str:
    """データ生成をモック"""
    print("サンプルデータを生成しました")
    return "sample_data_generated"


@task
def mock_create_json_file(data: str, file_path: str) -> str:
    """JSONファイル作成をモック"""
    print(f"JSONファイルを作成: {file_path}")
    return f"JSON created: {file_path}"


@task
def mock_create_csv_file(data: str, file_path: str) -> str:
    """CSVファイル作成をモック"""
    print(f"CSVファイルを作成: {file_path}")
    return f"CSV created: {file_path}"


@task
def mock_validate_files(files: list) -> str:
    """ファイル検証をモック"""
    print(f"{len(files)}個のファイルを検証しました")
    return "All files validated successfully"


@flow(name="Create File Flow", description="ファイル作成のモックワークフロー")
def create_file_flow(output_dir: str = "/opt/prefect/data", file_prefix: str = "sample"):
    """
    ファイル作成ワークフロー（モック版）
    
    Args:
        output_dir: 出力ディレクトリのパス
        file_prefix: ファイル名のプレフィックス
    """
    print("=== Create File Flow 開始 ===")
    
    # ディレクトリ作成（モック）
    dir_result = mock_create_directory(output_dir)
    
    # データ生成（モック）
    data = mock_generate_data()
    
    # ファイル作成（モック）
    json_result = mock_create_json_file(data, f"{output_dir}/{file_prefix}.json")
    csv_result = mock_create_csv_file(data, f"{output_dir}/{file_prefix}.csv")
    
    # 検証（モック）
    files = [json_result, csv_result]
    validation_result = mock_validate_files(files)
    
    print("=== Create File Flow 完了 ===")
    
    return {
        "directory": dir_result,
        "files_created": files,
        "validation": validation_result
    }


if __name__ == "__main__":
    # ローカル実行用
    result = create_file_flow("/tmp/test", "mock_test")
    print(f"実行結果: {result}")