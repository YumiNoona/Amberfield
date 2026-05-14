extends Area2D
class_name Enemy

@warning_ignore("unused_signal")
signal on_enemy_died

@export var max_health: float = 10.0
@export var damage: float = 2.0
@export var exp_amount: float = 20.0
@export var loot: Array[LootData]

@export_group("Behaviour")
@export var use_flip_for_left: bool = true
@export var detect_range: float = 80.0
@export var aggro_type: String = "normal"
@export var roam_speed: float = 20.0
@export var chase_speed: float = 30.0
@export var attack_cooldown: float = 1.0
@export var attack_range: float = 15.0

@onready var selector: Sprite2D = $Selector
@onready var health_component: HealthComponent = $HealthComponent
@onready var fsm: FSM = $FSM
@onready var anim_sprite: AnimatedSprite2D = $AnimSprite
@onready var health_bar: ProgressBar = $HealthBar
@onready var player_attack_area: Area2D = %PlayerAttackArea

@onready var attack_positions: Dictionary = {
	"Down": %Down,
	"Up": %Up,
	"Right": %Right,
	"Left": %Left
}

var enemy_zone: EnemyZone
var last_direction: String = "Down"
var is_dead: bool = false

func _ready() -> void:
	health_component.setup(max_health)
	health_bar.value = 1.0
	player_attack_area.monitoring = false
	print("[ENEMY] %s spawned | health: %.1f" % [name, max_health])

func _process(delta: float) -> void:
	if fsm.curr_state:
		fsm.curr_state.process_state(delta)

func update_animation(dir: Vector2) -> void:
	if is_dead:
		return
	if abs(dir.x) > abs(dir.y):
		last_direction = "Right" if dir.x > 0 else "Left"
	else:
		last_direction = "Down" if dir.y > 0 else "Up"
	play_direction_anim("Walk")

func play_direction_anim(anim_name: String) -> void:
	if use_flip_for_left and last_direction == "Left":
		anim_sprite.flip_h = true
		anim_sprite.play("%s_Right" % anim_name)
	else:
		anim_sprite.flip_h = false
		anim_sprite.play("%s_%s" % [anim_name, last_direction])

func play_damage_anim() -> void:
	if is_dead:
		return
	print("[ENEMY] %s playing damage anim | direction: %s" % [name, last_direction])
	play_direction_anim("Damage")
	if not anim_sprite.animation_finished.is_connected(_on_damage_anim_finished):
		anim_sprite.animation_finished.connect(_on_damage_anim_finished, CONNECT_ONE_SHOT)

func _on_damage_anim_finished() -> void:
	print("[ENEMY] %s damage anim finished, back to idle" % name)
	play_direction_anim("Idle")

func play_dead_anim() -> void:
	print("[ENEMY] %s playing dead anim" % name)
	is_dead = true
	enable_player_collision(false)
	play_direction_anim("Dead")
	if not anim_sprite.animation_finished.is_connected(_on_dead_anim_finished):
		anim_sprite.animation_finished.connect(_on_dead_anim_finished, CONNECT_ONE_SHOT)

func _on_dead_anim_finished() -> void:
	print("[ENEMY] %s dead anim finished, cleaning up" % name)
	drop_loot()
	Reference.player.add_exp(exp_amount)
	queue_free()

func enable_player_collision(value: bool) -> void:
	print("[ENEMY] %s PlayerAttackArea monitoring: %s" % [name, value])
	player_attack_area.monitoring = value

func drop_loot() -> void:
	var random_data: LootData = loot.pick_random()
	var drop_item: DropItem = Reference.DROP_ITEM_SCENE.instantiate()
	var away_dir: Vector2 = (global_position - Reference.player.global_position).normalized()
	var drop_pos: Vector2 = global_position + away_dir * 15
	drop_item.load_item(random_data)
	drop_item.global_position = drop_pos
	get_tree().root.call_deferred("add_child", drop_item)
	on_enemy_died.emit()

func select_enemy() -> void:
	selector.show()

func deselect_enemy() -> void:
	selector.hide()

func _on_health_component_on_health_changed(curr_health: float) -> void:
	print("[ENEMY] %s health changed: %.1f / %.1f" % [name, curr_health, max_health])
	health_bar.value = curr_health / max_health
	play_damage_anim()

func _on_health_component_on_dead() -> void:
	print("[ENEMY] %s health reached 0, triggering death" % name)
	play_dead_anim()

func _on_player_attack_area_body_entered(body: Node2D) -> void:
	var player = body as Player
	if not player:
		print("[ENEMY ATTACK] %s body_entered but not Player: %s" % [name, body.name])
		return
	print("[ENEMY ATTACK] %s hit player for %.1f dmg | state: %s" % [name, damage, fsm.curr_state.name])
	player.health_component.take_damage(damage)
	player.play_damage_anim()

func _on_detect_area_body_entered(_body: Node2D) -> void:
	print("[ENEMY] %s detected %s, switching to Follow" % [name, _body.name])
	fsm.transition_to("Follow")

func _on_detect_area_body_exited(_body: Node2D) -> void:
	print("[ENEMY] %s lost %s, switching to Wander" % [name, _body.name])
	fsm.transition_to("Wander")

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		print("[ENEMY] %s selected by player" % name)
		Reference.player.selected_enemy = self
