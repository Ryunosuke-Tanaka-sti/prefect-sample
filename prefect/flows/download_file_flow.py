"""
Download File Flow - ファイルダウンロードのモックワークフロー
"""
from prefect import flow, task


@task
def mock_create_download_directory(dir_path: str) -> str:
    """ダウンロード用ディレクトリ作成をモック"""
    print(f"ダウンロードディレクトリを作成: {dir_path}")
    return f"Created download dir: {dir_path}"


@task
def mock_download_file(url: str, output_path: str) -> str:
    """ファイルダウンロードをモック"""
    print(f"ダウンロード中: {url} -> {output_path}")
    return f"Downloaded: {url}"


@task
def mock_calculate_hash(file_path: str) -> str:
    """ハッシュ値計算をモック"""
    print(f"ハッシュ値計算: {file_path}")
    return f"hash_abc123_{file_path.split('/')[-1]}"


@task
def mock_validate_downloads(downloads: list) -> str:
    """ダウンロード結果検証をモック"""
    print(f"{len(downloads)}個のダウンロードを検証しました")
    return f"All {len(downloads)} downloads validated successfully"


@flow(name="Download File Flow", description="ファイルダウンロードのモックワークフロー")
def download_file_flow(
    urls: list = None,
    output_dir: str = "/opt/prefect/data/downloads"
):
    """
    ファイルダウンロードワークフロー（モック版）
    
    Args:
        urls: ダウンロードするURLのリスト
        output_dir: ダウンロード先ディレクトリ
    """
    print("=== Download File Flow 開始 ===")
    
    # デフォルトのテスト用URL
    if urls is None:
        urls = [
            "https://example.com/file1.json",
            "https://example.com/file2.xml",
            "https://example.com/file3.txt"
        ]
    
    # ダウンロードディレクトリ作成（モック）
    dir_result = mock_create_download_directory(output_dir)
    
    # 各URLからファイルをダウンロード（モック）
    download_results = []
    hash_results = []
    
    for i, url in enumerate(urls):
        output_path = f"{output_dir}/file_{i+1}.dat"
        
        # ダウンロード実行（モック）
        download_result = mock_download_file(url, output_path)
        download_results.append(download_result)
        
        # ハッシュ値計算（モック）
        hash_result = mock_calculate_hash(output_path)
        hash_results.append(hash_result)
    
    # ダウンロード結果の検証（モック）
    validation_result = mock_validate_downloads(download_results)
    
    print("=== Download File Flow 完了 ===")
    
    return {
        "download_directory": dir_result,
        "downloads": download_results,
        "hashes": hash_results,
        "validation": validation_result
    }


if __name__ == "__main__":
    # ローカル実行用
    test_urls = [
        "https://test.com/sample1.json",
        "https://test.com/sample2.txt"
    ]
    result = download_file_flow(test_urls, "/tmp/test_downloads")
    print(f"実行結果: {result}")