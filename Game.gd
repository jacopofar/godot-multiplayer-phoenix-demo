extends TileMap


var _client = WebSocketClient.new()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():	
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")
	var err = _client.connect_to_url("ws://localhost:4000/socket/websocket?userToken=123&vsn=2.0.0")
	if err != OK:
		print("ERROR, COULD NOT CONNECT!")
	else:
		print("CONNECTED")
	
# 


func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	_client.get_peer(1).put_packet('["3", "3", "room:lobby", "phx_join", {}]'.to_utf8())

func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	print("Got data from server: ", _client.get_peer(1).get_packet().get_string_from_utf8())

func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()


func create_random_other_player():
	var extra_player = load("res://OtherPlayer.tscn").instance()
	var maxval = 10000
	
	var x = randi() % maxval - maxval / 2
	var y = randi() % maxval - maxval / 2
	print("Creating player at ", x, ", ", y)
	extra_player.position = Vector2(x, y)
	extra_player.set_tint(
		(sin(x % maxval) - 1.0 ) / 2.0 + 0.5,
		(sin(y % maxval) - 1.0 ) / 2.0 + 0.5,
		(sin((y * x) % maxval) - 1.0 ) / 2.0 + 0.5
		)
	add_child(extra_player)
	
	$Player/Camera2D.zoom += Vector2(0.001, 0.001)
