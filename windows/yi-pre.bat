@echo off
REM loop through Yi 4k videos for pre-process
for %%A IN ("*.MP4") DO ffmpeg -stats -v 1 -vsync 1 -i "%%A" -c:v h264_qsv -global_quality 29 -look_ahead 1 -g 70 -pix_fmt yuv420p -c:a copy "output\%%A"