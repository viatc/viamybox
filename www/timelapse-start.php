<?php
$output = 0;
$ps = exec ("ps aux | grep -i 'timelapse_start.sh' | grep -v grep|tr -s ' '|cut -d ' ' -f 2");
//echo "$ps";
if ($ps == 0) {
$cmd = "sudo /home/pi/viamybox/www/scripts/timelapse_start.sh";
$output= exec($cmd ." >/dev/null &");
}
?>

