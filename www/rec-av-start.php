<?php
$ps = exec ("ps aux | grep -i 'via_rec_av_start.sh' | grep -v grep|tr -s ' '|cut -d ' ' -f 2");
if ($ps == 0) {
	$cmd = "sudo /home/pi/viamybox/www/scripts/via_rec_av_start.sh";
	exec($cmd ." >/dev/null &",$output,$retval);
	// print_r(array($output,$retval));
}
else {
	print "Process via_rec_av_start.sh is already running";
}
// if ($retval == 151) {
	// print "Process via_rec_av_start.sh is already running";
// }

?>
