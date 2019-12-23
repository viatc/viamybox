<?php
// $output= system ('/sbin/via_rec_audio_wrapper');
$output = 0;
$cmd = "sudo /home/pi/viamybox/www/scripts/via_rec_audio_gstrm.sh";
$output= exec($cmd ." >/dev/null &");
?>
