/******************************************************************************************
	 Copyright (C) 2017-2019 ViaMyBox viatc.msk@gmail.com
	 This file is a part of ViaMyBox free software: you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation, either version 3 of the License, or
     any later version.
																				
     ViaMyBox software is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License for more details.
                                                                           
	 You should have received a copy of the GNU General Public License
     along with ViaMyBox in /home/pi/COPIYNG file.
	 If not, see <https://www.gnu.org/licenses/>.
	                                             
*******************************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <gst/gst.h>
#include <signal.h>
#include <glib.h>
#include <unistd.h>
#include <time.h>

#define RECORD_DIR "/home/pi/camera/video/"
//time in seconds of file switching duration
#define FILE_DURATION 3600
#define FRAMERATE "5/1"
#define AUDIOSOURCE "plughw:1,0"

//запись с переключением файлов


static GstElement *pipeline;
static GstElement * muxer, *src, *alsasrc, *audioconvert, *vorbisenc;
static GstElement * sink;
static GstElement *q1, *q2v, *q2a;
static int i=0;
GstElement * bin;
GstPad *muxerSinkPadV,*muxerSinkPadA;
gulong probeId,probeId2;
char file_location[100];

typedef struct _StreamInfo{
  GMainLoop *loop;
  gboolean pipelineEOS;
  int restartPipelineAfterNtimes;
// GstClockTime buff;
  } StreamInfo;
StreamInfo si;
//static GQueue effects = G_QUEUE_INIT;

void CreateNewBin(StreamInfo *si);
void DestroyBin();
void ChangeLocation();
void RemovePad();

static gboolean handle_keyboard (GIOChannel *source, GIOCondition cond, StreamInfo *data) {
  gchar *str = NULL;

  if (g_io_channel_read_line (source, &str, NULL, NULL, NULL) != G_IO_STATUS_NORMAL) {
    return TRUE;
  }
  switch (g_ascii_tolower (str[0])) {
    case 'p':
 //   data->playing = !data->playing;
 //   gst_element_set_state (data->pipeline, data->playing ? GST_STATE_PLAYING : GST_STATE_PAUSED);
 
    g_print ("P button pressed\n");
    break;
	default:
    break;
  }

  g_free (str);

  return TRUE;
}
  
void sigintHandler(int signal) {
	switch (signal) {
		case SIGINT:
			g_print("You ctrl-c-ed! Sending EoS\n");
			si.pipelineEOS = TRUE;
			gst_element_send_event(pipeline, gst_event_new_eos());
			g_main_loop_quit (si.loop);
			break;
			
		case SIGALRM:
			g_print("You alarmed\n");
			break;
		default:
            g_print("Caught wrong signal: %d\n", signal);
            return;
	}		
}

char *currentDateTime(void) {
    time_t     now;
    struct tm  *tstruct;
    static char       buf[20];
	time (&now);
    tstruct = localtime(&now);
    strftime(buf, sizeof(buf), "%Y-%m-%d_%H-%M-%S", tstruct);
	return strdup(buf);
}

char *fileLocation(void)
{
	char first[] = RECORD_DIR;
	char name[] = "gstreamer-av-";
	char end[] = ".mkv";
    char *time = currentDateTime();
	
	strcpy(file_location,first);
	strcat(file_location,name);
	strcat(file_location,time);
	strcat(file_location,end);
	return file_location; 
}

static GstPadProbeReturn
EOS_probe_cb (GstPad * pad, GstPadProbeInfo * info, gpointer user_data)
{

	GstPad *sinkPadV = gst_element_get_static_pad(bin, "videosink");
	gst_pad_unlink(pad, sinkPadV);
	gst_pad_send_event(sinkPadV, gst_event_new_eos());
	gst_object_unref(sinkPadV);

	return GST_PAD_PROBE_OK;
}

static GstPadProbeReturn
EOS_probe_cbA (GstPad * pad, GstPadProbeInfo * info, gpointer user_data)
{

	GstPad *sinkPadA = gst_element_get_static_pad(bin, "audiosink");
	gst_pad_unlink(pad, sinkPadA);
	gst_pad_send_event(sinkPadA, gst_event_new_eos());
	gst_object_unref(sinkPadA);

	return GST_PAD_PROBE_OK;
}

static gboolean
timeout_cb (gpointer user_data)
{
	static int i=0;
	if(i==0)
	{
		//i++;
		GstPad *q2vSrcPad, *q2aSrcPad;
		gint64 offset;
		si.pipelineEOS = FALSE;
		q2vSrcPad = gst_element_get_static_pad(q2v, "src");
		g_print(" timeout_cb: ");
		probeId = gst_pad_add_probe (q2vSrcPad, GST_PAD_PROBE_TYPE_BLOCK_DOWNSTREAM,
				EOS_probe_cb, user_data, NULL);
				
		q2aSrcPad = gst_element_get_static_pad(q2a, "src");
		probeId2 = gst_pad_add_probe (q2aSrcPad, GST_PAD_PROBE_TYPE_BLOCK_DOWNSTREAM,
				EOS_probe_cbA, user_data, NULL);		
				
		gst_object_unref(q2vSrcPad);
		gst_object_unref(q2aSrcPad);
		


		return TRUE;
	}
return FALSE;
}

//---------------------------------------------------------------------------------------BUS
static gboolean
bus_cb (GstBus * bus, GstMessage * msg, gpointer user_data)
{
	GMainLoop *loop = (GMainLoop*)user_data;

	switch (GST_MESSAGE_TYPE (msg)) {
	case GST_MESSAGE_ERROR:{
		GError *err = NULL;
		gchar *dbg;

		gst_message_parse_error (msg, &err, &dbg);
		gst_object_default_error (msg->src, err, dbg);
		g_error_free (err);
		g_free (dbg);
		g_main_loop_quit (loop);
		break;
	}
	case GST_EVENT_EOS:
		g_print ("EOS message is got" );
		break;

	case GST_MESSAGE_SEGMENT_DONE:
		g_print ("GST_MESSAGE_SEGMENT_DONE message is got" );
		break;
	case GST_MESSAGE_ELEMENT:
	{
		const GstStructure *s = gst_message_get_structure (msg);

		if (gst_structure_has_name (s, "GstBinForwarded"))
		{
			GstMessage *forward_msg = NULL;
			gst_structure_get (s, "message", GST_TYPE_MESSAGE, &forward_msg, NULL);
			if (GST_MESSAGE_TYPE (forward_msg) == GST_MESSAGE_EOS)
			{
				if (!si.pipelineEOS) {
				g_print ("EOS from element %s\n",
				GST_OBJECT_NAME (GST_MESSAGE_SRC (forward_msg)));

				DestroyBin();
				CreateNewBin(&si);
				RemovePad();

				}
				else
				{
				g_main_loop_quit (loop);
				}
				
			}
			gst_message_unref (forward_msg);
		}
	}
		break;

	default:
		break;
	}
	return TRUE;
}
//---------------------------------------------------------------------------------------MAIN
int
main (int argc, char **argv)
{
	GIOChannel *io_stdin; 
	GError *err = NULL;

	GstElement /* *q2v,*/ /**effect,*/ /**filter1*//*, *filter2*/ *encoder,/*, *sink*/
	*videoconvert,*videorate, *parse, *capsfilter, *capsfilteromx, *clockoverlay;
	StreamInfo si;

	gst_init(&argc, &argv);
	si.restartPipelineAfterNtimes = 0;

	
	struct sigaction sa;
	sa.sa_handler = &sigintHandler;
	sigaction(SIGINT, &sa, NULL);
	
	pipeline = gst_pipeline_new ("pipeline");

	
	src = gst_element_factory_make ("v4l2src", NULL);
	alsasrc = gst_element_factory_make("alsasrc",NULL);
	vorbisenc = gst_element_factory_make("vorbisenc",NULL);
	audioconvert = gst_element_factory_make( "audioconvert", "audioconvert");
	
	
	capsfilter = gst_element_factory_make("capsfilter", NULL);
	videoconvert = gst_element_factory_make("videoconvert", NULL);
	videorate = gst_element_factory_make("videorate", NULL);
	encoder = gst_element_factory_make ("omxh264enc", NULL);
	capsfilteromx = gst_element_factory_make("capsfilter", NULL);
	clockoverlay = gst_element_factory_make("clockoverlay", NULL);
	parse = gst_element_factory_make("h264parse", NULL);
	q2v = gst_element_factory_make("queue", NULL);
	q2a = gst_element_factory_make("queue", NULL);
	q1 = gst_element_factory_make ("queue", NULL);

	//Create a caps filter between videosource videoconvert
/* 	char capsString[] = "video/x-raw,format=YV12,width=320,height=240,framerate=5/1";
	GstCaps * dataFilter = gst_caps_from_string(capsString); */

 	GstCaps *caps;
	
	char str[100];
	// char first[] = "video/x-raw,format=YV12,width=640,height=480,framerate=";
	char first[] = "video/x-raw,framerate=";
	char end[] = FRAMERATE;
	strcpy(str,first);
	strcat(str,end);
//	g_print("%s\n",str);

	g_object_set( G_OBJECT(alsasrc), "device", AUDIOSOURCE, "do-timestamp", TRUE, "provide-clock", FALSE, /* "num-buffers" , 1000, "rate", 8000, "buffer-time",80000,*/ NULL);
//	caps = gst_caps_from_string ("video/x-raw,format=YV12,width=640,height=480,framerate=25/1");
	caps = gst_caps_from_string (str);
	g_object_set (capsfilter, "caps", caps, NULL);
	gst_caps_unref(caps);

    char first2[] = "video/x-h264,stream-format=byte-stream,framerate=";
	strcpy(str,first2);
	strcat(str,end);
//	g_print("%s\n",str);
	
//	caps = gst_caps_from_string ("video/x-h264,stream-format=byte-stream,framerate=25/1");
	caps = gst_caps_from_string (str);
//	g_object_set(G_OBJECT(src), "do-timestamp", 1, NULL);
	g_object_set (capsfilteromx, "caps", caps, NULL);
	gst_caps_unref(caps);
	
//	g_object_set(q2a, "leaky", 2, "max-size-buffers", 0, "max-size-time", 0, "max-size-bytes", 0, NULL);
	g_object_set(q2a, "leaky", 1, NULL);
	g_object_set (G_OBJECT (clockoverlay), "time-format","%d-%b-%Y / %H:%M:%S",NULL);
	//blockpad = gst_element_get_static_pad(q2v, "src");

	gst_bin_add_many(GST_BIN(pipeline), src, q1, capsfilter, videoconvert, videorate, clockoverlay, encoder, capsfilteromx, parse, q2v,
										alsasrc, audioconvert, vorbisenc, q2a, 0);

	if (!gst_element_link_many(src, q1, capsfilter, videoconvert, videorate, clockoverlay, encoder, capsfilteromx, parse, q2v, NULL)){
		g_error("Failed to link elements");
		return -2;
	}
	
	if (!gst_element_link_many(alsasrc, audioconvert, vorbisenc, q2a, NULL)){
		g_error("Failed to link elements");
		return -2;
	}
//	g_print(" MAIN si.buff %d \n",si.buff);
	CreateNewBin(&si);

  /* Add a keyboard watch so we get notified of keystrokes */
	#ifdef G_OS_WIN32
	io_stdin = g_io_channel_win32_new_fd (fileno (stdin));
	#else
	io_stdin = g_io_channel_unix_new (fileno (stdin));
	#endif
	g_io_add_watch (io_stdin, G_IO_IN, (GIOFunc)handle_keyboard, &si);
	
	gst_element_set_state (pipeline, GST_STATE_PLAYING);

	si.loop = g_main_loop_new (NULL, FALSE);

	gst_bus_add_watch (GST_ELEMENT_BUS (pipeline), (GstBusFunc)bus_cb, si.loop);
	
	g_timeout_add_seconds (FILE_DURATION, timeout_cb, &si);
	
	g_main_loop_run (si.loop);

	//free resources
	gst_element_set_state (pipeline, GST_STATE_NULL);
	g_main_loop_unref (si.loop);
	g_io_channel_unref (io_stdin);
	gst_object_unref (pipeline);

	return 0;
}


void RemovePad()
{
	GstPad *q2vSrcPad,*q2aSrcPad;
	q2vSrcPad = gst_element_get_static_pad(q2v, "src");
	q2aSrcPad = gst_element_get_static_pad(q2a, "src");
	gst_pad_remove_probe(q2vSrcPad, probeId);
	gst_pad_remove_probe(q2aSrcPad, probeId2);
	gst_object_unref(q2vSrcPad);
	gst_object_unref(q2aSrcPad);
}

void DestroyBin()
{
	gst_element_set_state(bin, GST_STATE_NULL);
	gst_bin_remove(GST_BIN(pipeline), bin);
	gst_element_set_state(pipeline, GST_STATE_READY);
	gst_element_set_state(pipeline, GST_STATE_PLAYING);
	}

void CreateNewBin(StreamInfo *si)
{

	static char fileLocPattern[] = "deneme%d.mkv";
	char buffer[12];
	memset(buffer, 0, sizeof(buffer));
	sprintf(buffer, fileLocPattern, i++);

	muxer = gst_element_factory_make("matroskamux", "MatroskaMuxer");
	sink = gst_element_factory_make("filesink", fileLocation());
//	g_object_set(G_OBJECT(muxer), "streamable", TRUE, 0);
	bin = gst_bin_new(buffer);

	g_object_set(G_OBJECT(sink), "location", fileLocation(), "async", FALSE, 0);
	g_object_set(G_OBJECT(bin), "message-forward", TRUE, 0);

	gst_bin_add_many(GST_BIN(bin), muxer, sink, 0);

	gboolean linkState = TRUE;

	linkState &= gst_element_link_many(muxer, sink, 0);

	gst_bin_add(GST_BIN(pipeline), bin);


	{
		GstPadTemplate *muxerSinkPadTemplateV, *muxerSinkPadTemplateA;


		if( !(muxerSinkPadTemplateV = gst_element_class_get_pad_template(GST_ELEMENT_GET_CLASS(muxer), "video_%u")) )
		{
			g_print ("Unable to get source pad template from muxing element" );
		}
/* 		if( !(muxerSinkPadTemplateA = gst_element_class_get_pad_template(GST_ELEMENT_GET_CLASS(muxer), "audio_%u")) )
		{
			g_print ("Unable to get source pad template from muxing element" );
		}	 */

		muxerSinkPadV = gst_element_request_pad(muxer, muxerSinkPadTemplateV, 0, 0);
		muxerSinkPadA = gst_element_get_request_pad(muxer, "audio_%u");


		GstPad * ghostPadV = gst_ghost_pad_new("videosink", muxerSinkPadV);
		GstPad * ghostPadA = gst_ghost_pad_new("audiosink", muxerSinkPadA);
		gst_element_add_pad(bin, ghostPadV);
		gst_element_add_pad(bin, ghostPadA);
		gst_object_unref(GST_OBJECT(muxerSinkPadV));
		gst_object_unref(GST_OBJECT(muxerSinkPadA));

		gst_element_sync_state_with_parent(bin);

		GstPad *queueBeforeBinSrcPadV = gst_element_get_static_pad(q2v, "src");
		GstPad *queueBeforeBinSrcPadA = gst_element_get_static_pad(q2a, "src");

		//Link queuebeforebin to ghostpad
		if (gst_pad_link(queueBeforeBinSrcPadV, ghostPadV) != GST_PAD_LINK_OK )
		{

			g_print( "QueueBeforeBin cannot be linked to MuxerSinkPad." );
			//TODO :: throw an exception here
		}
		if (gst_pad_link(queueBeforeBinSrcPadA, ghostPadA) != GST_PAD_LINK_OK )
		{

			g_print( "QueueBeforeBin cannot be linked to MuxerSinkPad." );
			//TODO :: throw an exception here
		}
		gst_object_unref(queueBeforeBinSrcPadV);
		gst_object_unref(queueBeforeBinSrcPadA);
	}

}