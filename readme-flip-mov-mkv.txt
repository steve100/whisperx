Got it—when CCW looked “correct but upside down,” that means the file needs a 90° CCW plus a vertical flip (some cameras encode a rotation + mirror in the display matrix).

Try this exact command (adds vflip and also drops non-A/V streams for MKV):

ffmpeg -noautorotate -i "IMG_6707.MOV" \
  -vf "transpose=2,vflip,setsar=1" -metadata:s:v:0 rotate=0 \
  -c:v libx264 -pix_fmt yuv420p -crf 20 -preset medium \
  -c:a copy -map 0 -map -0:d -map -0:t -n \
  "custom-ccw-vflip.mkv"


If that still isn’t right, the other common variant is 90° CW + horizontal flip:

ffmpeg -noautorotate -i "IMG_6707.MOV" \
  -vf "transpose=1,hflip,setsar=1" -metadata:s:v:0 rotate=0 \
  -c:v libx264 -pix_fmt yuv420p -crf 20 -preset medium \
  -c:a copy -map 0 -map -0:d -map -0:t -n \