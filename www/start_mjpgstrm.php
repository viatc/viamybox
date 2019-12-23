<?php
$output = 0;
$cmd = "sudo /home/pi/viamybox/www/scripts/start_mjpgstrm.sh";
$output= exec($cmd ." >/dev/null &");
?>