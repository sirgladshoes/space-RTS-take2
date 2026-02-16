class_name object_networking_data extends Resource

enum networked_ids {
	MINING_SHIP
}

enum data_types {
	INT_8,
	INT_16,
	INT_32,
	INT_64,
	FLOAT,
	DOUBLE,
	STRING
}

@export var networked_id = networked_ids.MINING_SHIP
@export var networked_data: Dictionary[String, data_types]
@export var object_scene: PackedScene = null

func decode_data(buffer: StreamPeerBuffer) -> Dictionary:
	var conversion_functions: Dictionary[int, Callable] = {data_types.INT_8: buffer.get_8, 
	data_types.INT_16: buffer.get_16, data_types.INT_32: buffer.get_32, 
	data_types.INT_64: buffer.get_64, data_types.FLOAT: buffer.get_float, 
	data_types.DOUBLE: buffer.get_double, data_types.STRING: buffer.get_string}
	
	var decoded_dict = {}
	
	for item in networked_data:
		var type = networked_data[item]
		decoded_dict[item] = conversion_functions[type].call()
	
	return decoded_dict

#maybe extract from node in the future?
func encode_data(data:Dictionary, buffer: StreamPeerBuffer) -> void:
	var conversion_functions: Dictionary[int, Callable] = {data_types.INT_8: buffer.put_8, 
	data_types.INT_16: buffer.put_16, data_types.INT_32: buffer.put_32, 
	data_types.INT_64: buffer.put_64, data_types.FLOAT: buffer.put_float, 
	data_types.DOUBLE: buffer.put_double, data_types.STRING: buffer.put_string}
	
	for item in networked_data:
		var type = networked_data[item]
		conversion_functions[type].call(data[item])
