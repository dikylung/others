### Transcode using Quicksync (Windows)

* with "crf" (crf 23 = global_quality 25 look_ahead=1), decode hw accellerate (init_hw_device)
  * `ffmpeg -init_hw_device qsv=hw -filter_hw_device hw -i input.mp4 -vf hwupload=extra_hw_frames=64,format=qsv -c:v h264_qsv -global_quality 30 -look_ahead 1 output.mp4`
* without init_hw_device
  * `ffmpeg -vsync 1 -i input -c:v h264_qsv -global_quality 23 -c:a copy output.mkv`
* H.265 / HEVC
  * `ffmpeg -vsync 1 -i input -load_plugin hevc_hw -c:v hevc_qsv -global_quality 23 -c:a copy output.mkv`

### Transcode using ATI Radeon h264_amf (Windows)
* -ss is start offset, -t is seconds from start offset.
  * `ffmpeg -ss 00:10:00 -t 60 -vsync 1 -i input_file -c:v h264_amf -g 11 -rc cqp -qp_i 21 -qp_p 21 -qp_b 21 -quality balanced -c:a aac output_file.mp4`

### Transcode using Video Toolbox (MacOS)
* maxrate and buffsize optional
  * `ffmpeg -i input.mp4 -c:v h264_videotoolbox -b:v 2M -maxrate 5M -bufsize 10M -c:a copy test.mkv`

### Transcode using VAAPI (Linux)
vaapi (ubuntu 18.04) WARNING: Don't use the SNAP ffmpeg version, it WON'T WORK!!
* `ffmpeg -vaapi_device /dev/dri/renderD128 -i input.mkv -c:v h264_vaapi -vf 'format=nv12,hwupload' -qp 24 -bf 2 -c:a copy output.mkv`

### Transcode using libx264
`ffmpeg -i input -c:v libx264 -preset slow -profile:v high -crf 18 -coder 1 -pix_fmt yuv420p -movflags +faststart -g 30 -bf 2 -c:a aac -b:a 384k -profile:a aac_low output
`
### Youtube recommended setting
```
Video codec: H.264
Parameter	YouTube recommends setting
-profile:v high	High Profile
-bf 2	2 consecutive B frames
-g 30	Closed GOP. GOP of half the frame rate.
-coder 1	CABAC
-crf 18	Variable bitrate.
-pix_fmt yuv420p	Chroma subsampling: 4:2:0
```

### Merge Audio to Mono
- Set stream 0:2 volume to 6%
- Merge the 2 audio tracks into 1
- downmix to mono, encode in aac

`$ffmpeg -i input.mkv -to 01:00:39 -filter_complex '[0:2]volume=0.06[2];[0:1][2]amerge=inputs=2[a]' -map 0:0 -map [a] -c:v copy -ac 1 -c:a aac output.mp4`

`ffmpeg -i 'input.mkv' -filter_complex '[0:a:1]volume=0.1[l];[0:a:0][l]amerge=inputs=2[a]' -map '0:v:0' -map '[a]' -c:v copy -c:a libmp3lame -q:a 3 -ac 2 'output.mp4'`

**Explanation:**

filter_complex is a series of filters that operates on the input. Inside it, filters have inputs and outputs that are the parts in square brackets.

So a filter with two inputs looks like this: `[input0][input1]filter[output]`

`[0:a:1]` picks the 0th input file’s 1st audio track as input for the filter.

`volume=0.1[l]` lowers the volume (this can also use dB units) and puts the result into `l`.

`[0:a:0][l]` selects both the 0th input file’s 0th audio track and `l` from the previous filter as inputs.

`amerge=inputs=2` merges the given 2 input audio tracks. Here you would need to modify the 2 and the inputs if you had more than 2 audio tracks to merge.

`[a]` puts the output of the amerge into a.

`map` switches select the used video and audio tracks for the output. Here we use the original video as video track and the filtered audio a as the audio track.

`c:v` copy sets video codec to copy which just copies it without changing.

`c:a` libmp3lame uses LAME to convert the audio to MP3, here you could use some other codec if you wanted.

`q:a 3` is VBR quality 3 for the LAME codec.

`ac 2` sets output audio to have 2 channels (stereo).

### Trim Video
`$ffmpeg -i input.mp4 -ss 01:10:27 -to 02:18:51 -c:v copy -c:a copy output.mp4`

### Speedup-Slowdown Video
example: speed up 60x = 1/60 = 0.0166677

`ffmpeg -i input.mkv -vf "setpts=0.0166667*PTS" -an output.mkv`

### Stabilize Video (2pass with Vidstab)
#### First pass
Remove -t 60 (limit to first 60 seconds) if you're happy with the result.

`ffmpeg -t 60 -i input.mp4 -vf vidstabdetect=stepsize=32:shakiness=10:accuracy=10:result=transform_vectors.trf -f null - `

#### Second pass
`ffmpeg -t 60 -i input.mp4 -y -vf vidstabtransform=input=transform_vectors.trf:zoom=0:smoothing=10,unsharp=5:5:0.8:3:3:0.4,scale=-1:720 -vcodec libx264 -tune film -an output.mp4`

### Convert to MPEG4 Part 2 (XVID/DiVX) for Honda HR-V in-dash unit
#### Single File
`$ ffmpeg -i input.MP4 -vf "scale=640:360:force_original_aspect_ratio=decrease,pad=640:360:(ow-iw)/2:(oh-ih)/2" -c:v mpeg4 -vtag xvid -q:v 4 -c:a mp3 -q:a 7 output.AVI`

### Loops
#### Linux/MacOS
* `$ for i in *.mp4; do ffmpeg -i $i -vf "scale=640:360:force_original_aspect_ratio=decrease,pad=640:360:(ow-iw)/2:(oh-ih)/2" -c:v mpeg4 -vtag xvid -q:v 4 -c:a mp3 -q:a 7 "${i%.*}.avi"; done`
* `for i in *.mkv; do ffmpeg -async 1 -vsync 1 -i "$i" -c:v libx264 -preset slow -crf 25 -coder 1 -pix_fmt yuv420p -bf 2 -c:a copy output/"${i%.*}.mkv"; done`
#### Windows
`for %%A IN ("*.mp4") DO ffmpeg -stats -v 1 -i "%%A" -vf scale=640:-1 ^
 -c:v libxvid -qscale:v 4 -c:a libmp3lame -b:a 96k "output\%%A.avi"`
 
 ### Cropping and convert to GIF
`ffmpeg -i input -vf "fps=10,scale=-1:240:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse,crop=240:240:exact=1" -loop 0 output.gif`
