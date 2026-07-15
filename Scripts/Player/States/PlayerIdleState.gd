extends PlayerState
class_name PlayerIdleState

func enter_state() -> void:
	player.animator.play_anim("Idle")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Attack"):
		fsm.transition_to("Attack")
		return
	if player.is_moving():
		fsm.transition_to("Walk")
