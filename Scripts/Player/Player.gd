extends CharacterBody2D
class_name Player

@export_group("Stats")
@export var max_health: float = 10.0
@export var max_mana: float = 10.0
@export var move_speed: float = 60.0
@export var damage: float = 5.0
@export var crit_chance: float = 0.0
@export var crit_damage: float = 0.0

@export_group("Exp")
@export var base_exp: float = 100.0
@export var exp_multiplier: float = 2.0

@onready var anim_sprite: AnimatedSprite2D = $AnimSprite
@onready var health_component: HealthComponent = $HealthComponent
@onready var enemy_attack_area: Area2D = %EnemyAttackArea
@onready var fsm: FSM = $FSM

@onready var attack_positions: Dictionary = {
	"Down": %Down,
	"Up": %Up,
	"Right": %Right,
	"Left": %Left
}

var curr_exp: float
var next_level_exp: float
var curr_level: int = 1
var curr_points: int = 0
var curr_mana: float
var last_direction: String = "Down"

var strength_value: int = 0
var dexterity_value: int = 0
var intelligence_value: int = 0


func _process(delta: float) -> void:
	if fsm.curr_state:
		fsm.curr_state.process_state(delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		add_exp(100.0)

func is_moving() -> bool:
	var move_input = ["Move_Up", "Move_Down", "Move_Left", "Move_Right"]
	for input in move_input:
		if Input.is_action_pressed(input):
			return true
	return false

func update_direction(input_vector: Vector2) -> void:
	if input_vector == Vector2.ZERO:
		return
	if abs(input_vector.x) > abs(input_vector.y):
		last_direction = "Right" if input_vector.x > 0 else "Left"
	else:
		last_direction = "Down" if input_vector.y > 0 else "Up"

func play_direction_anim(anim_name: String) -> void:
	if last_direction == "Left":
		anim_sprite.flip_h = true
		anim_sprite.play("%s_Right" % anim_name)
	else:
		anim_sprite.flip_h = false
		anim_sprite.play("%s_%s" % [anim_name, last_direction])

func upgrade_stat(stat_name: String) -> void:
	if curr_points <= 0:
		return

	curr_points -= 1

	match stat_name:
		"STR":
			strength_value += 1
			damage += 1.5
			max_health += 3.0

			reset_health()

		"DEX":
			dexterity_value += 1
			move_speed += 2.0
			crit_chance += 2.0

		"INT":
			intelligence_value += 1
			max_mana += 15.0
			crit_damage += 5

			reset_mana()

	EventBus.on_player_stats_updated.emit()


func downgrade_stat(stat_name: String) -> void:
	match stat_name:
		"STR":
			if strength_value <= 0:
				return

			strength_value -= 1
			damage -= 1.5
			max_health -= 3.0

			reset_health()

		"DEX":
			if dexterity_value <= 0:
				return

			dexterity_value -= 1
			move_speed -= 2.0
			crit_chance -= 2.0

		"INT":
			if intelligence_value <= 0:
				return

			intelligence_value -= 1
			max_mana -= 15.0
			crit_damage -= 5

			reset_mana()

	curr_points += 1

	EventBus.on_player_stats_updated.emit()


func add_exp(value: float) -> void:
	curr_exp += value
	while curr_exp >= next_level_exp:
		level_up()
	EventBus.on_player_new_level.emit(curr_exp, next_level_exp)

func level_up() -> void:
	curr_exp -= next_level_exp
	curr_level += 1
	curr_points += 4
	next_level_exp *= exp_multiplier
	EventBus.on_player_stats_updated.emit()

func use_mana(value: float) -> void:
	curr_mana -= value
	curr_mana = max(curr_mana, 0)
	EventBus.on_player_mana_updated.emit(curr_mana, max_mana)

func add_mana(value: float) -> void:
	curr_mana += value
	curr_mana = min(curr_mana, max_mana)
	EventBus.on_player_mana_updated.emit(curr_mana, max_mana)

func setup() -> void:
	reset_health()
	reset_mana()
	next_level_exp = base_exp

func reset_health() -> void:
	health_component.setup(max_health)
	EventBus.on_player_health_updated.emit(max_health, max_health)

func reset_mana() -> void:
	curr_mana = max_mana
	EventBus.on_player_mana_updated.emit(max_mana, max_mana)

func get_damage(skill_dmg: float = 0.0) -> float:
	var total_dmg = damage + skill_dmg

	# Add bonus damage of each equipment
	for equip: EquipData in GameData.equipment.values():
		if equip:
			total_dmg += equip.bonus_damage

	# Check our critical attack
	if randf() * 100 <= crit_chance:
		total_dmg *= (1.0 + (crit_damage / 100.0))

	return total_dmg

func enable_weapon_collision(value: bool) -> void:
	enemy_attack_area.monitoring = value


func _on_health_component_on_health_changed(curr_health: float) -> void:
	EventBus.on_player_health_updated.emit(curr_health, max_health)

func _on_health_component_on_dead() -> void:
	queue_free()
