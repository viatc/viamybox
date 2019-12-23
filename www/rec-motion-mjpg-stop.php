<?php
$output = 0;
$cmd = "sudo /home/pi/viamybox/www/scripts/stopMovSensorRec.sh";
$output= exec($cmd ." >/dev/null &");
?>
