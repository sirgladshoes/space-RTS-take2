extends Node

var PORT = 18293
@onready var byte_buffer = StreamPeerBuffer.new()

var object_data: Array[networked_type] = []

signal recieved_game_state(state:Dictionary)
signal recieved_client_command(from: Vector2, to: Vector2, units: Array[int])


func _ready() -> void:
	#add all networked object reasources to object_data
	object_data.append(load("res://scripts/units/mining_ship/mining_ship_networking_data.tres"))


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



func data_from_networked_id(id:int) -> networked_type:
	for item in object_data:
		if item.networked_id == id:
			return item
	return null

#server methods
func send_game_state(state: Dictionary):
	byte_buffer.clear()
	
	for object_id in state:
		var networked_id = state[object_id][0]
		var data = state[object_id][1]
		byte_buffer.put_8(networked_id)
		byte_buffer.put_u32(object_id)
		data_from_networked_id(networked_id).encode_data(data, byte_buffer)
	
	recv_world_state.rpc(byte_buffer.data_array)

#client methods

func send_client_command(from: Vector2, to: Vector2, units: Array):
	byte_buffer.clear()
	
	byte_buffer.put_float(from.x)
	byte_buffer.put_float(from.y)
	byte_buffer.put_float(to.x)
	byte_buffer.put_float(to.y)
	for object_id in units:
		byte_buffer.put_u32(object_id)
	
	recv_client_command.rpc_id(1, byte_buffer.data_array)

#signals
func client_connected(id: int):
	print(str(id) + " connected")

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
func recv_world_state(data: PackedByteArray):
	byte_buffer.data_array = data
	
	var state = {}
	
	while byte_buffer.get_position() < byte_buffer.get_size():
		var networked_id = byte_buffer.get_8()
		var object_id = byte_buffer.get_u32()
		var object_state = data_from_networked_id(object_id).decode_data(byte_buffer)
		state[object_id] = [networked_id, object_state]
	
	recieved_game_state.emit(state)

#server rpcs
@rpc("any_peer", "reliable")
func recv_client_command(data: PackedByteArray):
	if !multiplayer.is_server():
		return
	
	byte_buffer.data_array = data
	
	var from: Vector2
	var to:Vector2
	var units: Array[int]
	
	from.x = byte_buffer.get_float()
	from.y = byte_buffer.get_float()
	to.x = byte_buffer.get_float()
	to.y = byte_buffer.get_float()
	
	while byte_buffer.get_position() < byte_buffer.get_size():
		units.append(byte_buffer.get_u32())
	
	recieved_client_command.emit(from, to, units)
