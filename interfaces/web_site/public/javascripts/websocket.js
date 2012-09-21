var connectionAttempts = 0;
var socketServer = window.location.hostname;
//var socket_server = "10.0.1.6"
var webSocketConnection = {};
var timeUpdater;
var statusTimer;
var playState;

$(function(){
	
	if(!("WebSocket"||"MozWebSocket" in window)){
		alert("You don’t have WebSockets");
	} else {
		openWebSocketConnection();
	}
	
	// setInterval(openWebSocketConnection,15000);	
})



function openWebSocketConnection(){

  try {

    if (webSocketConnection.readyState === undefined || webSocketConnection.readyState > 1) {
			// Connect to the web socket server
			var uri = "ws://" + socketServer + ":8084";
			if ("WebSocket" in window) {
				webSocketConnection = new WebSocket(uri);
			} else if ("MozWebSocket" in window) {
				webSocketConnection = new MozWebSocket(uri);
			}

			// Called every time the browser loads/refreshes a page
			// The web sever loads all the current info on the page
			// So we don't actually need to do anything
      webSocketConnection.onopen = function(){
        console.log("Socket opened");
      }

			// Process the update messages the server broadcasts
			// See SocketDispatcher class for the format of these messages
      webSocketConnection.onmessage = function(msg){ 
		console.log("web socket receiving message");
		console.log(msg);
		
        data = JSON.parse(msg.data);

		// Update player State
		for (var key in data){
			switch(key){
				case "state":
					$("#state").text(data[key]);
					break;
        case "progress":
          $("#track_position").val(data[key]);
					break;
        case "play":
          break;

				case "notification":
					$("#state").text(data[key]);
					break;
					
				case "response":
					if (data["response"]["action"] == "track"){
					
						console.log("track info!");
						console.log(data["response"]["track"]);
					}
					
					break;
					
				default: console.error('Unrecognised action: '+key);
			}
		}
		
        //for (var key in data) {
        //  switch(key) {
        //    case "state":
        //      updatePlayPauseButton(data[key]);
		//					break;
		//				case "time":
        //      updateCurrentTime(data[key]);
        //      break;
        //    case "rating":
        //      updateRating(data[key]);
        //      break;
        //    case "track_added":
        //      addStatusUpdate(data[key]);
        //      break;
		//				case "raters":
		//					setVotedState(data[key]);
		//					break;
		//				case "track": // The track has changed
		//					updateCurrentSong(data[key]);
		//					break;
		//				case "playlist": // Track added or removed
		//					updatePlaylist(data[key]);
		//					break;
		//				case "volume":
		//				  volume.slider({value: data[key]});
		//				  break;
		//				case "refresh":
		//					window.location.reload(true); // force the browser to reload the page from the server (not from cache)
        //      break;
        //    default: console.error('Unrecognised action: '+key);
        //  }
        //}
      }

			// Called every time a browser closes/refreshes a page 
			// or connection to the Web Socket Server is lost
			// Automatically tries to reconnect, increasing the wait time on each attempt by a second
      webSocketConnection.onclose = function(){
			console.log("Socket closed");
			clearInterval(timeUpdater); // stop the progress bar if it’s running
			//if (socketServer != 'jukebox') socketServer = 'jukebox'; // if no local server try the jukebox
			setTimeout(openWebSocketConnection, connectionAttempts * 1000);
			connectionAttempts++;
			console.log("WSS connection attempt: "+ connectionAttempts);
      }    
    }
  } catch(exception) {
    throw(exception);
  }
}
