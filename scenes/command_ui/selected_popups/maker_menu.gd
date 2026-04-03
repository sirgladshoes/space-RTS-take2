extends Control

@export var networked_obj: networked_object

func make_unit(indx: int) -> void:
	#kinda hacky, but it works
	Network.rpc_id(1, "recv_make_unit", indx, networked_obj.object_id)

#mining_ship
func _on_texture_button_pressed() -> void:
	make_unit(0)


func _on_texture_button_pressed2() -> void:
	make_unit(1)
