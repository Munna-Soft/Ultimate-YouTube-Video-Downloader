@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
title YouTube Video Downloader v4.1 - Munna MasterMind

REM ================= CONFIG =================
set ROOT=%~dp0
set YTDLP=%ROOT%yt-dlp.exe
set FFMPEG=%ROOT%ffmpeg.exe
set OUTDIR=%ROOT%Downloads
set TMPFILE=%TEMP%\ytformats.txt
set EXTRA_OPTS=--embed-subs --embed-thumbnail --add-metadata

if not exist "%OUTDIR%" mkdir "%OUTDIR%"

REM ================= MENU ===================
:MENU
cls
echo.
echo    ╔══════════════════════════════════════════════╗
echo    ║   YouTube Downloader - Munna MasterMind      ║
echo    ╠══════════════════════════════════════════════╣
echo    ║  1. Download yt-dlp + FFmpeg                 ║
echo    ║  2. Download Single Videos                   ║
echo    ║  3. Download Playlist Videos                 ║
echo    ║  4. Contact Us For Development               ║
echo    ║  0. Exit Program                             ║
echo    ╚══════════════════════════════════════════════╝
echo.

choice /c 01234 /n /m "Select Option Between [0-4]: "

if errorlevel 5 goto CONTACT
if errorlevel 4 goto PLAYLIST_VIDEO
if errorlevel 3 goto SINGLE_VIDEO
if errorlevel 2 goto INSTALL_TOOLS
if errorlevel 1 exit /b
goto MENU

REM ============ INSTALL TOOLS ===============
:INSTALL_TOOLS
cls
echo.
echo Downloading yt-dlp for Dependency Setup...
echo.
powershell -Command "Invoke-WebRequest https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe -OutFile '%YTDLP%'"
echo [OK] yt-dlp.exe successfully downloaded and ready to use!
echo.

REM --- Method 1: curl ---
echo Downloading FFmpeg for Video Encoding...
echo.
where curl >nul 2>&1
if not errorlevel 1 (
    curl -L -o ffmpeg.zip "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
    if exist "ffmpeg.zip" goto EXTRACT_NOW
)

REM --- Method 2: bitsadmin ---
bitsadmin /transfer "FFmpegDL" /download /priority normal ^
"https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip" "ffmpeg.zip"

if exist "ffmpeg.zip" goto EXTRACT_NOW

REM --- Method 3: PowerShell ---
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest 'https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip' -OutFile 'ffmpeg.zip'}"

if not exist "ffmpeg.zip" (
    echo [ERROR] FFmpeg download failed!
    pause
    goto MENU
)

:EXTRACT_NOW
echo.
echo Extracting FFmpeg for Video Encoding...

powershell -Command "Expand-Archive 'ffmpeg.zip' 'ffmpeg_temp' -Force"

for /r "ffmpeg_temp" %%F in (ffmpeg.exe) do (
    copy /y "%%F" "%ROOT%ffmpeg.exe" >nul
)

rd /s /q "ffmpeg_temp"
del ffmpeg.zip

echo.
echo [OK] ffmpeg.exe successfully downloaded and ready to use!
echo.
pause
goto MENU

REM ============ CHECK yt-dlp ================
:CHECK_YTDLP
if not exist "%YTDLP%" (
  echo.
  echo  yt-dlp.exe and ffmpeg.exe not found!
  echo  Please run option 1 first for Dependency Setup.
  echo.
  pause
  goto MENU
)
exit /b

REM ============ SINGLE VIDEO ================
:SINGLE_VIDEO
call :CHECK_YTDLP
set PLAYLIST_FLAG=--no-playlist
set OUTPUT_TEMPLATE=%OUTDIR%\%%(title)s.%%(ext)s

:SINGLE_LOOP
call :DOWNLOAD_FLOW
set /p AGAIN=Do you want to download more videos? (y/n): 
if /I "%AGAIN%"=="y" goto SINGLE_LOOP
if /I "%AGAIN%"=="n" goto MENU
goto SINGLE_LOOP

REM ============ PLAYLIST VIDEO ==============
:PLAYLIST_VIDEO
call :CHECK_YTDLP
set PLAYLIST_FLAG=
set OUTPUT_TEMPLATE=%OUTDIR%\%%(playlist_title)s\%%(title)s.%%(ext)s
call :DOWNLOAD_FLOW
pause
goto MENU

REM ============ DOWNLOAD CORE ===============
:DOWNLOAD_FLOW
cls
echo.
echo        ╔═══════════════════════════════════════════════════╗
echo        ║  YouTube Video Downloader by - Munna MasterMind   ║
echo        ║       https://munna-soft.github.io/Portfolio      ║
echo        ║          https://facebook.com/The.Munna           ║
echo        ╚═══════════════════════════════════════════════════╝
echo.

set "VIDEO_URL="
set /p VIDEO_URL=Enter YouTube URLs: 
if "%VIDEO_URL%"=="" exit /b

echo.
echo Fetching available formats...
"%YTDLP%" -F %PLAYLIST_FLAG% "%VIDEO_URL%" > "%TMPFILE%"

echo.
echo ===== Available Formats (MP4 / MKV / MP3) =====
set COUNT=0
for /f "tokens=*" %%A in ('type "%TMPFILE%" ^| findstr /i "mp4 mkv mp3"') do (
    set /a COUNT+=1
    echo !COUNT!^) %%A
    set "FMT_!COUNT!=%%A"
)

if !COUNT!==0 (
  echo No supported formats found!
  exit /b
)

echo.
set /p SERIAL=Select Format Serial Number: 
for /f "tokens=1" %%B in ("!FMT_%SERIAL%!") do set FORMAT_CODE=%%B

echo.
echo Downloading...

echo !FMT_%SERIAL%! | findstr /i "audio" >nul
if errorlevel 1 (
  "%YTDLP%" -f %FORMAT_CODE%+bestaudio --merge-output-format mp4 ^
  -o "%OUTPUT_TEMPLATE%" %EXTRA_OPTS% %PLAYLIST_FLAG% "%VIDEO_URL%"
) else (
  "%YTDLP%" -f %FORMAT_CODE% ^
  -o "%OUTPUT_TEMPLATE%" %EXTRA_OPTS% %PLAYLIST_FLAG% "%VIDEO_URL%"
)

REM Thumbnail JPG
"%YTDLP%" --skip-download --write-thumbnail --convert-thumbnails jpg ^
-o "%OUTPUT_TEMPLATE%" %PLAYLIST_FLAG% "%VIDEO_URL%"

del "%TMPFILE%" 2>nul
echo.
echo ✅ Download Completed!
exit /b

REM ============ CONTACT INFO ================
:CONTACT
cls
color 0A
echo.
echo:	::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo:	::		YouTube Video Downloader Premium Edition	  ::
echo:	::		Author : Munna MasterMind			  ::
echo:	::		https://github.com/Munna-Soft			  ::
echo:	::		https://facebook.com/The.Munna			  ::
echo:	::		Location : Dhaka, Bangladesh			  ::
echo:	::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.
pause
goto MENU
REM ================= CODE BY Munna MasterMind =================