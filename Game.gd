extends TileMap

export var room_id: String = ""
export var my_name: String = ""

var socket : PhoenixSocket
var channel : PhoenixChannel
var presence : PhoenixPresence



var all_players = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	$BlockingDialogBox.append_text("Choose a nickname", 30)
	yield($BlockingDialogBox, "box_hidden")
	$BlockingInputBox.ask_input()
	my_name = yield($BlockingInputBox, "text_from_player")
	
	$Player.set_player_name(my_name)
	print("Got the name:", my_name)
	$BlockingDialogBox.append_text("Insert the room id", 30)
	yield($BlockingDialogBox, "box_hidden")
	$BlockingInputBox.ask_input()
	
	room_id = yield($BlockingInputBox, "text_from_player")
	print("Got the room_id:", room_id)

	var ws_address = "ws://192.168.0.185:4000/socket"

# TODO enable this when serving statically from the same server
#	if OS.get_name() == "HTML5":
#		ws_address = "ws://" + JavaScript.eval("location.host", true) + "/socket"
	# TODO all this part here should start after the user chose the nick and the room
	# and after the initial random position has been set
	socket = PhoenixSocket.new(ws_address, {
		params = { user_name = my_name }
	})
	# Subscribe to Socket events
	socket.connect("on_open", self, "_on_Socket_open")
	socket.connect("on_close", self, "_on_Socket_close")
	socket.connect("on_error", self, "_on_Socket_error")
	socket.connect("on_connecting", self, "_on_Socket_connecting")

	# If you want to track Presence
	presence = PhoenixPresence.new()

	# Subscribe to Presence events (sync_diff and sync_state are also implemented)
	presence.connect("on_join", self, "_on_Presence_join")
	presence.connect("on_leave", self, "_on_Presence_leave")

	# Create a Channel
	channel = socket.channel("game:" + room_id, {}, presence)

	# Subscribe to Channel events
	channel.connect("on_event", self, "_on_Channel_event")
	channel.connect("on_join_result", self, "_on_Channel_join_result")
	channel.connect("on_error", self, "_on_Channel_error")
	channel.connect("on_close", self, "_on_Channel_close")

	call_deferred("add_child", socket, true)

	# Connect!
	socket.connect_socket()
	# react to new positions from the player
	$Player.connect("on_new_position", self, "_on_Player_new_position")


#
# Socket events
#

func _on_Socket_open(payload):
	channel.join()
	print("_on_Socket_open: ", " ", payload)

func _on_Socket_close(payload):
	print("_on_Socket_close: ", " ", payload)

func _on_Socket_error(payload):
	print("_on_Socket_error: ", " ", payload)

func _on_Socket_connecting(is_connecting):
	print("_on_Socket_connecting: ", " ", is_connecting)

#
# Channel events
#

func _on_Channel_event(event, payload, status):
	print("_on_Channel_event:  ", event, ", ", status, ", ", payload)
	if event == "new_player":
		var new_player_name = payload["user"]
		if new_player_name != my_name:
			print("new player detected", new_player_name)
			var extra_player = load("res://OtherPlayer.tscn").instance()
			all_players[new_player_name] = extra_player
			extra_player.set_player_name(new_player_name)
			extra_player.position = Vector2(payload["x"], payload["y"])
			add_child(extra_player)
		return
	if event == "new_position":
		var moving_player_name = payload["user"]
		if moving_player_name != my_name:
			all_players[moving_player_name].target = Vector2(payload["x"], payload["y"])
			all_players[moving_player_name].set_physics_process(true)
		return

func _on_Channel_join_result(status, result):
	print("_on_Channel_join_result:  ", status, result)
	var did_push = channel.push("new_player", {"x": int(position.x), "y": int(position.y)})
	print("did push the new_player? ", did_push)
			
func _on_Channel_error(error):
	print("_on_Channel_error: " + str(error))

func _on_Channel_close(closed):
	print("_on_Channel_close: " + str(closed))

#
# Presence events
#

func _on_Presence_join(joins):
	print("_on_Presence_join: " + str(joins))

func _on_Presence_leave(leaves):
	print("_on_Presence_leave: " + str(leaves))


func _on_Player_new_position(position: Vector2):
	var did_push = channel.push("new_position", {"x": int(position.x), "y": int(position.y)})
	if !did_push:
		print_debug("error, could not send the position!")


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
