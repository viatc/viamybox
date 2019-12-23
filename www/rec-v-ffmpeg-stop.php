<?php
$cmd = "sudo /home/pi/viamybox/www/scripts/via_rec_video_ffmpeg.sh stop";
$output= exec($cmd ." >/dev/null &");
?>
