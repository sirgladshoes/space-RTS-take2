extends Node2D

@export var team: selectable.teams
@export var master_template: master_unit_template

signal destroyed(team: int)

func _ready() -> void:
	$selectable.team = team
	$inventory.add_resource(inventory.resource_types.TEMP, 40)

func make_unit(template_indx: int) -> void:
	var template = master_template.data[template_indx]
	for resource in template.cost:
		if template.cost[resource] > $inventory.get_resource_amount(resource):
			return
	var scene = template.scene
	var node = scene.instantiate()
	node.global_position = $spawn_point.global_position
	node.global_position.y+=randi_range(-8, 8)
	for resource in template.cost:
		$inventory.remove_resource(resource, template.cost[resource])
	owner.add_child(node)
	node.get_node("selectable").team = $selectable.team

func _process(delta: float) -> void:
	$selected_ui.rotation = -rotation
	$team.frame = 2+$selectable.team

func _on_timer_timeout() -> void:
	$inventory.add_resource(inventory.resource_types.TEMP, 1)


func _on_damage_reciever_on_death() -> void:
	destroyed.emit(team)
	queue_free()
