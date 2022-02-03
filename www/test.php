<?php
$output = NULL;
$retval = NULL;
$ps = exec ("ps aux | grep -i 'via_rec_audio_start.sh' | grep -v grep|tr -s ' '|cut -d ' ' -f 2");
if ($ps == 0) {
	$cmd = "sudo /home/pi/viamybox/www/scripts/via_rec_audio_start.sh";
	exec($cmd ." >/dev/null &",$output,$retval);
	// print_r(array($output,$retval));
}
else {
	print "Process via_rec_audio_start.sh is already running";
}
// if ($retval == 151) {
	// print "Process via_rec_audio_start.sh is already running";
// }
// var_dump(http_response_code(157));
// $a = http_response_code();
// $b = http_response_code(202);
// return $b;
// $c = http_response_code();
// http_response_code(202);
// var_dump($b);
// header('Status: 404', TRUE, 404);
// exit (156);
?>

