extends Node2D

var openPort = 8000
var players = []
var playerVals = {}
var readyPlayers := 0

func _ready():
	print("Server up")
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	var server = NetworkedMultiplayerENet.new()
	
	server.create_server(openPort, 10)
	get_tree().set_network_peer(server)

func _player_connected(id):
	print("    P[", id, "] connected to server")
	rpc_id(id, "acknowledgeConnect")
	players.push_back(id)
	rpc("_update_player_count", readyPlayers, players.size())
	
func _player_disconnected(id):
	print("Client ", id, " disconnected")
	players.remove(players.find(id))
	if playerVals[id]:
		readyPlayers-=1
	
remote func client_msg(id, msg):
	print("    P[", id, "] says ", msg)
	
remote func player_ready(id, val):
	#true for ready up, false for not ready
	playerVals[id] = val
	print("A player readied up")
	if(val):
		readyPlayers += 1
	else:
		readyPlayers -= 1
	rpc("_update_player_count", readyPlayers, players.size())
