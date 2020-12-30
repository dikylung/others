@echo off
REM -g 30 or -g 18 crucial for scrubbing, -bf 2 helps a little with file size
REM loop through sjcam mov files
for %%A IN ("*.MOV") DO ffmpeg -stats -v 1 -vsync 1 -i "%%A" -c:v h264_qsv -global_quality 27 -look_ahead 1 -bf 2 -g 30 -c:a aac "prep\%%~nA.mp4"