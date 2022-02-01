<?php
$output = 0;
$cmd = "/home/pi/viamybox/scripts/control-services.sh --stopkodi";
$output= exec($cmd ." >/dev/null &");
?>
