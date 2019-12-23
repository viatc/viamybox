<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!--/******************************************************************************************
	 Copyright (C) 2017-2019 ViaMyBox viatc.msk@gmail.com
	 This file is a part of ViaMyBox free software: you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation, either version 3 of the License, or
     any later version.

	 You should have received a copy of the GNU General Public License
     along with ViaMyBox in /home/pi/COPIYNG file.
	 If not, see <https://www.gnu.org/licenses/>.
*******************************************************************************************/-->
	<!-- 
	-->
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Cache-Control" content="no-cache" />
<title>ViaMyBox home site</title>
<link rel="stylesheet" href="style.css?v1" type="text/css" />
<link rel="stylesheet" href="fixed-navigation-bar.css">

    <script type="text/javascript" src="jquery.js"></script>
    <script type="text/javascript" src="jquery.rotate.js"></script>

	<title>Bootstrap Toggle</title>
	<!-- <link rel="canonical" href="http://www.viamybox.com"> -->
	<link href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.3/styles/github.min.css" rel="stylesheet" >
	<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css" rel="stylesheet">
	<link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css" rel="stylesheet">
	<link href="css/bootstrap-toggle.css" rel="stylesheet">
	<script src="https://code.jquery.com/jquery-2.1.1.min.js"></script>

    <script type="text/javascript">
var objMJPGStreamer = {movSensorHCSRPythonScript:false,alreadyStarted:false};

jQuery.fn.center = function () {
    this.css("position","absolute");
    this.css("top", (($(window).height() - this.outerHeight()) / 2) + $(window).scrollTop() + "px");
    this.css("left", (($(window).width() - this.outerWidth()) / 2) + $(window).scrollLeft() + "px");
    return this;
}

    var phi = 0, flipped = 0, mirrored = 0;
		function setXformClass () {
		$('.xform').each(function(idx,el) {
			el.className = "xform x" +(flipped ? "-flipped":"") + (mirrored ? "-mirrored" : "") + "-rotated-" + phi;
		});
	}
    $(document).ready(function() {
		// set rotation angle phi and toggle rotate class
		$('#rotate').click(function() {
			phi = (phi + 90) % 360;
			setXformClass();
			if (phi % 180) {
				$('.xform-p').addClass('rotated');
			} else {
				$('.xform-p').removeClass('rotated');
			}
		});
		// toggle mirror class component
		$('#mirror').click(function() {
			mirrored = ! mirrored;
			setXformClass();
		});
		// toggle flip class component
		$('#flip').click(function() {
			flipped = ! flipped;
			setXformClass();
		});

		$("#rec-a").click(function(){
		var strPNG = $("#rec-a").css('background-image');
		var strImg = strPNG.indexOf("rec-red-a.gif");
		if (strImg == -1 ) {
		$("#rec-a").css('background-image', 'url(rec-red-a.gif)');
		}
		else {
		 $("#rec-a").css('background-image', 'url(rec-a.png)');
		}
                $.ajax({
                    url: 'rec-a.php',
                    complete: function(data){
                    }
                });
            })   
			
			$("#rec-av").click(function(){
		var strPNG = $("#rec-av").css('background-image');
		var strImg = strPNG.indexOf("rec-red-av.gif");
		if (strImg == -1 ) {
        	 $("#rec-av").css('background-image', 'url(rec-red-av.gif)');
		}
		else {
		 $("#rec-av").css('background-image', 'url(rec-av.png)');
		}
                $.ajax({
                    url: 'rec-av.php',
                    complete: function(data){
                    }
                });
            })


		$("#restart_mjpg").click({param1:'start_stop_mjpgstrm.php'}, restart_mjpg_func);
		
		function restart_mjpg_func(event,param1)
		{
		event.preventDefault();
		var checkedPosition = $('#toggle-event').prop('checked');
 		if (checkedPosition == true && this.id == 'restart_mjpg') {
			confirm ('Recording! \n \rTurn off recording with movement sensor, before turning viewing mode off!');
			return;
		}
		strPNG = $("#rec-av").css('background-image');
		var strImg = strPNG.indexOf("rec-av.png");
		if (strImg == -1 ) {
			confirm ('Recording! \n \rStop video recording before turning viewing mode on-off!');
			return;
		}
		//if (checkedPosition == true && window.objMJPGStreamer.alreadyStarted == true) {
		var imgObj = $("#loadImg");
		imgObj.show();
		imgObj.center();
		$.ajax({
			url: event.data.param1,
			complete: function(data){
		    $("#loadImg").hide();
		    $("#stream1").load('cameraframe.php #stream1');
		    }
                });
            }
			
		function restart_motion (event) {
		<?php 
		$result = explode(":", $_SERVER['HTTP_REFERER']);
		$result =  explode("/", $result[1]);
		?>
		//alert(event.type + " на " + event.currentTarget + "target = " + event.target.tagName + " this= " + this.tagName + "this id = " + this.id);
		var checkedPosition = $(this).prop('checked');
		//console.log(checkedPosition);
		if (checkedPosition == true) {
			var doThisPHP = "rec-motion-mjpg.php"
			//console.log("event.type = "+event.type);
				$.ajax({
				url:'checkmjpgstreamer.php',
				type:'POST',
				data:"started=abc",
				dataType:'json',
				success: function(result) {
				window.objMJPGStreamer = result;
				//console.log("alreadyStarted in function = "+window.objMJPGStreamer.alreadyStarted);
				if (objMJPGStreamer.alreadyStarted == false) {
					restart_mjpg_func(event,{param1:'start_stop_mjpgstrm.php'});
				}
				//alert(objMJPGStreamer.alreadyStarted);
				}
			});
			console.log("alreadyStarted = "+window.objMJPGStreamer.alreadyStarted);

		} else {
			var doThisPHP = "rec-motion-mjpg-stop.php"
			if (objMJPGStreamer.alreadyStarted == false) {
				restart_mjpg_func(event,{param1:'start_stop_mjpgstrm.php'});
			}
		}

		$.ajax({
				url: "http://<?=str_replace("/","",$result[2]);;?>/" + doThisPHP,
                type: "post",
                datatype: "html",
                data: {foo: 'bar', bar: 'foo'},
                success: function(response){
                        $("#div").html(response);
                        //console.log("There is a response");
                }
                });
//		debugger;
		//$('#console-event').html('Toggle: ' + $(this).prop('checked'));
		}

	function checkMovShell(){
			//alert('!!!!!');
			$.ajax({
				url:'checkprocess.php',
				type:'POST',
				data:"script=mov.py",
				dataType:'json',
				success: function(result) {
				window.objMJPGStreamer = result;
				//console.log("alreadyStarted in function checkMovShell = "+window.objMJPGStreamer.movSensorHCSRPythonScript);
				if (objMJPGStreamer.movSensorHCSRPythonScript == true) {
				$('#toggle-event').prop('checked', true).bootstrapToggle('destroy').bootstrapToggle();
				}
				}
			});
	}
    $('#toggle-event').change({param1:'start_stop_mjpgstrm.php'}, restart_motion);
	checkMovShell();
	
	});
	</script>

</head>

<body>

<div id=content>

  <p>
    <button id="rotate" title="flip the picture">
    <div class="btnface"></div>
    <button id="mirror" title="mirror left-right">
    <div class="btnface"></div>
    <button id="flip" title="mirror top-down">
    <div class="btnface"></div>
    <button id="rec-a" title="webcam audio recording">
    <div class="btnface"></div>
    <button id="rec-av" title="Record video from webcam">
    <div class="btnface"></div>
    <button id="restart_mjpg" title="start-stop web server mjpg-streamer ">
    <div class="btnface"></div>
</form>	
    </button>
  </p>

<div class="border1">
	<input id="toggle-event" class="hcr" type="checkbox" data-toggle="toggle"  data-size="mini" data-style="slow" <p> Record video stream when motion is detected </p>
<div id="console-event"></div>
<script>

</script>
</div>

  <p>&nbsp;</p>
  <p>&nbsp;</p>
  <p>&nbsp;</p>
<?php 
$result = explode(":", $_SERVER['HTTP_REFERER']);
$result = explode("/", $result[1]);
?>


<div id="stream1">
	<img id=loadImg class=loadImg src="ajax_loader_blue_32.gif"/>
	<b class="loading"></b>
	<p><img id="streamimage" class="xform" src="http://<?=str_replace("/","",$result[2]);;?>:8080/?action=stream" />	</p>
</div>
<p>&nbsp;</p>
<p>&nbsp;</p>

	<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.3/highlight.min.js"></script>
	<script src="doc/script.js"></script>
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
	<script src="js/bootstrap-toggle.js"></script>
</div>
</body>

</html>
