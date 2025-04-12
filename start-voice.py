import argparse
import os
import sys
import subprocess
import shutil
from pathlib import Path

# 全局变量定义
INSTALL_DIR = os.path.join(os.getcwd(), "installer_files")
CONDA_ROOT_PREFIX = os.path.join(INSTALL_DIR, "conda")
CONDA_ENV_PATH = os.path.join(INSTALL_DIR, "env")

def print_big_message(message):
    """打印突出显示的消息"""
    print("\n\n")
    print("*" * 70)
    for line in message.split("\n"):
        print(f"* {line}")
    print("*" * 70)
    print("\n\n")

def check_environment():
    """检查环境设置"""
    print("正在检查环境...")
    
    # 检查Python版本
    print(f"Python版本: {sys.version}")
    
    # 检查操作系统
    print(f"操作系统: {os.name}")
    
    # 检查GPU
    try:
        import torch
        print(f"CUDA是否可用: {torch.cuda.is_available()}")
        if torch.cuda.is_available():
            print(f"CUDA版本: {torch.version.cuda}")
            print(f"GPU型号: {torch.cuda.get_device_name(0)}")
    except ImportError:
        print("无法导入torch以检查CUDA状态")
    
    return True

def is_installed():
    """检查是否已安装"""
    return os.path.exists(CONDA_ENV_PATH) and os.path.exists(os.path.join(CONDA_ENV_PATH, "python.exe"))

def install_webui(update=False):
    """安装或更新WebUI"""
    print("正在安装/更新Voice-Pro WebUI...")
    
    # 创建必要的目录
    os.makedirs(INSTALL_DIR, exist_ok=True)
    
    # 安装依赖
    pip_install_packages()
    
    # 下载必要的模型
    download_models()
    
    print("WebUI安装/更新完成！")

def pip_install_packages():
    """安装必要的Python包"""
    print("正在安装Python依赖项...")
    
    # 读取requirements文件
    req_file = "requirements-voice-gpu.txt" if is_cuda_available() else "requirements-voice-cpu.txt"
    
    if os.path.exists(req_file):
        # 使用pip安装依赖项
        subprocess.run([sys.executable, "-m", "pip", "install", "-r", req_file])
    else:
        print(f"错误: 找不到{req_file}文件")
        sys.exit(1)

def is_cuda_available():
    """检查CUDA是否可用"""
    try:
        import torch
        return torch.cuda.is_available()
    except ImportError:
        return False

def download_models():
    """下载必要的模型文件"""
    print("正在下载必要的模型...")
    try:
        # 使用Hugging Face下载模型
        from huggingface_hub import snapshot_download
        
        # 下载Whisper模型
        snapshot_download(repo_id="openai/whisper-small", local_dir="models/whisper-small")
        
        # 下载其他必要模型
        # 这里可以根据需要添加更多模型的下载
        
    except ImportError:
        print("无法导入huggingface_hub以下载模型")
        sys.exit(1)
    except Exception as e:
        print(f"下载模型时出错: {str(e)}")
        sys.exit(1)

def run_webui():
    """运行WebUI"""
    print("正在启动Voice-Pro WebUI...")
    
    # 这里定义运行WebUI的代码
    import gradio as gr
    
    # 创建简单的gradio界面
    def tts_function(text, voice_type):
        # 这里是文本转语音的示例函数
        return f"已处理文本: {text}，使用声音: {voice_type}"
    
    demo = gr.Interface(
        fn=tts_function,
        inputs=[
            gr.Textbox(label="输入文本"),
            gr.Dropdown(choices=["男声", "女声"], label="选择声音类型")
        ],
        outputs="text",
        title="Voice-Pro 简易界面",
        description="语音克隆与转换工具"
    )
    
    demo.launch(server_name="127.0.0.1", server_port=7870)

if __name__ == "__main__":
    # 检查环境
    check_environment()
    
    # 检查是否已安装
    already_installed = is_installed()
    
    # 根据安装状态决定是否需要安装或更新
    if not already_installed:
        print_big_message("首次运行，正在安装Voice-Pro...")
        install_webui(False)
    else:
        # 检查命令行参数，是否需要更新
        parser = argparse.ArgumentParser(description="Voice-Pro启动脚本")
        parser.add_argument("--update", action="store_true", help="更新WebUI")
        args, _ = parser.parse_known_args()
        
        if args.update:
            print_big_message("正在更新Voice-Pro...")
            install_webui(True)
    
    # 运行WebUI
    run_webui()