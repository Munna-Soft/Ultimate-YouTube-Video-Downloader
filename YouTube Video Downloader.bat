@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
title YouTube Video Downloader v3.0- Munna MasterMind

:: --- Config ---
set YTDLP=%~dp0yt-dlp.exe
set FFMPEG=%~dp0ffmpeg.exe
set OUTDIR=%~dp0Downloads
set EXTRA_OPTS=--embed-subs --embed-thumbnail --add-metadata
set TMPFILE=%TEMP%\ytformats.txt
:: ------------------

:: Ensure output dir exists
if not exist "%OUTDIR%" mkdir "%OUTDIR%"

:: Check yt-dlp exists
if not exist "%YTDLP%" (
  echo.
  echo ERROR: yt-dlp.exe not found in "%~dp0".
  echo.
  echo Please download yt-dlp.exe from
  echo.
  pause
  exit /b 1
)

:MAIN
cls
echo.
echo        ╔══════════════════════════════════════════════════════╗
echo        ║    YouTube Video Downloader by - Munna MasterMind    ║
echo        ║        https://munna-soft.github.io/Portfolio        ║
echo        ║            https://facebook.com/The.Munna            ║
echo        ╚══════════════════════════════════════════════════════╝
echo.

:: Ask for URL
set "VIDEO_URL="
set /p VIDEO_URL=Enter YouTube Video URL or Playlist URL: 
if "%VIDEO_URL%"=="" (
  echo No URL provided.
  pause
  goto ASK_AGAIN
)

:: Ask playlist confirmation
echo.
set "ISPL="
set /p ISPL=Is this a playlist? (y/n): 

if /I "%ISPL%"=="y" (
  set PLAYLIST_FLAG=
) else if /I "%ISPL%"=="n" (
  set PLAYLIST_FLAG=--no-playlist
) else (
  echo ^G
  echo Invalid choice!
  pause
  goto MAIN
)

:: Save available formats
echo.
echo Fetching available formats...
"%YTDLP%" -F %PLAYLIST_FLAG% "%VIDEO_URL%" > "%TMPFILE%"

echo.
echo ================= Available Formats (MP3, MP4, MKV only) =================
set COUNT=0

for /f "tokens=*" %%A in ('type "%TMPFILE%" ^| findstr /i "mp4 mkv mp3"') do (
    set /a COUNT+=1
    echo !COUNT!^) %%A
    set "FMT_!COUNT!=%%A"
)

if !COUNT!==0 (
  echo No MP3, MP4 or MKV formats found.
  pause
  goto MAIN
)

echo ====================================================
echo.

:: Ask serial
set "SERIAL="
set /p SERIAL=Enter Serial Number of desired format/resolution: 

set /a SERIAL=%SERIAL% 2>nul
if %SERIAL% lss 1 (
  echo Invalid serial number.
  pause
  goto MAIN
)

if %SERIAL% gtr %COUNT% (
  echo Serial number too high.
  pause
  goto MAIN
)

for /f "tokens=1" %%B in ("!FMT_%SERIAL%!") do set FORMAT_CODE=%%B

echo.
echo You selected Format Code: %FORMAT_CODE%
echo.

:: Check audio/video
echo !FMT_%SERIAL%! | findstr /i "audio" >nul
if errorlevel 1 (
  "%YTDLP%" -f %FORMAT_CODE%+bestaudio --merge-output-format mp4 -o "%OUTDIR%\%%(title)s.%%(ext)s" %EXTRA_OPTS% %PLAYLIST_FLAG% "%VIDEO_URL%"
) else (
  "%YTDLP%" -f %FORMAT_CODE% -o "%OUTDIR%\%%(title)s.%%(ext)s" %EXTRA_OPTS% %PLAYLIST_FLAG% "%VIDEO_URL%"
)

:: Thumbnail
echo.
"%YTDLP%" --skip-download --write-thumbnail --convert-thumbnails jpg -o "%OUTDIR%\%%(title)s.%%(ext)s" %PLAYLIST_FLAG% "%VIDEO_URL%"

echo.
echo Download Completed Successfully!
echo Files saved to "%OUTDIR%".

del "%TMPFILE%" 2>nul

:ASK_AGAIN
echo.
set "AGAIN="
set /p AGAIN=Download another video? (y/n): 

if /I "%AGAIN%"=="y" goto MAIN
if /I "%AGAIN%"=="n" exit /b 0

:: Invalid input
echo ^G
echo Invalid input! Please press y or n.
goto ASK_AGAIN
