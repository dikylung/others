@echo off
REM loop through sjcam mov files
for %%A IN ("*.MOV") DO ffmpeg -stats -v 1 -vsync 1 -i "%%A" -c:v h264_qsv -global_quality 27 -look_ahead 1 -g 70 -c:a aac "prep\%%~nA.mp4"