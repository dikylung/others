@echo off
REM ffshare <input> <720> for 720p
ffmpeg -vsync 1 -i %1 -vf scale=-2:%2,setsar=1:1 -c:v h264_qsv -global_quality 29 -look_ahead 1 -bf 2 -g 70 -c:a aac %~n1-%2p-qsv.mp4