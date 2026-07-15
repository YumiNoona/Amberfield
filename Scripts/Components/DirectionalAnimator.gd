extends Node
class_name DirectionalAnimator

signal damage_anim_finished
signal dead_anim_finished

@export var anim_sprite: AnimatedSprite2D
@export var use_flip_for_left: bool = false

var last_direction: String = "Down"

func set_direction_from_vector(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		return
	if abs(dir.x) > abs(dir.y):
		last_direction = "Right" if dir.x > 0 else "Left"
	else:
		last_direction = "Down" if dir.y > 0 else "Up"

func play_anim(anim_name: String) -> void:
	if use_flip_for_left and last_direction == "Left":
		anim_sprite.flip_h = true
		anim_sprite.play("%s_Right" % anim_name)
	else:
		anim_sprite.flip_h = false
		anim_sprite.play("%s_%s" % [anim_name, last_direction])

func play_damage_anim() -> void:
	play_anim("Damage")
	if not anim_sprite.animation_finished.is_connected(_on_damage_anim_finished):
		anim_sprite.animation_finished.connect(_on_damage_anim_finished, CONNECT_ONE_SHOT)

func play_dead_anim() -> void:
	play_anim("Dead")
	if not anim_sprite.animation_finished.is_connected(_on_dead_anim_finished):
		anim_sprite.animation_finished.connect(_on_dead_anim_finished, CONNECT_ONE_SHOT)

func _on_damage_anim_finished() -> void:
	damage_anim_finished.emit()

func _on_dead_anim_finished() -> void:
	dead_anim_finished.emit()
