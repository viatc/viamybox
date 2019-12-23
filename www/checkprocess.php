<?php 
function alert($a){
echo "<script>";
echo "alert('$a');";
echo "</script>";
}

function getStatusMJPGStreamer($script_name){
	$already_started = false;
	$output = 0;
	$output = shell_exec ( 'ps aux| grep '.$script_name."|wc -l");
	if ($output >= 4) $already_started = true;
	return $already_started;
}

if(isset($_POST['script'])) {
$script_name = $_REQUEST["script"];
$return = getStatusMJPGStreamer($script_name);

$answer = array(

"movSensorHCSRPythonScript" => $return
); 
echo json_encode($answer);
exit();
}
?>