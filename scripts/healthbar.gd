class_name healthbar extends TextureProgressBar

@export var damage: damage_reciever

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_value = damage.health
	value = damage.health
	damage.on_health_changed.connect(update)

func update(value_):
	value = value_
