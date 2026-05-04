extends PlayerState
class_name PlayerWalkState

func enter_state() -> void:
	player.play_direction_anim("Walk")

func process_state(_delta: float) -> void:
	var input_vector = Input.get_vector("Move_Left", "Move_Right", "Move_Up", "Move_Down")

	if Input.is_action_pressed("Attack"):
		fsm.transition_to("Attack")
		return

	if input_vector == Vector2.ZERO:
		fsm.transition_to("Idle")
		return

	player.update_direction(input_vector)
	player.play_direction_anim("Walk")
	player.velocity = input_vector * player.move_speed
	player.move_and_slide()
