extends Node2D

@export var team: selectable.teams
 
var target_position: Vector2
@export var master_template: master_unit_template

func _ready() -> void:
	$selectable.team = team

func make_unit(template_indx: int) -> void:
	var template = master_template.data[template_indx]
	var scene = template.scene
	var node = scene.instantiate()
	node.team = team
	node.global_position = $Marker2D.global_position
	for resource in template.cost:
		$inventory.remove_resource(resource, template.cost[resource])
	owner.add_child(node)

func _physics_process(delta: float) -> void:
	if target_position:
		global_position = global_position.move_toward(target_position, 100*delta)
		look_at(target_position)

func _on_selectable_command_given(command: int, args: Array) -> void:
	match command:
		command_manager.commands.MOVE:
			target_position = args[0]
