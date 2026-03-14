extends Node

var PORT = 18293
@onready var byte_buffer = StreamPeerBuffer.new()

#tells the network how to encode and decode data
var networking_data: Array[networked_object_data] = []

signal recieved_client_command(from: Vector2, to: Vector2, units: Array[int])
#for creating objects client side.
signal create_object(scene: Node)
signal add_object_to_network(id: int)

var networked_objects: Dictionary[int,networked_object] = {}
var object_id_counter = 0

var time: Dictionary[String, int] = {"host_sync_time":0, "client_sync_time":0}
var render_delay = 0.2

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

func add_networked_object(object: networked_object):
	if object.object_id:
		if networked_objects.has(object.object_id):
			printerr("object with that id already exists")
			return
		networked_objects[object.object_id] = object
		return
	
	object_id_counter+=1
	var id = object_id_counter
	
	networked_objects[id] = object
	object.object_id = id

func remove_networked_object(object_id: int):
	networked_objects.erase(object_id)

#server methods
func send_world_state():
	byte_buffer.clear()
	
	byte_buffer.put_u32(Time.get_ticks_msec())
	for id in networked_objects:
		var object = networked_objects[id]
		var networking_type_indx = networking_data.find(object.networking_data)
		byte_buffer.put_u8(networking_type_indx)
		byte_buffer.put_u32(id)
		
		object.encode_data(byte_buffer)
	
	recv_world_state.rpc(byte_buffer.data_array)

#client methods
func get_time_secs() -> float:
	return float(Time.get_ticks_msec() - time.client_sync_time + time.host_sync_time)/1000

func skip_object_data(networked_data: networked_object_data, buffer: StreamPeerBuffer):
	var conversion_functions: Dictionary[int, Callable] = {networked_variable.data_types.INT_8: buffer.get_8, 
	networked_variable.data_types.INT_16: buffer.get_16, networked_variable.data_types.INT_32: buffer.get_32, 
	networked_variable.data_types.INT_64: buffer.get_64, networked_variable.data_types.FLOAT: buffer.get_float, 
	networked_variable.data_types.DOUBLE: buffer.get_double, networked_variable.data_types.STRING: buffer.get_string}
	
	for variable in networked_data.synced_vars:
		conversion_functions[variable.data_type].call()

#implementation specific client
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
	print("connected to host")
	recv_client_clocksync.rpc(Time.get_ticks_msec())

func connect_to_host_failed():
	print("connection failed")

func host_disconnected():
	print("host disconnected")


#client rpcs
@rpc
func recv_world_state(data: PackedByteArray):
	byte_buffer.data_array = data
	
	var recieved_objects = []
	
	var timestamp = float(byte_buffer.get_u32())/1000
	while byte_buffer.get_position() < byte_buffer.get_size():
		var object_data_indx = byte_buffer.get_u8()
		var object_id = byte_buffer.get_u32()
		recieved_objects.append(object_id)
		
		if !networked_objects.has(object_id):
			var scene = load(networking_data[object_data_indx].object_scene_path)
			var node = scene.instantiate()
			add_object_to_network.emit(object_id)
			create_object.emit(node)
		
		if networked_objects.has(object_id):
			networked_objects[object_id].update_data(byte_buffer, timestamp)
		else:
			skip_object_data(networking_data[object_data_indx], byte_buffer)
	
	for object_id in networked_objects:
		if !recieved_objects.has(object_id):
			networked_objects[object_id].destroy()

@rpc 
func recv_host_clocksync(host_time: int, client_start_time: int):
	var curr_time = Time.get_ticks_msec()
	@warning_ignore("integer_division")
	time.host_sync_time = host_time + (curr_time-client_start_time)/2
	time.client_sync_time = curr_time

#server rpcs
@rpc("any_peer", "reliable")
func recv_client_clocksync(client_time: int):
	var id = multiplayer.get_remote_sender_id()
	recv_host_clocksync.rpc_id(id, Time.get_ticks_msec(), client_time)

#implementation specific server rpcs
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
