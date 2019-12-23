<?php
$output = 0;
$cmd = "sudo /home/pi/viamybox/www/scripts/timelapse_start.sh --recvideo";
$output= exec($cmd ." >/dev/null &");
?>

