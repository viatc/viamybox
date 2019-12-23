<?php
$output = 0;
//$output= system ('python /home/pi/viamybox/www/scripts/mov.py',$retval);
Proc_Close (Proc_Open ("sudo python /home/pi/viamybox/www/scripts/mov.py --foo=1 &", Array (), $foo));
//echo "<pre>$output</pre>";
?>
