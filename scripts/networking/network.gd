extends Node

var PORT = 18293
@onready var byte_buffer = StreamPeerBuffer.new()

#tells the network how to encode and decode data
var networking_data: Array[networked_object_data] = []

var networked_objects: Dictionary[int,networked_object] = {}
var object_id_counter = 0

var time: Dictionary[String, int] = {"host_sync_time":0, "client_sync_time":0}
var render_delay = 0.2
var is_hosting = false

signal started_hosting()
signal client_connected_(id: int)
signal client_disconnected_(id: int)

signal connected_to_host_()
signal connect_to_host_failed_()
signal host_disconnected_()

#for creating objects client side.
signal create_object(scene: Node)
signal add_object_to_network(id: int)

#implementation specific
#host

var nicknames = {}
signal recieved_client_nickname(nickname: String)
signal reasign_team(id: int, team: String)
signal client_loaded(id: int)

signal recieved_client_command(from: Vector2, to: Vector2, units: Array[int])
signal make_unit(template_indx: int, maker_id: int)
#client
signal assigned_team(team: int)
signal recieved_lobby_state(state: Dictionary)
signal load_game()


func _ready() -> void:
	#add all networked object resources to networking_data
	var networked_res_path = "res://scripts/networking/networked_object_data/"
	var files = DirAccess.get_files_at(networked_res_path)
	for file in files:
		networking_data.append(load(networked_res_path + file))


func connect_to_host(ip: String, port: int) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.set_multiplayer_peer(peer)
	
	multiplayer.connected_to_server.connect(connected_to_host)
	multiplayer.connection_failed.connect(connect_to_host_failed)
	multiplayer.server_disconnected.connect(host_disconnected)

func start_hosting(port: int, max_connections: int) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, max_connections)
	multiplayer.set_multiplayer_peer(peer)
	is_hosting = true
	
	multiplayer.peer_connected.connect(client_connected)
	multiplayer.peer_disconnected.connect(client_disconnected)
	started_hosting.emit()

func set_accept_connections(value: bool):
	var peer = multiplayer.get_multiplayer_peer()
	peer.set_refuse_new_connections(!value)

func destroy_connection() -> void:
	var peer = OfflineMultiplayerPeer.new()
	multiplayer.set_multiplayer_peer(peer)
	is_hosting = false

func add_networked_object(object: networked_object) -> void:
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

func remove_networked_object(object_id: int) -> void:
	networked_objects.erase(object_id)

#server methods
func send_world_state() -> void:
	byte_buffer.clear()
	
	byte_buffer.put_u32(Time.get_ticks_msec())
	for id in networked_objects:
		var object = networked_objects[id]
		var networking_type_indx = networking_data.find(object.networking_data)
		byte_buffer.put_u8(networking_type_indx)
		byte_buffer.put_u32(id)
		
		object.encode_data(byte_buffer)
	
	recv_world_state.rpc(byte_buffer.data_array)

#implementation specific server
func assign_team(client_id: int, team: int) -> void:
	recv_team_assignment.rpc_id(client_id, team)

func send_lobby_state(state: Dictionary) -> void:
	recv_lobby_state.rpc(state)

func send_load_game():
	recv_load_game.rpc()

func send_load_lobby():
	recv_load_lobby.rpc()

#client methods
func get_time_secs() -> float:
	return float(Time.get_ticks_msec() - time.client_sync_time + time.host_sync_time)/1000

func create_networked_object(object_id: int, object_data_indx) -> void:
	var scene = load(networking_data[object_data_indx].object_scene_path)
	var node = scene.instantiate()
	add_object_to_network.emit(object_id)
	create_object.emit(node)

func skip_object_data(networked_data: networked_object_data, buffer: StreamPeerBuffer) -> void:
	var conversion_functions: Dictionary[int, Callable] = {networked_variable.data_types.INT_8: buffer.get_8, 
	networked_variable.data_types.INT_16: buffer.get_16, networked_variable.data_types.INT_32: buffer.get_32, 
	networked_variable.data_types.INT_64: buffer.get_64, networked_variable.data_types.FLOAT: buffer.get_float, 
	networked_variable.data_types.DOUBLE: buffer.get_double, networked_variable.data_types.STRING: buffer.get_string}
	
	for variable in networked_data.synced_vars:
		conversion_functions[variable.data_type].call()

#implementation specific client
func send_client_command(from: Vector2, to: Vector2, units: Array) -> void:
	byte_buffer.clear()
	
	byte_buffer.put_float(from.x)
	byte_buffer.put_float(from.y)
	byte_buffer.put_float(to.x)
	byte_buffer.put_float(to.y)
	for object_id in units:
		byte_buffer.put_u32(object_id)
	
	recv_client_command.rpc_id(1, byte_buffer.data_array)

func send_nickname(nickname: String) -> void:
	recv_client_nickname.rpc_id(1, nickname)

func send_reasign_team(team: String) -> void:
	recv_reasign_team.rpc_id(1, team)

func send_client_loaded():
	recv_client_loaded.rpc_id(1)

#signals
func client_connected(id: int) -> void:
	client_connected_.emit(id)
	print(str(id) + " connected")

func client_disconnected(id: int) -> void:
	client_disconnected_.emit(id)
	print(str(id) + " disconnected")

func connected_to_host() -> void:
	connected_to_host_.emit()
	print("connected to host")
	recv_client_clocksync.rpc(Time.get_ticks_msec())

func connect_to_host_failed() -> void:
	connect_to_host_failed_.emit()
	print("connection failed")

func host_disconnected() -> void:
	host_disconnected_.emit()
	print("host disconnected")


#client rpcs
@rpc("unreliable")
func recv_world_state(data: PackedByteArray) -> void:
	byte_buffer.data_array = data
	
	var recieved_objects = []
	
	var timestamp = float(byte_buffer.get_u32())/1000
	while byte_buffer.get_position() < byte_buffer.get_size():
		var object_data_indx = byte_buffer.get_u8()
		var object_id = byte_buffer.get_u32()
		recieved_objects.append(object_id)
		
		if !networked_objects.has(object_id):
			create_networked_object(object_id, object_data_indx)
		
		if networked_objects.has(object_id):
			if networked_objects[object_id].networking_data != networking_data[object_data_indx]:
				networked_objects[object_id].destroy()
				create_networked_object(object_id, object_data_indx)
			networked_objects[object_id].update_data(byte_buffer, timestamp)
		else:
			skip_object_data(networking_data[object_data_indx], byte_buffer)
	
	for object_id in networked_objects:
		if !recieved_objects.has(object_id):
			networked_objects[object_id].destroy()

@rpc("reliable") 
func recv_host_clocksync(host_time: int, client_start_time: int) -> void:
	var curr_time = Time.get_ticks_msec()
	@warning_ignore("integer_division")
	time.host_sync_time = host_time + (curr_time-client_start_time)/2
	time.client_sync_time = curr_time

#implementation specific client rpcs
@rpc("reliable")
func recv_team_assignment(team: int) -> void:
	assigned_team.emit(team)

@rpc("reliable")
func recv_lobby_state(state: Dictionary) -> void:
	recieved_lobby_state.emit(state)

@rpc("any_peer", "reliable", "call_local")
func recv_make_unit(template_indx: int, maker_id: int):
	make_unit.emit(template_indx, maker_id)

@rpc("reliable")
func recv_load_game():
	load_game.emit()

@rpc("reliable")
func recv_load_lobby():
	SceneManager.load_lobby()

#server rpcs
@rpc("any_peer", "reliable")
func recv_client_clocksync(client_time: int) -> void:
	var id = multiplayer.get_remote_sender_id()
	recv_host_clocksync.rpc_id(id, Time.get_ticks_msec(), client_time)

#implementation specific server rpcs
@rpc("any_peer", "reliable")
func recv_client_nickname(nickname: String) -> void:
	nicknames[multiplayer.get_remote_sender_id()] = nickname
	recieved_client_nickname.emit(multiplayer.get_remote_sender_id(), nickname)

@rpc("any_peer", "reliable")
func recv_client_command(data: PackedByteArray) -> void:
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
	
	var sender = multiplayer.get_remote_sender_id()
	
	recieved_client_command.emit(from, to, units, sender)

@rpc("reliable", "any_peer")
func recv_reasign_team(team: String):
	reasign_team.emit(multiplayer.get_remote_sender_id(), team)

@rpc("any_peer", "reliable")
func recv_client_loaded() -> void:
	client_loaded.emit(multiplayer.get_remote_sender_id())
