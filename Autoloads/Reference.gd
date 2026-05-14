extends Node

var player: Player

const NEW_LEVEL_FX_SCENE = preload("uid://ctekw1xgrg320")
const DAMAGE_TEXT_SCENE = preload("uid://ci0lssb7ksbut")
const DROP_ITEM_SCENE = preload("uid://clixaseqvjwyv")

func create_new_level_fx(pos: Vector2) -> void:
	create_fx_at_pos(NEW_LEVEL_FX_SCENE, pos)

func create_damage_text(pos: Vector2, amount: float) -> void:
	var label: Label = DAMAGE_TEXT_SCENE.instantiate()
	label.text = str(amount)
	label.global_position = pos + Vector2.RIGHT.rotated(randf_range(0, TAU)) * 4
	get_tree().root.add_child(label)
	var tween = create_tween()
	tween.tween_property(label, "global_position:y", label.global_position.y - 24, 0.7)
	tween.tween_callback(label.queue_free)

func create_fx_at_pos(scene: PackedScene, pos: Vector2) -> void:
	var fx: AnimatedSprite2D = scene.instantiate()
	fx.global_position = pos
	get_tree().root.add_child(fx)
	fx.animation_finished.connect(func(): fx.queue_free())
