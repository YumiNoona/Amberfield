extends Area2D
class_name EnemyZone

@export var enemy_scene: PackedScene
@export var spawn_rate: float = 3.0
@export var max_enemies: int = 5

@onready var collider: CollisionShape2D = $CollisionShape2D

var curr_enemies: int = 0


func _ready() -> void:
	var timer = Timer.new()

	timer.wait_time = spawn_rate
	timer.autostart = true
	timer.timeout.connect(_timeout)
	add_child(timer)

func spawn_enemy() -> void:
	if curr_enemies >= max_enemies:
		return
	
	var pos = get_random_pos()
	var enemy: Enemy = enemy_scene.instantiate()
	enemy.global_position = pos
	enemy.enemy_zone = self
	enemy.on_enemy_died.connect(_on_enemy_died)
	get_tree().root.add_child(enemy)
	curr_enemies += 1


func get_random_pos() -> Vector2:
	var shape = collider.shape as RectangleShape2D
	var half_size = shape.size / 2
	var random_pos = Vector2(
		randf_range(-half_size.x, half_size.x),
		randf_range(-half_size.y, half_size.y)
	)

	return collider.global_position + random_pos

func _timeout() -> void:
	spawn_enemy()

func _on_enemy_died() -> void:
	curr_enemies -= 1
	if curr_enemies < 0:
		curr_enemies = 0
