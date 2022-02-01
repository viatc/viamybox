<?php
$output = 0;
$output_dir = '/tmp/viamybox';
if (!is_dir($output_dir)) {
  if (!mkdir($output_dir, 0755, true))
    die("Failed to create directory $output_dir");
}

$key = '--startkodi';
$date = new DateTime();
$date = $date->format("y:m:d h:i:s");
$command = sprintf("sudo /home/pi/viamybox/scripts/control-services.sh %s",
  escapeshellarg($key));
// $command = sprintf("sudo /home/pi/viamybox/scripts/control-services.sh --startkodi");

$descriptors = [
  1 => ['pipe', 'w'], // stdout
  2 => ['file', "$output_dir/control-services.log", "a"], // stderr
];

$proc = proc_open($command, $descriptors, $pipes);
if (!is_resource($proc))
  die("Failed to open process for command $command");

/* if ($output = stream_get_contents($pipes[1]))
  echo "Output: $output\n\n";
fclose($pipes[1]); */

/* if ($errors = stream_get_contents($pipes[2]))
   echo "Errors: >>>>>>>>\n$errors\n<<<<<<<\n\n";
 fclose($pipes[2]); */

$exit_code = proc_close($proc);

if ($exit_code != 0) {
  die("Failed to execute control-services.sh... $output_dir/control-services.log");
}

?>
