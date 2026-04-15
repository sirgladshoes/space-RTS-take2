extends Node2D

@export var master_template: master_unit_template

func make_unit(template_indx: int) -> void:
	var template = master_template.data[template_indx]
	for resource in template.cost:
		if template.cost[resource] > $inventory.get_resource_amount(resource):
			return
	var scene = template.scene
	var node = scene.instantiate()
	node.team = $selectable.team
	node.global_position = $spawn_point.global_position
	if randi_range(0, 1) == 0:
		node.global_position.y+=randi_range(10, 20)
	else:
		node.global_position.y-=randi_range(10, 20)
	for resource in template.cost:
		$inventory.remove_resource(resource, template.cost[resource])
	owner.add_child(node)
