class_name networked_object extends Node

@export var networking_data: networked_object_data

#uses metadata to access other surrounding nodes
@export var related_nodes: Dictionary[String, NodePath]

#only set by server
var object_id: int

var interpolated_data: Array[Dictionary] = []

signal destroy_object()

func _init() -> void:
	Network.add_object_to_network.connect(add_to_network)

#called when network creates object
func add_to_network(id: int):
	object_id = id
	Network.add_object_to_network.disconnect(add_to_network)

func _ready() -> void:
	if Network.add_object_to_network.is_connected(add_to_network):
		Network.add_object_to_network.disconnect(add_to_network)
	Network.add_networked_object(self)
	for path in related_nodes.values():
		print(path)
		get_node(path).set_meta("networked_object", self)

func encode_data(buffer: StreamPeerBuffer) -> void:
	var conversion_functions: Dictionary[int, Callable] = {networked_variable.data_types.INT_8: buffer.put_8, 
	networked_variable.data_types.INT_16: buffer.put_16, networked_variable.data_types.INT_32: buffer.put_32, 
	networked_variable.data_types.INT_64: buffer.put_64, networked_variable.data_types.FLOAT: buffer.put_float, 
	networked_variable.data_types.DOUBLE: buffer.put_double, networked_variable.data_types.STRING: buffer.put_string}
	
	for variable in networking_data.synced_vars:
		var property_node = get_node(variable.propery_path)
		var value
		if variable.getter:
			value = property_node.get(variable.getter).call()
		else:
			value = property_node.get_indexed(variable.property)
		
		var type = variable.data_type
		conversion_functions[type].call(value)

func update_data(buffer: StreamPeerBuffer, timestamp: float) -> void:
	var conversion_functions: Dictionary[int, Callable] = {networked_variable.data_types.INT_8: buffer.get_8, 
	networked_variable.data_types.INT_16: buffer.get_16, networked_variable.data_types.INT_32: buffer.get_32, 
	networked_variable.data_types.INT_64: buffer.get_64, networked_variable.data_types.FLOAT: buffer.get_float, 
	networked_variable.data_types.DOUBLE: buffer.get_double, networked_variable.data_types.STRING: buffer.get_string}
	
	var interpolated_snapshot = {}
	interpolated_snapshot["timestamp"] = timestamp
	for variable in networking_data.synced_vars:
		var type = variable.data_type
		var value = conversion_functions[type].call()
		
		if !variable.is_interpolated:
			apply_variable(variable, value)
		else:
			interpolated_snapshot[variable] = value
			if interpolated_data.size() == 0:
				apply_variable(variable, value)
	interpolated_data.append(interpolated_snapshot)

func apply_variable(variable: networked_variable, value) -> void:
		var property_node = get_node(variable.propery_path)
		if variable.setter:
			property_node.get(variable.setter).call(value)
		else:
			property_node.set_indexed(variable.property, value)

func destroy():
	destroy_object.emit()
	free()

func get_related_node(key: String) -> Node:
	return get_node(related_nodes[key])

func _process(_delta: float) -> void:
	if interpolated_data.size() < 2:
		return
	
	var render_time = Network.get_time_secs() - Network.render_delay
	
	while interpolated_data.size() > 2 and interpolated_data[1].timestamp < render_time:
		interpolated_data.remove_at(0)
	 
	
	var snapshot1 = interpolated_data[0]
	var timestamp1 = snapshot1.timestamp
	
	var snapshot2 = interpolated_data[1]
	var timestamp2 = snapshot2.timestamp
	
	
	var lerp_weight = (render_time - timestamp1) / (timestamp2 - timestamp1)
	
	for variable in snapshot1:
		if not variable is networked_variable:
			continue
		var value1 = snapshot1[variable]
		var value2 = snapshot2[variable]
		
		var interpolated_value = lerp(value1, value2, lerp_weight)
		apply_variable(variable, interpolated_value)

func _exit_tree() -> void:
	Network.remove_networked_object(object_id)
