<?php
$result = explode(":", $_SERVER['HTTP_REFERER']);
$output = 0;
$cmd = "sudo /home/pi/viamybox/www/scripts/start_stop_mjpgstrm.sh";
$output= exec($cmd ." >/dev/null");
?>
