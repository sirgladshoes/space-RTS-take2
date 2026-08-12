extends Control

var client_states = {}

var loaded_players = 0

@onready var lists = {"u": $unasigned, "t1":$team1, "t2": $team2}

func _ready() -> void:
	MusicManager.play_track("lobby")
	
	Network.set_accept_connections(true)
	Network.recieved_client_nickname.connect(recieved_nickname)
	Network.recieved_lobby_state.connect(recieved_lobby_state)
	Network.reasign_team.connect(reassign_team)
	Network.load_game.connect(load_game)
	Network.client_disconnected_.connect(client_disconnected)
	Network.client_loaded.connect(client_loaded)
	Network.host_disconnected_.connect(host_disconnected)
	for client in Network.nicknames:
		client_states[client] = "u"
		lists["u"].add_item(Network.nicknames[client])
	if Network.is_hosting:
		send_state()

func host_disconnected():
	SceneManager.load_menu()

func recieved_nickname(client: int, nickname: String):
	Network.nicknames[client] = nickname
	client_states[client] = "u"
	lists["u"].add_item(nickname)
	$start_game.disabled = true
	send_state()

func client_disconnected(client: int):
	if !client_states.has(client):
		return
	
	var team = client_states[client]
	var indx = get_text_index(lists[team], Network.nicknames[client])
	lists[team].remove_item(indx)
	
	client_states.erase(client)
	
	if !lists["u"].item_count and client_states.size() > 1:
		$start_game.disabled = false
	else:
		$start_game.disabled = true

func recieved_lobby_state(state: Dictionary):
	for team in state:
		lists[team].clear()
		for nickname in state[team]:
			lists[team].add_item(nickname)

func send_state():
	var state = {"u":[], "t1":[], "t2":[]}
	for i in range($unasigned.get_item_count()):
		state["u"].append($unasigned.get_item_text(i))
	
	for i in range($team1.get_item_count()):
		state["t1"].append($team1.get_item_text(i))
	
	for i in range($team2.get_item_count()):
		state["t2"].append($team2.get_item_text(i))
	
	Network.send_lobby_state(state)

func get_text_index(list, text) -> int:
	for i in range(list.get_item_count()):
		if text == list.get_item_text(i):
			return i
	return -1

func reassign_team(client, team):
	var curr_team = client_states[client]
	
	var indx = get_text_index(lists[curr_team], Network.nicknames[client])
	lists[curr_team].remove_item(indx)
	lists[team].add_item(Network.nicknames[client])
	
	client_states[client] = team
	
	send_state()
	
	if !Network.is_hosting:
		return
	
	if lists["u"].item_count or client_states.size() <= 1:
		$start_game.disabled = true
	else:
		$start_game.disabled = false

func load_game():
	var teams = {}
	for player in client_states:
		if client_states[player] == "t1":
			teams[player] = 0
		if client_states[player] == "t2":
			teams[player] = 1
	SceneManager.load_game(teams)

func client_loaded(client: int):
	var team
	if client_states[client] == "t1":
		team = 0
	else:
		team = 1
	Network.assign_team(client, team)
	loaded_players+=1
	
	if loaded_players == client_states.size()-1:
		load_game()

func _on_join_team_1_pressed() -> void:
	$AudioStreamPlayer.play()
	if Network.is_hosting:
		reassign_team(1, "t1")
	else:
		Network.send_reasign_team("t1")


func _on_join_team_2_pressed() -> void:
	$AudioStreamPlayer.play()
	if Network.is_hosting:
		reassign_team(1, "t2")
	else:
		Network.send_reasign_team("t2")


func _on_start_game_pressed() -> void:
	$AudioStreamPlayer.play()
	Network.set_accept_connections(false)
	Network.send_load_game()


func _on_leave_pressed() -> void:
	Network.nicknames = {}
	Network.destroy_connection()
	SceneManager.load_menu()
