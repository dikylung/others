@echo off

for %%A IN ("*.MP4") DO ffmpeg -t 30 -vsync 1 -i "%%A" -c:v mpeg2video -qscale:v 9 -pix_fmt yuv420p "output\%%~nA.mpg"