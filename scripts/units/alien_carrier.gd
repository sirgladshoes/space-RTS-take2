extends Node2D

@onready var sm = $state_machine
var target_pos: Vector2
@onready var roam_center: Vector2 = global_position
var roam_rad = 300

@export var alien_ore_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sm.set_transition_func(state_transitions)
	sm.switch_state("roam")


func state_transitions(current: String):
	match current:
		"roam":
			if global_position.distance_to(target_pos) < 10:
				$wait_timer.start()
				return "wait"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !Network.is_hosting:
		return
	
	match sm.current_state:
		"roam":
			global_position = global_position.move_toward(target_pos, 20*delta)
			var target_angle = global_position.direction_to(target_pos).angle()
			global_rotation = rotate_toward(global_rotation, target_angle, delta)

func pick_target() -> void:
	var rand_len = randf_range(0, 1)*roam_rad
	var rand_dir = randf_range(0, 2*PI)
	target_pos = roam_center + Vector2.from_angle(rand_dir)*rand_len

func _on_state_machine_state_switched(current: String, previous: String) -> void:
	if current == "roam":
		pick_target()


func _on_wait_timer_timeout() -> void:
	sm.switch_state("roam")


func _on_damage_reciever_on_death() -> void:
	var scene = alien_ore_scene.instantiate()
	scene.global_position = global_position
	owner.add_child(scene)
	
	queue_free()
