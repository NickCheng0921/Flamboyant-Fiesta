extends Node2D

const connectLocalIP = "127.0.0.1"
const connectServerIP = "34.94.217.165"
const connectPort = 8000
var connectedToServer = false
onready var client = NetworkedMultiplayerENet.new()
onready var connectTimer = Timer.new()
#var Player = load("res://Scenes/Player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(get_tree().connect("connected_to_server", self, "_connected_ok") == OK)
	assert(get_tree().connect("connection_failed", self, "_connected_fail") == OK)
	assert(get_tree().connect("server_disconnected", self, "_server_disconnected") == OK)
	
	tryConnect()
	add_child(connectTimer)
	connectTimer.connect("timeout", self, "tryConnect")
	connectTimer.wait_time = 3
	connectTimer.start()

func tryConnect():
	print("Attempting to connect to server")
	if not connectedToServer:
		client.close_connection()
		client = NetworkedMultiplayerENet.new()
		client.create_client(connectLocalIP, connectPort)
		get_tree().set_network_peer(client)
	
func _connected_ok():
	print("Connected to server!")

func _connected_fail():
	print("Connection Unsuccessful")
	
func _server_disconnected():
	print("ERROR: Server disconnected")

puppet func acknowledgeConnect():
	print("Ping")
	connectedToServer = true
	connectTimer.stop()
	remove_child(connectTimer)
	rpc_id(1, "client_msg", get_tree().get_network_unique_id(), " I connected")

"""
puppet func spawn_player(spawn_pos, id):
	print("Spawning a player ", id)
	var player = Player.instance()
	
	player.position = spawn_pos
	player.name = String(id)
	player.set_network_master(id)
	#if this client version "owns" the player, we need to add a camera, spawn keys, and add a HUD
	if(id == get_tree().get_network_unique_id()):
		var camera = Camera2D.new()
		camera.make_current()
		camera.set_limit_smoothing_enabled(100)
		player.add_child(camera)
		#make keys if player controls side
		#get_node("/root/GameIntroLevel").rpc_id(1, "spawn_keys")
	get_node("/root/GameIntroLevel/humans").add_child(player)
"""
