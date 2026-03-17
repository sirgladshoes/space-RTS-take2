class_name inventory extends Node

enum resource_types{
	TEMP
}

var my_inventory: Dictionary[String, int]

func _ready() -> void:
	for type in resource_types.values():
		my_inventory[str(type)] = 0

func add_resource(type: resource_types, amount: int) -> void:
	my_inventory[str(type)] += amount
	print(my_inventory)

func remove_resource(type: resource_types, attempted_amount: int) -> int:
	if my_inventory[str(type)] - attempted_amount >= 0:
		my_inventory[str(type)] -= attempted_amount
		return attempted_amount
	else:
		my_inventory[str(type)] = 0
		return my_inventory[str(type)]

func remove_all_resource(type: resource_types) -> int:
	var amount = my_inventory[str(type)]
	my_inventory[str(type)] = 0
	return amount

func get_resource_amount(type: resource_types) -> int:
	return my_inventory[str(type)]
