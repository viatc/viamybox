  #include <stdlib.h>
  #include <sys/types.h>
  #include <unistd.h>

  int
  main (int argc, char *argv[])
  {
     setuid (0);

     /* WARNING: Only use an absolute path to the script to execute,
      *          a malicious user might fool the binary and execute
      *          arbitary commands if not.
      * */

     system ("/bin/sh /home/pi/viamybox/www/scripts/start_stop_mjpgstrm.sh");

     return 0;
   }
