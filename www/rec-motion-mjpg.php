<?php
$output = 0;
//$output= system ('python /home/pi/viamybox/www/scripts/mov.py',$retval);
$ps = exec ("ps aux | grep -i 'mov.py' | grep -v grep|tr -s ' '|cut -d ' ' -f 2");
// echo "$ps";
if ($ps == 0) {
	Proc_Close (Proc_Open ("sudo python /home/pi/viamybox/www/scripts/mov.py --foo=1 &", Array (), $foo));
}
?>
