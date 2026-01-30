@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
title YouTube Video Downloader v4.5 - Munna MasterMind

REM ================= CONFIG =================
set ROOT=%~dp0
set YTDLP=%ROOT%yt-dlp.exe
set FFMPEG=%ROOT%ffmpeg.exe
set OUTDIR=%ROOT%Downloads
set TMPFILE=%TEMP%\ytformats.txt
set USER_AGENT=
set EXTRA_OPTS=

if not exist "%OUTDIR%" mkdir "%OUTDIR%"

REM ================= MENU ===================
:MENU
cls
echo.
echo    ╔══════════════════════════════════════════════╗
echo    ║   YouTube Downloader - Munna MasterMind      ║
echo    ╠══════════════════════════════════════════════╣
echo    ║  1. Complete Dependency Setup                ║
echo    ║  2. Download Single Videos                   ║
echo    ║  3. Download Playlist Videos                 ║
echo    ║  4. Download Bulk Videos at Once             ║
echo    ║  5. Contact Us For Development               ║
echo    ║  0. Exit Program                             ║
echo    ╚══════════════════════════════════════════════╝
echo.

choice /c 012345 /n /m "Select Option Between [0-5]: "

if errorlevel 6 goto CONTACT
if errorlevel 5 goto BULK_VIDEOS
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
    echo Please check your internet connection and try again or download manually from: https://github.com/BtbN/FFmpeg-Builds/releases/latest
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
  echo  yt-dlp.exe not found!
  echo  Please run option 1 first for Dependency Setup.
  echo.
  pause
  goto MENU
)
exit /b

REM ============ CHECK FFmpeg ================
:CHECK_FFMPEG
if not exist "%FFMPEG%" (
  echo.
  echo  ffmpeg.exe not found!
  echo  Please run option 1 first for Dependency Setup.
  echo.
  pause
  goto MENU
)
exit /b

REM ============ SINGLE VIDEO ================
:SINGLE_VIDEO
call :CHECK_YTDLP
call :CHECK_FFMPEG
set PLAYLIST_FLAG=--no-playlist
set OUTPUT_TEMPLATE=%OUTDIR%\%%(title)s.%%(ext)s

:SINGLE_LOOP
call :DOWNLOAD_FLOW
set /p AGAIN=Do you want to download more videos? (y/n): 
if /I "%AGAIN%"=="y" goto SINGLE_LOOP
if /I "%AGAIN%"=="n" goto MENU
goto SINGLE_LOOP

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
set /p VIDEO_URL=Input YouTube Video URLs: 
if "%VIDEO_URL%"=="" goto MENU

echo.
echo Fetching available formats...
echo.

"%YTDLP%" -F %PLAYLIST_FLAG% "%VIDEO_URL%" > "%TMPFILE%"

echo.
echo ========== Available Formats (MP3 / MP4) ==========
set COUNT=0
for /f "tokens=*" %%A in ('type "%TMPFILE%" ^| findstr /i "mp4 mkv mp3" ^| findstr /v /i "m3u8"') do (
    set /a COUNT+=1
    echo !COUNT!^) %%A
    set "FMT_!COUNT!=%%A"
)

if !COUNT!==0 (
  echo.
  echo [ERROR] No supported formats found! Please check the URL.
  echo.
  del "%TMPFILE%" 2>nul
  exit /b
)

echo --------------------------------------------------
echo.
echo Tips: For best quality, choose the highest number (usually at the bottom)
echo.
set /p SERIAL=Input Format/Resolution Serial Number: 
for /f "tokens=1" %%B in ("!FMT_%SERIAL%!") do set FORMAT_CODE=%%B

echo.
echo Downloading Video...

echo !FMT_%SERIAL%! | findstr /i "audio" >nul
if errorlevel 1 (
  "%YTDLP%" -f %FORMAT_CODE%+bestaudio --merge-output-format mp4 ^
  -o "%OUTPUT_TEMPLATE%" %EXTRA_OPTS% %PLAYLIST_FLAG% "%VIDEO_URL%"
) else (
  "%YTDLP%" -f %FORMAT_CODE% ^
  -o "%OUTPUT_TEMPLATE%" %EXTRA_OPTS% %PLAYLIST_FLAG% "%VIDEO_URL%"
)

REM ============ THUMBNAILS DOWNLOAD ==============
echo.
echo Downloading thumbnails for video...
"%YTDLP%" --skip-download --write-thumbnail --convert-thumbnails jpg ^
-o "%OUTPUT_TEMPLATE%" %PLAYLIST_FLAG% "%VIDEO_URL%"

del "%TMPFILE%" 2>nul
echo.
echo ✅ Download Completed!
exit /b

REM ============ PLAYLIST VIDEO ==============
:PLAYLIST_VIDEO
call :CHECK_YTDLP
call :CHECK_FFMPEG
set PLAYLIST_FLAG=
set OUTPUT_TEMPLATE=%OUTDIR%\%%(playlist_title)s\%%(title)s.%%(ext)s

cls
echo.
echo        ╔═══════════════════════════════════════════════════╗
echo        ║  YouTube Video Downloader by - Munna MasterMind   ║
echo        ║       https://munna-soft.github.io/Portfolio      ║
echo        ║          https://facebook.com/The.Munna           ║
echo        ╚═══════════════════════════════════════════════════╝
echo.

set "PLAYLIST_URL="
set /p PLAYLIST_URL=Input YouTube Playlist URLs: 
if "%PLAYLIST_URL%"=="" goto MENU

echo.
echo Fetching available formats from first video in playlist...
echo.

"%YTDLP%" --playlist-items 1 -F %PLAYLIST_FLAG% "%PLAYLIST_URL%" > "%TMPFILE%"

echo.
echo ========== Available Formats (MP3 / MP4) ==========
set COUNT=0
for /f "tokens=*" %%A in ('type "%TMPFILE%" ^| findstr /i "mp4 mkv mp3" ^| findstr /v /i "m3u8"') do (
    set /a COUNT+=1
    echo !COUNT!^) %%A
    set "FMT_!COUNT!=%%A"
)

if !COUNT!==0 (
  echo.
  echo [ERROR] No supported formats found! Please check the URL.
  echo.
  del "%TMPFILE%" 2>nul
  pause
  goto MENU
)

echo --------------------------------------------------
echo.
echo Tips: For best quality, choose the highest number (usually at the bottom)
echo.
set /p SERIAL=Select Format/Resolution Serial Number for all playlist videos: 
for /f "tokens=1" %%B in ("!FMT_%SERIAL%!") do set FORMAT_CODE=%%B

echo.
echo Starting playlist download...

echo !FMT_%SERIAL%! | findstr /i "audio" >nul
if errorlevel 1 (
    "%YTDLP%" -f %FORMAT_CODE%+bestaudio --merge-output-format mp4 ^
    -o "%OUTPUT_TEMPLATE%" %EXTRA_OPTS% %PLAYLIST_FLAG% "%PLAYLIST_URL%"
) else (
    "%YTDLP%" -f %FORMAT_CODE% ^
    -o "%OUTPUT_TEMPLATE%" %EXTRA_OPTS% %PLAYLIST_FLAG% "%PLAYLIST_URL%"
)

REM ============ THUMBNAILS DOWNLOAD =============
echo.
echo Downloading thumbnails for playlist videos...
"%YTDLP%" --skip-download --write-thumbnail --convert-thumbnails jpg ^
-o "%OUTPUT_TEMPLATE%" %PLAYLIST_FLAG% "%PLAYLIST_URL%"

del "%TMPFILE%" 2>nul
echo.
echo ✅ Playlist download completed!
pause
goto MENU

REM ============ BULK VIDEOS ==============
:BULK_VIDEOS
call :CHECK_YTDLP
call :CHECK_FFMPEG
set PLAYLIST_FLAG=--no-playlist
set OUTPUT_TEMPLATE=%OUTDIR%\%%(title)s.%%(ext)s

:BULK_START
cls
echo.
echo        ╔═══════════════════════════════════════════════════╗
echo        ║  YouTube Video Downloader by - Munna MasterMind   ║
echo        ║       https://munna-soft.github.io/Portfolio      ║
echo        ║          https://facebook.com/The.Munna           ║
echo        ╚═══════════════════════════════════════════════════╝
echo.

set /p "VIDEO_COUNT=How many videos do you want to download? (1-100): "
echo.
if "%VIDEO_COUNT%"=="" goto MENU

echo %VIDEO_COUNT%| findstr /r "^[1-9][0-9]*$" >nul
if errorlevel 1 (
    echo Invalid input! Please enter a number between 1-100.
    pause
    goto BULK_START
)

set /a NUM=VIDEO_COUNT 2>nul
if %NUM% LSS 1 (
    echo Minimum 1 video required!
    pause
    goto BULK_START
)
if %NUM% GTR 100 (
    echo Maximum 100 videos allowed!
    pause
    goto BULK_START
)

set "URL_LIST="
set /a CURRENT=1

:GET_URLS
if %CURRENT% GTR %VIDEO_COUNT% goto GOT_URLS

echo [Video %CURRENT% of %VIDEO_COUNT%]
set "URL="
set /p "URL=Enter YouTube URLs: "

if "!URL!"=="" (
    echo URL cannot be empty! Please try again.
    echo.
    goto GET_URLS
)

set "URL_LIST=!URL_LIST!,"!URL!""
echo.
set /a CURRENT+=1
goto GET_URLS

:GOT_URLS
if "!URL_LIST!"=="" (
    echo No URLs entered!
    pause
    goto MENU
)

set "URL_LIST=!URL_LIST:~1!"

for /f "tokens=1 delims=," %%A in ("!URL_LIST!") do (
    set "FIRST_URL=%%~A"
    set "FIRST_URL=!FIRST_URL:"=!"
)

if "!FIRST_URL!"=="" (
    echo Could not process URLs!
    pause
    goto MENU
)

echo.
echo Fetching available formats from first video...
echo.

"%YTDLP%" -F %PLAYLIST_FLAG% "!FIRST_URL!" > "%TMPFILE%"

echo.
echo ========== Available Formats (MP3 / MP4) ==========
set COUNT=0
for /f "tokens=*" %%A in ('type "%TMPFILE%" ^| findstr /i "mp4 mkv mp3" ^| findstr /v /i "m3u8"') do (
    set /a COUNT+=1
    echo !COUNT!^) %%A
    set "FMT_!COUNT!=%%A"
)

if !COUNT!==0 (
    echo.
    echo No supported formats found! Please check the URLs.
    echo.
    pause
    goto MENU
)

:SELECT_FORMAT
echo --------------------------------------------------
echo.
echo Tips: For best quality, choose the highest number (usually at the bottom)
echo.
set /p "SERIAL=Select Format/Resolution Serial Number for all videos: "
if "!FMT_%SERIAL%!"=="" (
    echo Invalid selection! Please choose a number from the list.
    goto SELECT_FORMAT
)

for /f "tokens=1" %%B in ("!FMT_%SERIAL%!") do set FORMAT_CODE=%%B

echo.
echo Starting download of %VIDEO_COUNT% videos...

set /a DOWNLOADED=0
set /a TOTAL=%VIDEO_COUNT%
set "TEMP_LIST=!URL_LIST!"

:DOWNLOAD_LOOP
if "!TEMP_LIST!"=="" goto DOWNLOAD_DONE

for /f "tokens=1* delims=," %%A in ("!TEMP_LIST!") do (
    set "CURRENT_URL=%%~A"
    set "TEMP_LIST=%%B"
)

set "CURRENT_URL=!CURRENT_URL:"=!"

echo.
echo ============================================
set /a DOWNLOADED+=1
echo [Downloading video !DOWNLOADED! of !TOTAL!]
echo ============================================

echo !FMT_%SERIAL%! | findstr /i "audio" >nul
if errorlevel 1 (
    "%YTDLP%" -f %FORMAT_CODE%+bestaudio --merge-output-format mp4 ^
    -o "%OUTPUT_TEMPLATE%" %EXTRA_OPTS% %PLAYLIST_FLAG% "!CURRENT_URL!"
) else (
    "%YTDLP%" -f %FORMAT_CODE% ^
    -o "%OUTPUT_TEMPLATE%" %EXTRA_OPTS% %PLAYLIST_FLAG% "!CURRENT_URL!"
)

REM ============= THUMBNAILS DOWNLOAD ==============
echo.
echo Downloading thumbnail for current video...
"%YTDLP%" --skip-download --write-thumbnail --convert-thumbnails jpg ^
-o "%OUTPUT_TEMPLATE%" %PLAYLIST_FLAG% "!CURRENT_URL!"

goto DOWNLOAD_LOOP

:DOWNLOAD_DONE
del "%TMPFILE%" 2>nul
echo.
echo    ╔═══════════════════════════════════════════════════╗
echo    ║✅ All %VIDEO_COUNT% videos downloaded successfully!║
echo    ╚═══════════════════════════════════════════════════╝
echo.
pause
goto MENU

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