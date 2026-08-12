extends Node


func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	
	var indx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(indx, $VSlider.value)
	MusicManager.play_track("menu")
	
	SceneManager.current_scene = self
	Network.connected_to_host_.connect(connection_succeded)
	Network.connect_to_host_failed_.connect(connection_failed)
	if $nickname.text != "":
		$host.disabled = false
		if $ip.text.is_valid_ip_address():
			$join.disabled = false

func connection_succeded():
	Network.send_nickname($nickname.text)
	SceneManager.load_lobby()

func connection_failed():
	Network.destroy_connection()
	$join.disabled = false
	$host.disabled = false
	$ip.editable = true
	$nickname.editable = true
	$message_text.text = "connection failed"

func _on_join_pressed() -> void:
	$AudioStreamPlayer.play()
	Network.connect_to_host($ip.text, Network.PORT)
	$join.disabled = true
	$host.disabled = true
	$ip.editable = false
	$nickname.editable = false
	$message_text.text = "attempting connection..."


func _on_host_pressed() -> void:
	$AudioStreamPlayer.play()
	
	if $CheckBox.button_pressed:
		$message_text.text = "attempting auto port forward with UPNP..."
		
		await get_tree().process_frame
		await get_tree().process_frame
	
		
		if !Network.open_port(Network.PORT):
			$message_text.text = "UPNP port forward failed, try manualy port forwarding on " + str(Network.PORT)
			return
	
	Network.start_hosting(Network.PORT, 5)
	Network.nicknames[1] = $nickname.text
	
	SceneManager.load_lobby()


func _on_nickame_text_changed() -> void:
	$AudioStreamPlayer2.play()
	if $nickname.text == "":
		$host.disabled = true
		$join.disabled = true
	else:
		$host.disabled = false
		if $ip.text.is_valid_ip_address():
			$join.disabled = false


func _on_ip_text_changed() -> void:
	$AudioStreamPlayer2.play()
	if  $ip.text.is_valid_ip_address():
		if $nickname.text:
			$join.disabled = false


func _on_h_slider_drag_ended(value_changed: bool) -> void:
	var indx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(indx, $VSlider.value)
