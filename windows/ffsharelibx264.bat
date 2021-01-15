@echo off
REM ffshare <input> <720> for 720p
ffmpeg -vsync 1 -i %1 -vf scale=-2:%2,setsar=1:1 -c:v libx264 -crf 27 -bf 2 -g 70 -c:a aac %~n1-%2p-libx264.mp4