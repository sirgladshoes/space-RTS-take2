extends Control

var lobby_state = {"u": [], "t1": [], "t2": []}

var loaded_players = 0

func _ready() -> void:
	Network.set_accept_connections(true)
	Network.recieved_client_nickname.connect(recieved_nickname)
	Network.recieved_lobby_state.connect(recieved_lobby_state)
	Network.reasign_team.connect(reassign_team)
	Network.load_game.connect(load_game)
	Network.client_loaded.connect(client_loaded)
	Network.host_disconnected_.connect(host_disconnected)
	for id in Network.nicknames:
		lobby_state["u"].append(id)
		$unasigned.add_item(Network.nicknames[id])
	if Network.is_hosting:
		send_state()

func host_disconnected():
	SceneManager.load_menu()

func recieved_nickname(client: int, nickname: String):
	lobby_state["u"].append(client)
	$unasigned.add_item(nickname)
	$start_game.disabled = true
	send_state()

func recieved_lobby_state(state: Dictionary):
	$unasigned.clear()
	for nickname in state["u"]:
		$unasigned.add_item(nickname)
	$team1.clear()
	for nickname in state["t1"]:
		$team1.add_item(nickname)
	$team2.clear()
	for nickname in state["t2"]:
		$team2.add_item(nickname)

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

func reassign_team(id, team):
	var lists = {"u": $unasigned, "t1":$team1, "t2": $team2}
	
	for list in lists:
		var indx = get_text_index(lists[list], Network.nicknames[id])
		if indx > -1:
			lobby_state[list].erase(id)
			lists[list].remove_item(indx)
			lobby_state[team].append(id)
			lists[team].add_item(Network.nicknames[id])
	
	send_state()
	
	if !Network.is_hosting:
		return
	
	if lobby_state["u"].size():
		$start_game.disabled = true
	else:
		$start_game.disabled = false

func load_game():
	var teams = {}
	for player in lobby_state["t1"]:
		teams[player] = 0
	for player in lobby_state["t2"]:
		teams[player] = 1
	SceneManager.load_game(teams)

func client_loaded(id: int):
	var team
	if lobby_state["t1"].has(id):
		team = 0
	else:
		team = 1
	Network.assign_team(id, team)
	loaded_players+=1
	
	if loaded_players == lobby_state["t1"].size() + lobby_state["t2"].size() - 1:
		load_game()

func _on_join_team_1_pressed() -> void:
	if Network.is_hosting:
		reassign_team(1, "t1")
	else:
		Network.send_reasign_team("t1")


func _on_join_team_2_pressed() -> void:
	if Network.is_hosting:
		reassign_team(1, "t2")
	else:
		Network.send_reasign_team("t2")


func _on_start_game_pressed() -> void:
	Network.set_accept_connections(false)
	Network.send_load_game()
