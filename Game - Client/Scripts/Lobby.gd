extends Node2D

const connectLocalIP = "127.0.0.1"
const connectServerIP = "35.230.9.176"
const connectPort = 8000
var connectedToServer = false
var Player = load("res://Scenes/Player.tscn")
onready var client = NetworkedMultiplayerENet.new()
onready var connectTimer = Timer.new()

var puppet_num_players := 1
var puppet_ready_players := 0
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
		#client.create_client(connectServerIP, connectPort)
		get_tree().set_network_peer(client)
	
func _connected_ok():
	print("Connected to server!")

func _connected_fail():
	print("Connection Unsuccessful")
	
func _server_disconnected():
	print("ERROR: Server disconnected")

puppet func acknowledgeConnect(listPlayers):
	connectedToServer = true
	connectTimer.stop()
	remove_child(connectTimer)
	
	#spawn existing players
	print("Existing players: ", listPlayers)
	for p in listPlayers:
		print("Spawn P[", p, "]")
		var player = Player.instance()
		player.name = str(p)
		player.position = Vector2(350, 350)
		get_node(".").add_child(player)
	
	#spawn our player
	rpc_id(1, "createCharacter")

remote func spawnCharacter(id):
	print("Spawn P[", id, "]")
	var player = Player.instance()
	var cam = Camera2D.new()
	player.position = Vector2(350, 350)
	#player.set_network_master(get_tree().get_network_unique_id())
	#player.add_child(cam)
	#cam.make_current()
	get_node(".").add_child(player)
	rpc_id(1, "localSpawned", id)

remote func setMasterPlayer(id):
	if id == get_tree().get_network_unique_id():
		print("Setting master to ", id)

func player_ready(val):
	rpc_id(1, "player_ready", get_tree().get_network_unique_id(), val)

remote func _update_player_count(ready, total):
	$PlayerReady.clear()
	var message = str(ready)+"/"+str(total)+" Ready"
	$"./PlayerReady".text = message

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
