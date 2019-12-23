<?php
$output = 0;
//$output= system ('python /home/pi/viamybox/www/scripts/mov.py',$retval);
//$output= system ('sudo /home/pi/viamybox/www/scripts/stopMovSensorRec.sh >/dev/null 2>/dev/null &');
//$output= shell_exec('sudo /home/pi/viamybox/www/scripts/stopMovSensorRec.sh >/dev/null 2>/dev/null &');
$cmd = "sudo /home/pi/viamybox/www/scripts/stop_mjpgstrm.sh";
$output= exec($cmd ." >/dev/null &");
?>