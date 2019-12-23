<?php
$output = 0;
$cmd = "sudo /home/pi/viamybox/www/scripts/via_rec_video_gstrm.sh";
$output= exec($cmd ." >/dev/null &");
?>
