  #include <stdlib.h>
  #include <sys/types.h>
  #include <unistd.h>

  int
  main (int argc, char *argv[])
  {
     setuid (0);

     system ("/bin/bash /home/pi/viamybox/scripts/switchMovSensorRec.sh");

     return 0;
   }
