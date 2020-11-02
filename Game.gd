extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var socket : PhoenixSocket
	var channel : PhoenixChannel
	var presence : PhoenixPresence

	socket = PhoenixSocket.new("ws://localhost:4000/socket", {
	  params = {user_id = 10, token = "some_token"}
	})
	
	presence = PhoenixPresence.new()
	channel = socket.channel("room:lobby", {}, presence)
	
	socket.connect_socket()
	
	var result = channel.push("new_msg", parse_json('{"body": "Ciao sono Godot"}'))
	print(result)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func create_random_other_player():
	var extra_player = load("res://OtherPlayer.tscn").instance()
	var maxval = 10000
	
	var x = randi() % maxval - maxval / 2
	var y = randi() % maxval - maxval / 2
	print("Creating player at ", x, ", ", y)
	extra_player.position = Vector2(x, y)
	extra_player.set_tint((x % maxval) / float(maxval), (y % maxval) / float(maxval), ((x * y) % maxval) / float(maxval))
	add_child(extra_player)

