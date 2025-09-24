# Ultimate YouTube Video Downloader (Batch Script)

## 🎯 Advantages
This batch script provides a simple yet powerful way to download YouTube videos and audio directly from Windows, without needing to memorize long command-line options. Some key benefits:

- **User-Friendly** – Instead of typing complex commands, you just paste the video URL and pick the format.
- **Multiple Format Support** – Works with MP3 (audio), MP4, and MKV (video) formats.
- **No Manual Searching** – Automatically filters and lists only useful formats, making selection easier.
- **Integrated Tools** – Uses `yt-dlp` with `ffmpeg` for maximum compatibility and metadata embedding.
- **Reliable Downloads** – Falls back to an alternative download method if the first attempt fails.
- **Automatic Organization** – Downloads are saved into a predefined `Downloads` folder with clear filenames.

---

## ⚙️ Features
This script includes several handy functions:

- **Playlist Support**: Choose whether your input link is a single video or a playlist.
- **Format Filtering**: Displays only MP3, MP4, and MKV formats for easier selection.
- **Serial Number Selection**: Pick the desired format by entering its serial number.
- **Metadata Embedding**: Automatically embeds subtitles, thumbnails, and metadata into files.
- **Audio/Video Detection**: Detects whether you selected an audio-only or video format, then downloads accordingly.
- **Error Handling**: If a download fails, the script retries with a simplified command.
- **Update Reminder**: Suggests updating `yt-dlp` if errors persist.

---

## 🛠️ Setup Process
Follow these steps to set up the script:

1. **Download Required Files**  
   - [yt-dlp.exe](https://github.com/yt-dlp/yt-dlp/releases)  
   - [ffmpeg.exe](https://ffmpeg.org/download.html)  

2. **Create a Folder**  
   - Make a folder (e.g., `YouTubeDownloader`).  
   - Place the following files inside it:
     - `yt-dlp.exe`
     - `ffmpeg.exe`
     - The batch script (e.g., `Ultimate YouTube Video Downloader.bat`).

3. **Folder Structure Example**
   ```
   YouTubeDownloader\
   ├─ yt-dlp.exe
   ├─ ffmpeg.exe
   ├─ downloader.bat
   └─ Downloads\   (auto-created for saving files)
   ```

4. **Run the Script**  
   - Double-click `Ultimate YouTube Video Downloader.bat`.  
   - Enter the video/playlist URL.  
   - Choose whether it’s a playlist.  
   - Pick the desired format using the serial number.  
   - Wait for the download to complete.

5. **Find Your Files**  
   - Downloads will be saved in the `Downloads` folder inside your script directory.

---

## 📜 License
Released under the **MIT License**. See [LICENSE](LICENSE) for details.  
   ```
   Copyright (c) 2025 Munna MasterMind
   ```
---

## 👨‍💻 Author
🛠️ Developed and maintained by [Munna MasterMind](https://www.facebook.com/The.Munna)  
🌍 Open-source and free for all users.  

---

<div align="center">

## ☕ Support the Project  
✨ If you find this project helpful and want to support its development,  
consider buying me a coffee via **Binance Pay**:  

[![Binance Pay](https://img.shields.io/badge/Binance%20Pay-788233021-fcd535?style=for-the-badge&logo=binance&logoColor=white)](https://github.com/Munna-Soft)  

🚀 Every contribution keeps me motivated and helps me improve this project!  

</div>

---

## 🤝 Contribution  
Pull requests and issues are welcome if you want to improve documentation. 

---

✅ Now you have a fully automated and user-friendly YouTube downloader for Windows!
