class_name selected_ui extends Control

func _ready() -> void:
	visible = false

func selected():
	visible = true

func deselected():
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation = -owner.rotation
