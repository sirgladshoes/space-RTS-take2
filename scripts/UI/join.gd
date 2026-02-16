extends Button


func _on_pressed() -> void:
	Network.connect_to_host("127.0.0.1", Network.PORT)
