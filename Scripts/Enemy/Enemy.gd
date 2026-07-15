extends Area2D
class_name Enemy

@warning_ignore("unused_signal")
signal on_enemy_died

@export var max_health: float = 10.0
@export var damage: float = 2.0
@export var exp_amount: float = 20.0
@export var loot: Array[LootData]

@export_group("Behaviour")
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
@onready var animator: DirectionalAnimator = $DirectionalAnimator

@onready var attack_positions: Dictionary = {
	"Down": %Down,
	"Up": %Up,
	"Right": %Right,
	"Left": %Left
}

var enemy_zone: EnemyZone
var is_dead: bool = false

func _ready() -> void:
	health_component.setup(max_health)
	health_bar.value = 1.0
	player_attack_area.monitoring = false
	animator.damage_anim_finished.connect(_on_damage_anim_finished)
	animator.dead_anim_finished.connect(_on_dead_anim_finished)
	Reference.log("ENEMY", "%s spawned | health: %.1f" % [name, max_health])

func _process(delta: float) -> void:
	if is_dead:
		return
	if fsm.curr_state:
		fsm.curr_state.process_state(delta)

func _on_damage_anim_finished() -> void:
	if is_dead:
		return
	Reference.log("ENEMY", "%s damage anim finished, back to idle" % name)
	animator.play_anim("Idle")

func _on_dead_anim_finished() -> void:
	Reference.log("ENEMY", "%s dead anim finished, cleaning up" % name)
	drop_loot()
	Reference.player.add_exp(exp_amount)
	queue_free()

#region Combat

func enable_player_collision(value: bool) -> void:
	Reference.log("ENEMY", "%s PlayerAttackArea monitoring: %s" % [name, value])
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

#endregion

#region Detection & Selection

func select_enemy() -> void:
	selector.show()

func deselect_enemy() -> void:
	selector.hide()

func _on_health_component_on_health_changed(curr_health: float) -> void:
	Reference.log("ENEMY", "%s health changed: %.1f / %.1f" % [name, curr_health, max_health])
	health_bar.value = curr_health / max_health
	animator.play_damage_anim()

func _on_health_component_on_dead() -> void:
	Reference.log("ENEMY", "%s health reached 0, triggering death" % name)
	is_dead = true
	enable_player_collision(false)
	animator.play_dead_anim()

func _on_player_attack_area_body_entered(body: Node2D) -> void:
	var player = body as Player
	if not player:
		Reference.log("ENEMY ATTACK", "%s body_entered but not Player: %s" % [name, body.name])
		return
	Reference.log("ENEMY ATTACK", "%s hit player for %.1f dmg | state: %s" % [name, damage, fsm.curr_state.name])
	player.health_component.take_damage(damage)
	player.animator.play_damage_anim()

func _on_detect_area_body_entered(_body: Node2D) -> void:
	Reference.log("ENEMY", "%s detected %s, switching to Follow" % [name, _body.name])
	fsm.transition_to("Follow")

func _on_detect_area_body_exited(_body: Node2D) -> void:
	Reference.log("ENEMY", "%s lost %s, switching to Wander" % [name, _body.name])
	fsm.transition_to("Wander")

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		Reference.log("ENEMY", "%s selected by player" % name)
		Reference.player.selected_enemy = self

#endregion
