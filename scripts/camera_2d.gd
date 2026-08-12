extends Camera2D

func _unhandled_input(event: InputEvent) -> void:
	var mouse = get_global_mouse_position()
	
	if event is InputEventMouseMotion:
		var delta_movement = event.relative
		if Input.is_action_pressed("drag"):
			global_position-=delta_movement*1.2*(1/zoom.x)
	elif event.is_action_pressed("zoom_in"):
		zoom = zoom.move_toward(Vector2(1, 1), 0.1)
		global_position += mouse - get_global_mouse_position()
	elif event.is_action_pressed("zoom_out"):
		zoom = zoom.move_toward(Vector2(0.1, 0.1), 0.1)

func _process(delta: float) -> void:
	$AudioListener2D.global_position = get_screen_center_position()
	var indx = AudioServer.get_bus_index("world")
	AudioServer.set_bus_volume_linear(indx, zoom.x)
