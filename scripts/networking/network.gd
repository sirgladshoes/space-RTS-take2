extends Node

var PORT = 18293
@onready var byte_buffer = StreamPeerBuffer.new()

#tells the network how to encode and decode data
var networking_data: Array[networked_object_data] = []

signal recieved_client_command(from: Vector2, to: Vector2, units: Array[int])

var networked_objects: Dictionary[int,networked_object] = {}
var object_id_counter = 0

func _ready() -> void:
	#add all networked object resources to networking_data
	var networked_res_path = "res://scripts/networking/networked_object_data/"
	var files = DirAccess.get_files_at(networked_res_path)
	for file in files:
		networking_data.append(load(networked_res_path + file))


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




#server methods
func create_networked_object(object: networked_object) -> int:
	object_id_counter+=1
	var id = object_id_counter
	
	networked_objects[id] = object
	object.object_id = id
	
	return id

func send_game_state():
	byte_buffer.clear()
	
	for id in networked_objects:
		var object = networked_objects[id]
		var networking_type_indx = networking_data.find(object.networking_data)
		byte_buffer.put_8(networking_type_indx)
		byte_buffer.put_u32(id)
		
		object.encode_data(byte_buffer)
	
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
	
	while byte_buffer.get_position() < byte_buffer.get_size():
		var object_data_indx = byte_buffer.get_8()
		
		var object_id = byte_buffer.get_u32()
		if !networked_objects.has(object_id):
			print("create object")
		networked_objects[object_id].update_data(byte_buffer)


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
