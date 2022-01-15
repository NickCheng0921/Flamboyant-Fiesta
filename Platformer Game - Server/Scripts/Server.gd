extends Node2D

var openPort = 8000
var players = []
var readyPlayers := 0
var pendingSpawn = {}
var Player = load("res://Scenes/Player.tscn")

func _ready():
	print("\n\n\nServer up")
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	var server = NetworkedMultiplayerENet.new()
	
	server.create_server(openPort, 10)
	get_tree().set_network_peer(server)

func _player_connected(id):
	print("    P[", id, "] connected to server")
	rpc_id(id, "acknowledgeConnect", players)
	players.push_back(id)
	rpc("_update_player_count", readyPlayers, players.size())
	
func _player_disconnected(id):
	print("Client ", id, " disconnected")
	if(id in players):
		rpc("despawnCharacter", id)
		get_node("./"+str(id)).queue_free()
	players.remove(players.find(id))
	rpc("_update_player_count", readyPlayers, players.size())
	
remote func client_msg(id, msg):
	print("    P[", id, "] says ", msg)
	
remote func player_ready(id, val):
	#true for ready up, false for not ready
	#print("A player readied up ", get_tree().get_rpc_sender_id())
	if(val):
		readyPlayers += 1
	else:
		readyPlayers -= 1
	rpc("_update_player_count", readyPlayers, players.size())
	
remote func createCharacter():
	print("Player tried to make a character")
	var player = Player.instance()
	player.position = Vector2(0, -50)
	player.name = str(get_tree().get_rpc_sender_id())
	player.set_network_master(0)
	get_node(".").add_child(player)
	pendingSpawn[get_tree().get_rpc_sender_id()] = []
	rpc("spawnCharacter", get_tree().get_rpc_sender_id())
	
	
remote func localSpawned(id):
	#print("Local spawned")
	if id in pendingSpawn:
		pendingSpawn[id].push_back(get_tree().get_rpc_sender_id())
		if pendingSpawn[id].size() == players.size():
			pendingSpawn.erase(id)
			rpc("setMasterPlayer", id)
		
remote func spawnFireball():
	print("Spawning a fireball")