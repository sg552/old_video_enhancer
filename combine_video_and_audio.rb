command = "ffmpeg -i test.mp4 -i vcd3_audio.mp3 -c:v copy -c:a aac -strict experimental -shortest output.mp4"
puts command
