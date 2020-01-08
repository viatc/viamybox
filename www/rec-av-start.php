<?php
$ps = exec ("ps aux | grep -i 'via_rec_av_start.sh' | grep -v grep|tr -s ' '|cut -d ' ' -f 2");
//echo "$ps";
if ($ps == 0) {
	$cmd = "sudo /home/pi/viamybox/www/scripts/via_rec_av_start.sh";
	$output= exec($cmd ." >/dev/null &");
}
?>
