@echo off
REM Stabilize vid with 2 pass

for %%A IN ("*.mpg") DO (
	ffmpeg -i "%%A" -vf vidstabdetect=stepsize=32:shakiness=10:accuracy=10:result=transform_vectors.trf -f null -
	ffmpeg -i "%%A" -y -vf vidstabtransform=input=transform_vectors.trf:zoom=0:smoothing=10,unsharp=5:5:0.8:3:3:0.4 -c:v mpeg2video -qscale:v 9 -c:a mp2 "vidstab\%%~nA.mpg"
)