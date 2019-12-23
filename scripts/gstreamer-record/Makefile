CC=gcc
LIBS=`pkg-config gstreamer-1.0 --libs`
CFLAGS=`pkg-config gstreamer-1.0 --cflags`
FILE=via-rec-av-c270
FILE2=via-rec-audio

all:
	$(CC) $(LIBS) $(CFLAGS) $(FILE).c -o $(FILE)
	$(CC) $(LIBS) $(CFLAGS) $(FILE2).c -o $(FILE2)
#	$(CC) $(LIBS) $(CFLAGS) via-rec-av-c910-1.c -o via-rec-av-c910-1
#	$(CC) $(LIBS) $(CFLAGS) via-rec-av-c910-2.c -o via-rec-av-c910-2
#	$(CC) $(LIBS) $(CFLAGS) temp.c -o temp
#	$(CC) $(LIBS) $(CFLAGS) test4-4.c -o test4-4
install:
	install ./$(FILE) /sbin
	install ./$(FILE2) /sbin
#	install ./via-rec-av-c910-2 /sbin