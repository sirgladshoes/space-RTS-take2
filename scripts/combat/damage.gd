class_name damage_reciever extends Area2D

@export var tag: String = "P"

@export var health: int = 10

signal on_health_changed(value)
signal on_death()

func _ready() -> void:
	collision_layer =  3
	collision_mask = 0

func take_damage(amount: int) -> void:
	health-=amount
	if health<=0:
		on_death.emit()
	on_health_changed.emit(health)
