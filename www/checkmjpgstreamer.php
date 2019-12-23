<?php 
function alert($a){
echo "<script>";
echo "alert('$a');";
echo "</script>";
}
//global $already_started;
//   $process = new Process('/lib/systemd/systemd-logind');
function getStatusMJPGStreamer(){
	$already_started = false;
	$output = 0;
	$script_name = 'mjpg_streamer';
	$output = shell_exec ( 'ps aux| grep '.$script_name."|wc -l");
	//$output = shell_exec ( 'ps aux| grep '.$script_name);
//	echo "<pre>$output</pre>";
	if ($output >= 3) $already_started = true; 
	//else {$already_started = false;}
//	echo $already_started;
	return $already_started;
}

//$return = getStatusMJPGStreamer();

//$param = 0;
if(isset($_POST['started'])) {
$return = getStatusMJPGStreamer();
//echo $return;
//$test = $_REQUEST["started"];
//$test = "QQQQQQQQ";
//alert($test);
//echo("<script>console.log('PHP: ".$test."');</script>");
$answer = array(
"alreadyStarted" => $return
); 
echo json_encode($answer);
exit();
}

// $param = json_decode($_POST['param']);
 //$already_started = get_text($param->started);
// echo json_encode(array(started => getStatusMJPGStreamer()));
//echo boolval($return);
/* $out = json_encode(array(//где нибудь перед else
    as => getStatusMJPGStreamer(); //присваиваем переменным в объекте,
));
echo $out; */

//getStatusMJPGStreamer();
//echo $already_started;

#exec ( 'ps -aux| grep '.$script_name , $output, $retval);
//if $output > 3 return true else false;
/*     $process = new Process();
    $process->setPid('27405');

	$process->status() ? print 'true' : print 'status  = false'."\n";
    $my_pid = $process->getPid();
	echo 'my_pid=',$my_pid,"\n"; */
	
    // or if you got the pid, however here only the status() metod will work.
//    $process = new Process();
//	if ($process->status()) echo 'true';
?>