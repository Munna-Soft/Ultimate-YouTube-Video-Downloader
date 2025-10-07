@echo off
setlocal enabledelayedexpansion

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
  echo ERROR: yt-dlp.exe not found in "%~dp0".
  pause
  exit /b 1
)

echo.
echo ========================================================================================
echo          Ultimate YouTube Video Downloader - By Munna MasterMind
echo                       	https://facebook.com/The.Munna
echo ========================================================================================
echo.

:: Ask for URL
set /p VIDEO_URL=Enter YouTube URL or Playlist URL: 
if "%VIDEO_URL%"=="" (
  echo No URL provided. Exiting.
  pause
  exit /b 1
)

:: Ask playlist confirmation
echo.
set /p ISPL=Is this a playlist? (y/n): 
if /I "%ISPL%"=="y" (
  set PLAYLIST_FLAG=
) else (
  set PLAYLIST_FLAG=--no-playlist
)

:: Save available formats to temp file
echo.
echo Fetching available formats...
"%YTDLP%" -F %PLAYLIST_FLAG% "%VIDEO_URL%" > "%TMPFILE%"

echo.
echo ================= Available Formats (MP3, MP4, MKV only) =================
set COUNT=0

:: Filter and show only MP3, MP4, and MKV formats
for /f "tokens=*" %%A in ('type "%TMPFILE%" ^| findstr /i "mp4 mkv mp3"') do (
    set /a COUNT+=1
    echo !COUNT!^) %%A
    set "FMT_!COUNT!=%%A"
)

:: If no MP3/MP4/MKV formats found, show message
if !COUNT!==0 (
  echo No MP3, MP4 or MKV formats found.
  echo Showing all available formats instead:
  echo.
  set COUNT=0
  for /f "skip=3 tokens=* delims=" %%A in (%TMPFILE%) do (
      set /a COUNT+=1
      echo !COUNT!^) %%A
      set "FMT_!COUNT!=%%A"
  )
)

echo ====================================================
echo.

:: If no formats found at all, exit
if !COUNT!==0 (
  echo No formats available for this URL.
  del "%TMPFILE%" 2>nul
  pause
  exit /b 1
)

:: Ask user for serial number
set /p SERIAL=Enter Serial Number of desired format: 

if "%SERIAL%"=="" (
  echo No selection made. Exiting.
  del "%TMPFILE%" 2>nul
  pause
  exit /b 1
)

:: Validate serial number
set /a SERIAL=%SERIAL% 2>nul
if %SERIAL% lss 1 (
  echo Invalid serial number.
  del "%TMPFILE%" 2>nul
  pause
  exit /b 1
)

if %SERIAL% gtr %COUNT% (
  echo Serial number too high. Maximum is %COUNT%.
  del "%TMPFILE%" 2>nul
  pause
  exit /b 1
)

:: Extract actual format code from saved line
for /f "tokens=1" %%B in ("!FMT_%SERIAL%!") do set FORMAT_CODE=%%B

echo.
echo You selected Serial %SERIAL% → Format Code %FORMAT_CODE%
echo.

:: Determine if it's audio only
echo !FMT_%SERIAL%! | findstr /i "audio" >nul
if errorlevel 1 (
  echo Downloading video with best audio...
  "%YTDLP%" -f %FORMAT_CODE%+bestaudio --merge-output-format mp4 -o "%OUTDIR%\%%(title)s.%%(ext)s" %EXTRA_OPTS% %PLAYLIST_FLAG% "%VIDEO_URL%"
) else (
  echo Downloading audio only...
  "%YTDLP%" -f %FORMAT_CODE% -o "%OUTDIR%\%%(title)s.%%(ext)s" %EXTRA_OPTS% %PLAYLIST_FLAG% "%VIDEO_URL%"
)

if errorlevel 1 (
  echo.
  echo yt-dlp reported an error. Trying alternative download method...
  "%YTDLP%" -f %FORMAT_CODE% -o "%OUTDIR%\%%(title)s.%%(ext)s" %PLAYLIST_FLAG% "%VIDEO_URL%"
)

:: Download thumbnail (JPEG)
echo.
echo Downloading video thumbnail...
"%YTDLP%" --skip-download --write-thumbnail --convert-thumbnails jpg -o "%OUTDIR%\%%(title)s.%%(ext)s" %PLAYLIST_FLAG% "%VIDEO_URL%"

if errorlevel 1 (
  echo Thumbnail download failed.
) else (
  echo Thumbnail downloaded successfully!
)

echo.
echo Download Completed Successfully!
echo Files saved to "%OUTDIR%".

:: Cleanup
del "%TMPFILE%" 2>nul

echo.
pause
exit /b 0
