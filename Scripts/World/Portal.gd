extends Area2D
class_name Portal

@export var target_pos: Node2D

func _on_body_entered(body: Node2D) -> void:

	# Ignore non-player bodies
	if body != Reference.player:
		return

	# Fade screen before teleporting player
	await Transition.fade_in(1.0)

	Reference.player.global_position = (target_pos.global_position)
	Transition.fade_out(1.0)
