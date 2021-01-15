@echo off
REM ffshare <input>
ffmpeg -vsync 1 -i %1 -c:v libx264 -crf 27 -bf 2 -g 70 -c:a copy %~n1-youtube.mp4