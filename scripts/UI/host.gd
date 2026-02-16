extends Button


func _on_pressed() -> void:
	Network.start_hosting(Network.PORT, 2)
