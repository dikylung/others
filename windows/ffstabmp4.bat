@echo off
REM Stabilize vid with 2 pass

for %%A IN ("*.mp4") DO (
	ffmpeg -i "%%A" -vf vidstabdetect=stepsize=32:shakiness=10:accuracy=10:result=vidstab_vectors.trf -f null -
	REM no need smooting
	REM -g 70 = i-frame every 70th frame for good scrubbing
	REM ffmpeg -t 30 -i "%%A" -y -vf vidstabtransform=input=transform_vectors.trf:zoom=0:smoothing=10,unsharp=5:5:0.8:3:3:0.4 -c:v h264_qsv -global_quality 35 -look_ahead 1 -c:a copy "vidstab\%%A"
	ffmpeg -i "%%A" -y -vf vidstabtransform=input=vidstab_vectors.trf -c:v h264_qsv -global_quality 29 -look_ahead 1 -g 30 -bf 2 -c:a copy "vidstab\%%A"
)