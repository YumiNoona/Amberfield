extends EnemyState
class_name EnemyAttackState

@export var attack_duration := 0.5
@export var attack_cooldown: float = 1.0

var attack_timer := 0.0
var cooldown_timer := 0.0
var damage_applied := false
var in_cooldown := false

var attack_rotations: Dictionary = {
	"Down": -90.0,
	"Up": 90.0,
	"Left": 0.0,
	"Right": 0.0
}

func enter_state() -> void:
	Reference.log("ENEMY STATE", "%s entering Attack | direction: %s" % [enemy.name, enemy.animator.last_direction])
	attack_timer = attack_duration
	cooldown_timer = 0.0
	damage_applied = false
	in_cooldown = false
	_position_hitbox()
	enemy.animator.play_anim("Attack")
	enemy.enable_player_collision(true)

func exit_state() -> void:
	Reference.log("ENEMY STATE", "%s exiting Attack" % enemy.name)
	enemy.enable_player_collision(false)

func _position_hitbox() -> void:
	var marker: Marker2D = enemy.attack_positions[enemy.animator.last_direction]
	enemy.player_attack_area.global_position = marker.global_position
	enemy.player_attack_area.rotation_degrees = attack_rotations[enemy.animator.last_direction]

func process_state(delta: float) -> void:
	if not enemy or not Reference.player:
		fsm.transition_to("Wander")
		return

	var distance = enemy.global_position.distance_to(Reference.player.global_position)

	if distance > enemy.attack_range * 2.0:
		Reference.log("ENEMY STATE", "%s player out of range, switching to Follow" % enemy.name)
		fsm.transition_to("Follow")
		return

	if in_cooldown:
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			Reference.log("ENEMY STATE", "%s cooldown done, attacking again" % enemy.name)
			in_cooldown = false
			attack_timer = attack_duration
			damage_applied = false
			_position_hitbox()
			enemy.animator.play_anim("Attack")
			enemy.enable_player_collision(true)
		return

	attack_timer -= delta

	if attack_timer <= 0.0:
		enemy.enable_player_collision(false)
		in_cooldown = true
		cooldown_timer = attack_cooldown
		enemy.animator.play_anim("Idle")
