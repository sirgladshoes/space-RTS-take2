extends Node

func _ready() -> void:
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
	print("failed")

func _on_join_pressed() -> void:
	Network.connect_to_host($ip.text, 19203)


func _on_host_pressed() -> void:
	Network.start_hosting(19203, 5)
	Network.nicknames[1] = $nickname.text
	var upnp = UPNP.new()
	upnp.discover()
	upnp.add_port_mapping(19203)
	
	SceneManager.load_lobby()


func _on_nickame_text_changed() -> void:
	if $nickname.text == "":
		$host.disabled = true
		$join.disabled = true
	else:
		$host.disabled = false
		if $ip.text.is_valid_ip_address():
			$join.disabled = false


func _on_ip_text_changed() -> void:
	if  $ip.text.is_valid_ip_address():
		if $nickname.text:
			$join.disabled = false
