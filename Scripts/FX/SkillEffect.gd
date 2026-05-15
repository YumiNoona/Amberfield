extends Node2D
class_name SkillEffect


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
