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

var is_dead: bool = false
var hit_enemies_this_attack: Array = []

var selected_enemy: Enemy:
	set(value):
		if selected_enemy:
			selected_enemy.deselect_enemy()
		selected_enemy = value
		selected_enemy.select_enemy()

func _process(delta: float) -> void:
	if is_dead:
		return
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

func play_damage_anim() -> void:
	if is_dead:
		return
	print("[PLAYER] taking damage, playing damage anim | direction: %s" % last_direction)
	play_direction_anim("Damage")
	if not anim_sprite.animation_finished.is_connected(_on_damage_anim_finished):
		anim_sprite.animation_finished.connect(_on_damage_anim_finished, CONNECT_ONE_SHOT)

func _on_damage_anim_finished() -> void:
	if is_dead:
		return
	print("[PLAYER] damage anim finished, resuming state: %s" % fsm.curr_state.name)
	fsm.curr_state.enter_state()

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
	print("[PLAYER] leveled up! level: %d | next level exp: %.1f" % [curr_level, next_level_exp])
	Reference.create_new_level_fx(global_position)
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
	for equip: EquipData in GameData.equipment.values():
		if equip:
			total_dmg += equip.bonus_damage
	if randf() * 100 <= crit_chance:
		total_dmg *= (1.0 + (crit_damage / 100.0))
	return total_dmg

func enable_weapon_collision(value: bool) -> void:
	print("[PLAYER] EnemyAttackArea monitoring: %s" % value)
	enemy_attack_area.monitoring = value

func _on_health_component_on_health_changed(curr_health: float) -> void:
	print("[PLAYER] health changed: %.1f / %.1f" % [curr_health, max_health])
	EventBus.on_player_health_updated.emit(curr_health, max_health)
	play_damage_anim()

func _on_health_component_on_dead() -> void:
	print("[PLAYER] died")
	is_dead = true
	fsm.curr_state.exit_state()
	play_direction_anim("Dead")
	anim_sprite.animation_finished.connect(_on_dead_anim_finished, CONNECT_ONE_SHOT)

func _on_dead_anim_finished() -> void:
	print("[PLAYER] dead anim finished, removing")
	queue_free()

func _on_enemy_attack_area_area_entered(area: Area2D) -> void:
	var enemy = area as Enemy
	if not enemy:
		print("[PLAYER ATTACK] area entered but not Enemy: %s" % area.name)
		return
	if enemy in hit_enemies_this_attack:
		print("[PLAYER ATTACK] already hit %s this swing, skipping" % enemy.name)
		return
	hit_enemies_this_attack.append(enemy)
	var dmg = get_damage()
	print("[PLAYER ATTACK] hit %s for %.1f dmg | enemy health after: %.1f" % [enemy.name, dmg, enemy.health_component.curr_health - dmg])
	enemy.health_component.take_damage(dmg)
	Reference.create_damage_text(enemy.global_position, dmg)
