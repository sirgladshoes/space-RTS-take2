class_name networked_object extends Node

@export var networking_data: networked_object_data

#only set by server
var object_id: int

func _ready() -> void:
	Network.create_networked_object(self)

func encode_data(buffer: StreamPeerBuffer) -> void:
	
	var conversion_functions: Dictionary[int, Callable] = {networked_variable.data_types.INT_8: buffer.put_8, 
	networked_variable.data_types.INT_16: buffer.put_16, networked_variable.data_types.INT_32: buffer.put_32, 
	networked_variable.data_types.INT_64: buffer.put_64, networked_variable.data_types.FLOAT: buffer.put_float, 
	networked_variable.data_types.DOUBLE: buffer.put_double, networked_variable.data_types.STRING: buffer.put_string}
	
	for variable in networking_data.synced_vars:
		var property_node = owner.get_node(variable.propery_path)
		
		var value
		if variable.getter:
			value = property_node.get(variable.getter).call()
		else:
			value = property_node.get_indexed(variable.property)
		
		var type = variable.data_type
		conversion_functions[type].call(value)

func update_data(buffer: StreamPeerBuffer) -> void:
	var conversion_functions: Dictionary[int, Callable] = {networked_variable.data_types.INT_8: buffer.get_8, 
	networked_variable.data_types.INT_16: buffer.get_16, networked_variable.data_types.INT_32: buffer.get_32, 
	networked_variable.data_types.INT_64: buffer.get_64, networked_variable.data_types.FLOAT: buffer.get_float, 
	networked_variable.data_types.DOUBLE: buffer.get_double, networked_variable.data_types.STRING: buffer.get_string}
	
	for variable in networking_data.synced_vars:
		var type = variable.data_type
		var value = conversion_functions[type].call()
		
		var property_node = owner.get_node(variable.propery_path)
		if variable.setter:
			property_node.get(variable.setter).call(value)
		else:
			property_node.set_indexed(variable.property, value)
