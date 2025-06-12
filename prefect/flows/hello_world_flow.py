"""
Hello World Flow - シンプルなモックワークフロー
"""
from prefect import flow, task


@task
def print_hello(name: str = "World") -> str:
    """挨拶メッセージを出力するタスク"""
    message = f"Hello, {name}!"
    print(message)
    return message


@task
def print_status() -> str:
    """ステータスメッセージを出力するタスク"""
    message = "ワークフローが正常に実行されました"
    print(message)
    return message


@flow(name="Hello World Flow", description="シンプルなモックワークフロー")
def hello_world_flow(name: str = "Prefect"):
    """
    Hello Worldワークフロー（モック版）
    
    Args:
        name: 挨拶する相手の名前
    """
    print("=== Hello World Flow 開始 ===")
    
    hello_result = print_hello(name)
    status_result = print_status()
    
    print("=== Hello World Flow 完了 ===")
    
    return {
        "greeting": hello_result,
        "status": status_result
    }


if __name__ == "__main__":
    # ローカル実行用
    result = hello_world_flow("Docker環境")
    print(f"実行結果: {result}")