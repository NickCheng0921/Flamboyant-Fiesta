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
		player.position = Vector2(0, -50)
		player.get_node("label").text = str(p)
		get_node(".").add_child(player)
	
	#spawn our player
	rpc_id(1, "createCharacter")

remote func spawnCharacter(id):
	print("Spawn P[", id, "]")
	var player = Player.instance()
	player.name = str(id)
	player.position = Vector2(0, -50)
	player.set_network_master(0)
	player.get_node("label").text = str(id)
	get_node(".").add_child(player)
	rpc_id(1, "localSpawned", id)
	
remote func despawnCharacter(id):
	#remove on next possible physics frame
	get_node("./"+str(id)).queue_free()
	
remote func setMasterPlayer(id):
	if id == get_tree().get_network_unique_id():
		print("Set Master [", id, "]")
		#print_tree_pretty()
		get_node("./"+str(id)).set_network_master(id)
		
		var cam = Camera2D.new()
		cam.make_current()
		get_node("./"+str(id)).add_child(cam)
		
		get_node("./"+str(id)).connect_readyArea()

remote func _update_player_count(ready, total):
	$PlayerReady.clear()
	var message = str(ready)+"/"+str(total)+" Ready"
	$"./PlayerReady".text = message