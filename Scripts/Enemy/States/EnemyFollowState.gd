extends EnemyState
class_name EnemyFollowState

@export var min_move_speed := 20.0
@export var max_move_speed := 35.0
@export var stop_distance := 15.0

func process_state(delta: float) -> void:
	if not enemy or not Reference.player:
		return
	var dir = enemy.global_position.direction_to(Reference.player.global_position)
	var distance = enemy.global_position.distance_to(Reference.player.global_position)
	if distance > stop_distance:
		var speed = randf_range(min_move_speed, max_move_speed)
		enemy.global_position += dir * speed * delta
		enemy.update_animation(dir)
	if distance <= stop_distance:
		fsm.transition_to("Attack")
