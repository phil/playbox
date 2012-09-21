$(function(){
	
	$('a.play_button').click(function(e){
		e.preventDefault();
		play();
	});
	$('a.pause_button').click(function(e){
		e.preventDefault();
		pause();
	});
	
	$("a.next_button").click(function(e){
		e.preventDefault();
		next();
		//return false;
	});
	
	$("a.add_track_button").click(function(e){
		//var target = $(e.target);
		e.preventDefault();
		addTrack($(e.target).attr("data-trackid"));
	});
	
	$("a.track_button").click(function(e){
		e.preventDefault();
		track($(e.target).attr("data-trackid"));
	});
});

function play(){
	webSocketConnection.send(JSON.stringify({
		"action": "play"
	}));
}

function pause(){
	webSocketConnection.send(JSON.stringify({
		"action": "pause"
	}));
}

function next(){
	webSocketConnection.send(JSON.stringify({
		"action": "next"
	}));
}

function track(trackId){
	console.log("getting track " + trackId )
	webSocketConnection.send(JSON.stringify({
		"action": "track",
		"track_id": trackId
	}));
}

function addTrack(trackId){
	webSocketConnection.send(JSON.stringify({
		"action": "add",
		"track_id": trackId
	}));
}