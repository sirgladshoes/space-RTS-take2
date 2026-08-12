extends Node2D



func _on_arrival_timer_timeout() -> void:
	$tick_timer.start()
	$mineable/CollisionShape2D.disabled = false
	$healthbar.visible = true
	$AnimationPlayer.play("idle")
	z_index = -1
