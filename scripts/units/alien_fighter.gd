extends Node2D

var move_speed = 55
@onready var sm = $state_machine
var target_pos: Vector2
var target_obj: Node
var targets = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_rand_target()
	
	sm.set_transition_func(state_transitions)
	sm.switch_state("roam")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !Network.is_hosting:
		return
	decide_target()
	
	var dir = Vector2.ZERO
	
	match sm.current_state:
		"roam":
			if $NavigationAgent2D.is_navigation_finished():
				set_rand_target()
			dir = global_position.direction_to($NavigationAgent2D.get_next_path_position())
		"chase":
			dir = global_position.direction_to(target_obj.global_position)
		"attack":
			look_at(target_obj.global_position)
	var velocity = move_speed*dir
	
	$NavigationAgent2D.set_velocity(velocity*delta)


func state_transitions(current: String):
	match current:
		"roam":
			if target_obj:
				return "chase"
		"chase":
			if !target_obj:
				return "roam"
			if global_position.distance_to(target_obj.global_position) < 60:
				return "attack"
		"attack":
			if !target_obj:
				return "roam"
			if global_position.distance_to(target_obj.global_position) > 75:
				return "chase"


func _on_state_machine_state_switched(current: String, previous: String) -> void:
	if current == "attack":
		$laser.active = true
	elif previous == "attack":
		$laser.active = false


func _on_laser_hit_object(object: Node) -> void:
	object.take_damage(1)
	$AudioStreamPlayer2D.play()


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	global_position+=safe_velocity
	if safe_velocity:
		global_rotation =safe_velocity.angle()

func set_rand_target() -> void:
	var map_rid = $NavigationAgent2D.get_navigation_map()
	var random_point = NavigationServer2D.map_get_random_point(map_rid, 2, true)
	$NavigationAgent2D.target_position = random_point


func _on_damage_reciever_on_death() -> void:
	queue_free()


func _on_target_detector_area_entered(area: Area2D) -> void:
	if area.context == command_manager.commands.ATTACK and area.connected_nodes.selectable.team != 2:
		targets.append(area)

func _on_target_detector_area_exited(area: Area2D) -> void:
	if area in targets:
		targets.erase(area)

func distance_sort(a, b):
	return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)

func decide_target():
	for obj in targets:
		if !is_instance_valid(obj):
			targets.erase(obj)
	if !targets:
		target_obj = null
		sm.switch_state("roam")
		return
	targets.sort_custom(distance_sort)
	target_obj = targets[0]
