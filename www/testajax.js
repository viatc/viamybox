$(document).ready(function(){
	    $("#info").click(function(e){
		alert("OK");
	        e.preventDefault();
	        var el = $(this);
	        var img = $("<img>");
	        img.attr("src", "ajax_loader_blue_32.gif");
	        el.html("").append(img);
	        $.ajax({
	            url: el.attr("href"),
	            success: function(data){
	                el.html(data);
	            }
	        });
	    })
});
