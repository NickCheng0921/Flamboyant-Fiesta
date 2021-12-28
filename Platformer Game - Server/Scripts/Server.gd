extends Node2D

var openPort = 8000
var players = []

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
	
func _player_disconnected(id):
	print("Client ", id, " disconnected")
	
remote func client_msg(id, msg):
	print("    P[", id, "] says ", msg)