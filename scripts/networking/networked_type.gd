class_name networked_type extends Resource

enum networked_ids {
	MINING_SHIP
}

@export var networked_id = networked_ids.MINING_SHIP
@export var networked_data: Array[networked_variable]
@export var object_scene: PackedScene = null

func decode_data(buffer: StreamPeerBuffer) -> Dictionary:
	var conversion_functions: Dictionary[int, Callable] = {networked_variable.data_types.INT_8: buffer.get_8, 
	networked_variable.data_types.INT_16: buffer.get_16, networked_variable.data_types.INT_32: buffer.get_32, 
	networked_variable.data_types.INT_64: buffer.get_64, networked_variable.data_types.FLOAT: buffer.get_float, 
	networked_variable.data_types.DOUBLE: buffer.get_double, networked_variable.data_types.STRING: buffer.get_string}
	
	var decoded_dict = {}
	
	for item in networked_data:
		var type = item.data_type
		decoded_dict[item.name] = conversion_functions[type].call()
	
	return decoded_dict

func encode_data(data:Dictionary, buffer: StreamPeerBuffer) -> void:
	var conversion_functions: Dictionary[int, Callable] = {networked_variable.data_types.INT_8: buffer.put_8, 
	networked_variable.data_types.INT_16: buffer.put_16, networked_variable.data_types.INT_32: buffer.put_32, 
	networked_variable.data_types.INT_64: buffer.put_64, networked_variable.data_types.FLOAT: buffer.put_float, 
	networked_variable.data_types.DOUBLE: buffer.put_double, networked_variable.data_types.STRING: buffer.put_string}
	
	for item in networked_data:
		var type = item.data_type
		conversion_functions[type].call(data[item.name])
