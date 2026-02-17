class_name networked_variable extends Resource

enum data_types {
	INT_8,
	INT_16,
	INT_32,
	INT_64,
	FLOAT,
	DOUBLE,
	STRING
}

@export var name: String
@export var data_type: data_types
@export var is_interpolated: bool
