# Voice-Pro 语音克隆与转换工具

基于 [abus-aikorea/voice-pro](https://github.com/abus-aikorea/voice-pro) 的AI语音转换、克隆和翻译工具。

## 🎙️ 功能介绍

Voice-Pro是一款先进的AI语音处理工具，集成了多种功能：

- 🔊 **顶级语音识别技术**：支持Whisper、Faster-Whisper、Whisper-Timestamped、WhisperX
- 🎤 **零样本语音克隆**：支持F5-TTS、E2-TTS、CosyVoice
- 📢 **多语种文本转语音**：支持Edge-TTS、kokoro（付费版包括Azure TTS）
- 🎥 **YouTube视频处理与音频提取**：内置yt-dlp工具
- 🌍 **即时翻译**：支持100+种语言的Deep-Translator（付费版包括Azure Translator）

## 💻 系统要求

- **操作系统**：Windows 10/11（64位）※ 不支持Linux/Mac
- **GPU**：推荐NVIDIA显卡，支持CUDA 12.4
- **显存**：4GB+（推荐8GB+）
- **内存**：4GB+
- **存储空间**：20GB+以上空余空间
- **网络**：需要互联网连接

## 📀 安装步骤

### 1. 获取安装包

- 从GitHub克隆或下载最新版本

```bash
git clone https://github.com/abus-aikorea/voice-pro.git
```

### 2. 安装与运行

1. 🚀 **configure.bat**
   - 安装git、ffmpeg和CUDA（如果有NVIDIA GPU）
   - 首次运行，需要1小时以上并连接互联网
   - 请勿关闭命令窗口

2. 🚀 **start.bat**
   - 启动Voice-Pro网页界面
   - 首次运行会安装依赖（需要1小时以上）
   - 如遇问题，删除**installer_files**文件夹后重试

### 3. 更新

- 🚀 **update.bat**：更新Python环境（比重新安装更快）

### 4. 卸载

- 运行**uninstall.bat**或删除整个文件夹（便携式安装）

## ❓ 使用技巧

#### 浏览器未自动运行

- 关闭Windows命令窗口并重新运行start.bat
- 直接在浏览器中输入命令窗口显示的地址（例如 **http://127.0.0.1:7870**）

#### CUDA内存不足错误

- 检查Windows任务管理器-性能选项卡中的GPU内存状态
- 将降噪级别设置为0或1。降噪级别2至少需要8GB显存
- 将计算类型设置为int类型。float类型质量更好，但需要更多GPU内存

#### 如何提高字幕质量

- 字幕质量通常随着更大的Whisper模型而提升：large > medium > small > base > tiny
- 在计算类型中，float类型性能更好。int类型通过模型量化减少GPU使用并提高速度，但性能降低
- 增加降噪级别可以移除更多背景声音，只保留语音用于识别，但不一定保证更好的结果

## 🚨 注意事项

- 免费试用版本的Voice-Pro处理媒体时长限制为**60秒**
- 订阅版支持Microsoft Azure TTS和Translator，可在[Shopify](https://r17wvy-t2.myshopify.com)购买

| 功能           | 试用版   | 贡献者版 | 订阅版   |
|----------------|----------|----------|----------|
| 媒体长度限制   | 60秒     | 无限制   | 无限制   |
| 翻译服务       | Google翻译(开源) | Google翻译(开源) | Azure翻译(微软) |
| 文本转语音服务 | Edge TTS(开源) | Edge TTS(开源) | Azure TTS(微软) |

## 📬 联系方式

- 邮箱：abus.aikorea@gmail.com
- 韩国主页：https://abuskorea.imweb.me
- 付费版购买：[Shopify（全球）](https://r17wvy-t2.myshopify.com)，[Naver（韩国）](https://smartstore.naver.com/abus)

## 使用的开源项目

* Demucs: https://github.com/facebookresearch/demucs
* yt-dlp: https://github.com/yt-dlp/yt-dlp
* gradio: https://github.com/gradio-app/gradio
* edge-TTS: https://github.com/rany2/edge-tts
* F5-TTS: https://github.com/SWivid/F5-TTS.git
* openai-whisper: https://github.com/openai/whisper
* faster-whisper: https://github.com/SYSTRAN/faster-whisper
* whisper-timestamped: https://github.com/linto-ai/whisper-timestamped
* whisperX: https://github.com/m-bain/whisperX
* CosyVoice: https://github.com/FunAudioLLM/CosyVoice
* kokoro: https://github.com/hexgrad/kokoro
* Deep-Translator: https://github.com/nidhaloff/deep-translator
* spaCy: https://github.com/explosion/spaCy

## ©️ 版权

原项目版权归[ABUS](https://abuskorea.imweb.me)所有