<?php
$output = 0;
$cmd = "sudo /home/pi/viamybox/www/scripts/timelapse_stop.sh";
$output= exec($cmd ." >/dev/null &");
?>

