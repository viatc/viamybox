/******************************************************************************************
	 Copyright (C) 2017-2019 ViaMyBox viatc.msk@gmail.com
	 This file is a part of ViaMyBox free software: you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation, either version 3 of the License, or
     any later version.

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

#define RECORD_DIR "/home/pi/camera/audio/"
//#define RECORD_DIR "/home/www/scripts/"
#define FILE_DURATION 3600
#define FRAMERATE "25/1"

//предыдущий рабочий via-rec-audio1.c


static gchar *opt_effects = NULL;


//static GstPad *blockpad;
//static GstElement *conv_before;
//static GstElement *conv_after;
//static GstElement *cur_effect;
static GstElement *pipeline;
static GstElement * muxer, *src, *alsasrc, *audioconvert, *vorbisenc;
static GstElement * sink;
static GstElement *q1, *q2;
static int i=0;
GstElement * bin;
GstPad * muxerSinkPad;
gulong probeId,probeId2;
char file_location[100];

typedef struct _StreamInfo{
  GMainLoop *loop;
  gboolean pipelineEOS;
  int restartPipelineAfterNtimes;
  GstClockTime buff;
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
 
    g_print ("P button pressed-----------------\n");
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
/* char *currentDateTime(void) {
    time_t     now = time(0);
    struct tm  tstruct;
    static char       buf[20];
    tstruct = *localtime(&now);
    strftime(buf, sizeof(buf), "%Y-%m-%d_%H-%M-%S", &tstruct);
	return strdup(buf);
} */

char *fileLocation(void)
{
//	char first[] = "/home/www/scripts/";
	char first[] = RECORD_DIR;
	char end[] = ".mka";
    char *time = currentDateTime();
	
	strcpy(file_location,first);
	strcat(file_location,time);
	strcat(file_location,end);
	return file_location; 
}
static GstPadProbeReturn
source_buffer (GstPad          *pad,
               GstPadProbeInfo *info,
               gpointer user_data)
{
	StreamInfo *si = (StreamInfo *)user_data; 
    GstBuffer *buffer; 
    GstBufferFlags flags;

//	g_print("  si.buff %d ---- ",si->buff);
	buffer = GST_PAD_PROBE_INFO_BUFFER(info); 
    buffer = gst_buffer_make_writable(buffer); 
    flags = GST_BUFFER_FLAGS(buffer); 
	GST_PAD_PROBE_INFO_DATA(info) = buffer; 
//	g_print("si-buff: %" GST_TIME_FORMAT "--- ",si->buff);
    g_print("GST_BUFFER_PTS before %" GST_TIME_FORMAT " ",GST_BUFFER_PTS(buffer));
//	g_print("GST_BUFFER_PTS %d",GST_BUFFER_PTS(GST_PAD_PROBE_INFO_BUFFER (info)));

    if (!(flags & GST_BUFFER_FLAG_DELTA_UNIT)) { 
	g_print("Buffer is I-frame!\n");
      // save current buffer timestamp as reference 
      if (si->buff == 0) { 
      si->buff = GST_BUFFER_PTS (buffer); 
      } 
    }
    GST_BUFFER_PTS (buffer) -= si->buff;  
	
//	exit(0);
	GST_BUFFER_PTS (buffer) = 0;
	g_print("GST_BUFFER_PTS after %d \n",GST_BUFFER_PTS(buffer));
	gst_pad_remove_probe(pad, probeId2);
	return GST_PAD_PROBE_OK;
}

static GstPadProbeReturn 
  padadd_probe_cb (GstPad * pad, GstPadProbeInfo * info, /*StreamInfo *si*/ gpointer user_data) 
  { 
    StreamInfo *si = (StreamInfo *)user_data;
    GstPad *q1padSrc;
	q1padSrc = gst_element_get_static_pad(q2, "src");
//	exit(0);
	 g_print("PROBE  si.buff %d \n",si->buff);
	 probeId2 =  gst_pad_add_probe (q1padSrc, GST_PAD_PROBE_TYPE_BUFFER|
					GST_PAD_PROBE_TYPE_BLOCK,
                     (GstPadProbeCallback) source_buffer, si, NULL);

 
  } 

static GstPadProbeReturn
EOS_probe_cb (GstPad * pad, GstPadProbeInfo * info, gpointer user_data)
{
	// on retire la sonde
	//gst_pad_remove_probe(pad, GST_PAD_PROBE_INFO_ID(info));
	// cast des donnГ©es
	GstPad *sinkPad = gst_element_get_static_pad(bin, "sink");
	// deconnecte le bin
	gst_pad_unlink(pad, sinkPad);
	// injecte l'EOS
	gst_pad_send_event(sinkPad, gst_event_new_eos());
	// libГЁre les ressources
	gst_object_unref(sinkPad);
	// libГЁre le tee
	//gst_element_release_request_pad(GST_PAD_PARENT(pad), pad);

	return GST_PAD_PROBE_OK;

//	//---------------------------
//
//	GstPad *srcpad, *sinkpad;
//
//	/* remove the probe first */
//	gst_pad_remove_probe (pad, GST_PAD_PROBE_INFO_ID (info));
//
//	/* install new probe for EOS */
////	srcpad = gst_element_get_static_pad (sink, "src");
////	gst_pad_add_probe (srcpad, (GstPadProbeType)(GST_PAD_PROBE_TYPE_BLOCK |
////			GST_PAD_PROBE_TYPE_EVENT_DOWNSTREAM), event_probe_cb, user_data, NULL);
////	gst_object_unref (srcpad);
//
//	/* push EOS into the element, the probe will be fired when the
//	 * EOS leaves the effect and it has thus drained all of its data */
//	std::cout << "Send eos event" << std::endl;
//	sinkpad = gst_element_get_static_pad (bin, "sink");
//	gst_pad_send_event (sinkpad, gst_event_new_eos ());
//	//gst_element_send_event(bin, gst_event_new_eos());
//	gst_object_unref (sinkpad);
//
//	return GST_PAD_PROBE_OK;
}
//------------------------------------------------------------------------------------------TIMEOUT_CB
static gboolean
timeout_cb (gpointer user_data)
{
	static int i=0;
	if(i==0)
	{
		//i++;
		GstPad * q2SrcPad;
		gint64 offset;
		si.pipelineEOS = FALSE;
		q2SrcPad = gst_element_get_static_pad(q2, "src");
		g_print( "Timeout: ");
		probeId = gst_pad_add_probe (q2SrcPad, GST_PAD_PROBE_TYPE_BLOCK_DOWNSTREAM,
				EOS_probe_cb, user_data, NULL);

		  /* Add a probe to adjust the frame timestamps */
/* 		probeId2 = gst_pad_add_probe (q2SrcPad, GST_PAD_PROBE_TYPE_BUFFER|
                             GST_PAD_PROBE_TYPE_BLOCK,
                     (GstPadProbeCallback) source_buffer, user_data, NULL); */

		gst_object_unref(q2SrcPad);
		


		return TRUE;
	}
return FALSE;
}
//       offset = gst_pad_get_offset (q2SrcPad);
//		g_print( "offset: %f \n", offset);

//---------------------------------------------------------------------------------------BUS
static gboolean
bus_cb (GstBus * bus, GstMessage * msg, gpointer user_data)
{
	GMainLoop *loop = (GMainLoop*)user_data;
/* 		const GstStructure *m = gst_message_get_structure (msg);
		gchar *m_string = gst_structure_to_string(m); 
		g_print("structure is \n%s\n", m_string); 
		g_free(m_string);  */

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
//		gchar *s_string = gst_structure_to_string(s); 
//		g_print("structure is \n%s\n", s_string); 
//		g_free(s_string); 
//		g_print("name of structure:------------- %s\n",gst_structure_get_name (s));
		//g_print("%s\n", gst_structure_to_string(gst_message_get_structure(msg)));
		if (gst_structure_has_name (s, "GstBinForwarded"))
		{
			GstMessage *forward_msg = NULL;
			gst_structure_get (s, "message", GST_TYPE_MESSAGE, &forward_msg, NULL);
			if (GST_MESSAGE_TYPE (forward_msg) == GST_MESSAGE_EOS)
			{
				if (!si.pipelineEOS) {
				g_print ("EOS from element %s\n",
				GST_OBJECT_NAME (GST_MESSAGE_SRC (forward_msg)));
//						exit(0);
//				gst_element_set_state (sink, GST_STATE_NULL);
//				gst_element_set_state (muxer, GST_STATE_NULL);
//				//app_update_filesink_location (app);
//				ChangeLocation();
//				gst_element_set_state (sink, GST_STATE_PLAYING);
//				gst_element_set_state (muxer, GST_STATE_PLAYING);
//				/* do another recording in 10 secs time */
//				g_timeout_add_seconds (10, start_recording_cb, app);
				DestroyBin();
				CreateNewBin(&si);
				RemovePad();
				//DestroyBin();
				//ChangeLocation();
				}
				else
				{
//				g_error_free (err);
//				g_free (dbg);
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
//	GMainLoop *loop;
	GstElement /* *q2,*/ /**effect,*/ /**filter1*//*, *filter2*/ *encoder,/*, *sink*/
	*videoconvert,*videorate, *parse, *capsfilter, *capsfilteromx, *clockoverlay;
	StreamInfo si;

	gst_init(&argc, &argv);
	si.restartPipelineAfterNtimes = 0;
	si.buff = 0;
	
	struct sigaction sa;
	sa.sa_handler = &sigintHandler;
	sigaction(SIGINT, &sa, NULL);
	
	pipeline = gst_pipeline_new ("pipeline");

	
//	src = gst_element_factory_make ("v4l2src", NULL);
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
	q2 = gst_element_factory_make("queue", NULL);
	q1 = gst_element_factory_make ("queue", NULL);
	
	//g_object_set (src, "is-live", TRUE, NULL);

	//Create a caps filter between videosource videoconvert
/* 	char capsString[] = "video/x-raw,format=YV12,width=320,height=240,framerate=5/1";
	GstCaps * dataFilter = gst_caps_from_string(capsString); */

 	GstCaps *caps;
	
	char str[100];
	char first[] = "video/x-raw,format=YV12,width=640,height=480,framerate=";
	char end[] = FRAMERATE;
	strcpy(str,first);
	strcat(str,end);
	g_print("%s\n",str);

	g_object_set( G_OBJECT(alsasrc), "device", "plughw:1,0", "do-timestamp", TRUE, "provide-clock", FALSE, /* "num-buffers" , 1000, "rate", 8000, "buffer-time",80000,*/ NULL);
	
//	caps = gst_caps_from_string ("video/x-raw,format=YV12,width=640,height=480,framerate=25/1");
	caps = gst_caps_from_string (str);
	g_object_set (capsfilter, "caps", caps, NULL);
	gst_caps_unref(caps);

    char first2[] = "video/x-h264,stream-format=byte-stream,framerate=";
	strcpy(str,first2);
	strcat(str,end);
	g_print("%s\n",str);
	
//	caps = gst_caps_from_string ("video/x-h264,stream-format=byte-stream,framerate=25/1");
	caps = gst_caps_from_string (str);
//	g_object_set(G_OBJECT(src), "do-timestamp", 1, NULL);
	g_object_set (capsfilteromx, "caps", caps, NULL);
	gst_caps_unref(caps);
	
	g_object_set (G_OBJECT (clockoverlay), "time-format","%d-%b-%Y / %H:%M:%S",NULL);
	//blockpad = gst_element_get_static_pad(q2, "src");

//	gst_bin_add_many(GST_BIN(pipeline), src, q1, capsfilter, videoconvert, videorate, clockoverlay, encoder, capsfilteromx, parse, q2, 0);
	gst_bin_add_many(GST_BIN(pipeline), alsasrc, audioconvert, vorbisenc, q2, 0);

	
	/* 	gboolean link = gst_element_link_filtered(src, q1, dataFilter);
	link &= gst_element_link(q1, encoder);
	link &= gst_element_link(encoder, q2); */

	if (!gst_element_link_many(alsasrc, audioconvert, vorbisenc, q2, NULL)){
		g_error("Failed to link elements");
		return -2;
	}
	g_print(" MAIN si.buff %d \n",si.buff);
	CreateNewBin(&si);

  /* Add a keyboard watch so we get notified of keystrokes */
	#ifdef G_OS_WIN32
	io_stdin = g_io_channel_win32_new_fd (fileno (stdin));
	#else
	io_stdin = g_io_channel_unix_new (fileno (stdin));
	#endif
	g_io_add_watch (io_stdin, G_IO_IN, (GIOFunc)handle_keyboard, &si);
	
	gst_element_set_state (pipeline, GST_STATE_PLAYING);
//----------------------------	
/* 		GstPad * q2SrcPad;
		q2SrcPad = gst_element_get_static_pad(q2, "src");
	GstPad *sinkPad = gst_element_get_static_pad(sink, "sink");
	// deconnecte le bin

	//	gst_pad_unlink(q2SrcPad, sinkPad);
	// injecte l'EOS
	gst_pad_send_event(sinkPad, gst_event_new_eos()); */
//----------------------------------
	si.loop = g_main_loop_new (NULL, FALSE);

	gst_bus_add_watch (GST_ELEMENT_BUS (pipeline), (GstBusFunc)bus_cb, si.loop);
//	g_signal_connect (q2, "pad-added", G_CALLBACK(padadd_probe_cb), &si);
	
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
	GstPad * q2SrcPad;
	q2SrcPad = gst_element_get_static_pad(q2, "src");
	gst_pad_remove_probe(q2SrcPad, probeId);
	gst_object_unref(q2SrcPad);
}

void DestroyBin()
{
	gst_element_set_state(bin, GST_STATE_NULL);
	gst_bin_remove(GST_BIN(pipeline), bin);
/* 	if (si.restartPipelineAfterNtimes >= 2) {
	gst_element_set_state(pipeline, GST_STATE_NULL);
	si.restartPipelineAfterNtimes = 0;
	}
	else {
	si.restartPipelineAfterNtimes++;	
	} */
	gst_element_set_state(pipeline, GST_STATE_READY);
	gst_element_set_state(pipeline, GST_STATE_PLAYING);
	}

void CreateNewBin(StreamInfo *si)
{

	static char fileLocPattern[] = "deneme%d.mkv";
	char buffer[12];
	memset(buffer, 0, sizeof(buffer));
	sprintf(buffer, fileLocPattern, i++);

/*      if (!gst_element_seek(pipeline, 1.0, GST_FORMAT_TIME,
            (GstSeekFlags) (GST_SEEK_FLAG_SEGMENT | GST_SEEK_FLAG_FLUSH),
            GST_SEEK_TYPE_SET, 0, GST_SEEK_TYPE_NONE, GST_CLOCK_TIME_NONE)) {
        g_printerr("Seek failed!\n");
    }; */
	
	
	//Create Muxer Element
	muxer = gst_element_factory_make("matroskamux", "MatroskaMuxer");
	g_print(" CREATEBIN si.buff %d \n",si->buff);
//	g_object_set(G_OBJECT(muxer), "message-forward", TRUE, 0);

	//Create File Sink Element
	sink = gst_element_factory_make("filesink", fileLocation());
	//GstPad * ghostPadSink = gst_ghost_pad_new_no_target("src", GST_PAD_SRC);
	//gst_element_add_pad(fileSink, ghostPadSink);
//	g_object_set(G_OBJECT(muxer), "streamable", TRUE, 0);
	g_object_set(G_OBJECT(sink), "location", fileLocation(), "async", FALSE, 0);

	//Create muxsinkBin
	bin = gst_bin_new(buffer);
	g_object_set(G_OBJECT(bin), "message-forward", TRUE, 0);
	//Add a src pad to the bin
	//GstPad * srcPadFromSink = gst_element_get_static_pad(fileSink, "src");
	//GstPad * srcPadFromBin = gst_ghost_pad_new("src", srcPadFromSink);
//	GstPad * ghostPad = gst_ghost_pad_new_no_target("src", GST_PAD_SRC);
//	gst_element_add_pad(bin, ghostPad);
	gst_bin_add_many(GST_BIN(bin), muxer, sink, 0);

	gboolean linkState = TRUE;
	//Connect elements within muxsink_bin
	//Link: matroskamuxer -> filesink
	linkState &= gst_element_link_many(muxer, sink, 0);

	//Add this bin to pipeline
	gst_bin_add(GST_BIN(pipeline), bin);
//	gst_element_set_base_time (src,0);
//	gst_element_set_start_time (src,0);

	//Create ghostpad and manually link muxsinkBin and remaining part of the pipeline
	{
		GstPadTemplate * muxerSinkPadTemplate;


		if( !(muxerSinkPadTemplate = gst_element_class_get_pad_template(GST_ELEMENT_GET_CLASS(muxer), "audio_%u")) )
		{
			g_print ("Unable to get source pad template from muxing element" );
		}

		//Obtain dynamic pad from element
		muxerSinkPad = gst_element_request_pad(muxer, muxerSinkPadTemplate, 0, 0);

		//Add ghostpad
		GstPad * ghostPad = gst_ghost_pad_new("sink", muxerSinkPad);
		gst_element_add_pad(bin, ghostPad);
		gst_object_unref(GST_OBJECT(muxerSinkPad));

		gst_element_sync_state_with_parent(bin);

		//Get src pad from queue element
		GstPad * queueBeforeBinSrcPad = gst_element_get_static_pad(q2, "src");

		//Link queuebeforebin to ghostpad
		if (gst_pad_link(queueBeforeBinSrcPad, ghostPad) != GST_PAD_LINK_OK )
		{

			g_print( "QueueBeforeBin cannot be linked to MuxerSinkPad." );
			//TODO :: throw an exception here
		}
		gst_object_unref(queueBeforeBinSrcPad);
	}

//	gst_element_set_state(muxer, GST_STATE_PLAYING);
//	gst_element_set_state(sink, GST_STATE_PLAYING);
	//gst_element_set_state(bin, GST_STATE_PLAYING);

}