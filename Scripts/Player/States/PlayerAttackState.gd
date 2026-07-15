extends PlayerState
class_name PlayerAttackState

var attack_rotations: Dictionary = {
	"Down": -90.0,
	"Up": 90.0,
	"Left": 0.0,
	"Right": 0.0
}

func enter_state() -> void:
	Reference.log("PLAYER STATE", "entering Attack | direction: %s" % player.animator.last_direction)
	player.hit_enemies_this_attack.clear()
	player.animator.play_anim("Attack")
	_position_hitbox()
	player.enable_weapon_collision(true)
	if not player.anim_sprite.animation_finished.is_connected(_on_animation_finished):
		player.anim_sprite.animation_finished.connect(_on_animation_finished)

func exit_state() -> void:
	Reference.log("PLAYER STATE", "exiting Attack")
	player.hit_enemies_this_attack.clear()
	player.enable_weapon_collision(false)
	if player.anim_sprite.animation_finished.is_connected(_on_animation_finished):
		player.anim_sprite.animation_finished.disconnect(_on_animation_finished)

func _position_hitbox() -> void:
	var marker: Marker2D = player.attack_positions[player.animator.last_direction]
	player.enemy_attack_area.global_position = marker.global_position
	player.enemy_attack_area.rotation_degrees = attack_rotations[player.animator.last_direction]

func _on_animation_finished() -> void:
	Reference.log("PLAYER STATE", "attack anim finished, going to Idle")
	player.enable_weapon_collision(false)
	fsm.transition_to("Idle")
