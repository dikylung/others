1. Set stream 0:2 volume to 6%
1. Merge the 2 audio tracks into 1
1. downmix to mono, encode in aac

`$ffmpeg -i input.mkv -to 01:00:39 -filter_complex '[0:2]volume=0.06[2];[0:1][2]amerge=inputs=2[a]' -map 0:0 -map [a] -c:v copy -ac 1 -c:a aac output.mp4`
