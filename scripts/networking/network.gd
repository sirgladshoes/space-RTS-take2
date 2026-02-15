extends Node

var PORT = 18293
@onready var byte_buffer = StreamPeerBuffer.new()

@export var test: object_networking_data

func _on_join_pressed() -> void:
	connect_to_host("127.0.0.1", PORT)

func _on_host_pressed() -> void:
	start_hosting(PORT, 2)


#methods to call
func connect_to_host(ip: String, port: int):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.set_multiplayer_peer(peer)
	
	multiplayer.connected_to_server.connect(connected_to_host)
	multiplayer.connection_failed.connect(connect_to_host_failed)
	multiplayer.server_disconnected.connect(host_disconnected)

func start_hosting(port: int, max_connections: int):
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, max_connections)
	multiplayer.set_multiplayer_peer(peer)
	
	multiplayer.peer_connected.connect(client_connected)
	multiplayer.peer_disconnected.connect(client_disconnected)

func destroy_connection():
	var peer = OfflineMultiplayerPeer.new()
	multiplayer.set_multiplayer_peer(peer)


#packet managment
func construct_test_packet() -> PackedByteArray:
	byte_buffer.clear()
	
	var data = {"y": 90,  "name": "doidy", "x": 390}
	test.encode_data(data, byte_buffer)
	
	return byte_buffer.data_array

#prolly move this to world sync node or whatever
func decode_test_packet(packet:PackedByteArray):
	byte_buffer.data_array = packet
	
	print(test.decode_data(byte_buffer))


#signals
func client_connected(id: int):
	print(str(id) + " connected")
	recv_test.rpc_id(id, construct_test_packet())

func client_disconnected(id: int):
	print(str(id) + " disconnected")

func connected_to_host():
	print("connected")

func connect_to_host_failed():
	print("connection failed")

func host_disconnected():
	print("host disconnected")


#client rpcs
@rpc
func recv_test(data: PackedByteArray):
	decode_test_packet(data)
