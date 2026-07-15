extends CharacterBody2D
class_name Player

enum StatType { STR, DEX, INT }

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
@onready var animator: DirectionalAnimator = $DirectionalAnimator

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

func _ready() -> void:
	animator.damage_anim_finished.connect(_on_damage_anim_finished)
	animator.dead_anim_finished.connect(_on_dead_anim_finished)

func _process(delta: float) -> void:
	if is_dead:
		return
	for i in GameData.skill_cooldowns.size():
		if GameData.skill_cooldowns[i] > 0.0:
			GameData.skill_cooldowns[i] -= delta
	if fsm.curr_state:
		fsm.curr_state.process_state(delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Skill_1"):
		use_skill(0)

	elif event.is_action_pressed("Skill_2"):
		use_skill(1)

	elif event.is_action_pressed("Skill_3"):
		use_skill(2)

	elif event.is_action_pressed("Skill_4"):
		use_skill(3)

func is_moving() -> bool:
	var move_input = ["Move_Up", "Move_Down", "Move_Left", "Move_Right"]
	for input in move_input:
		if Input.is_action_pressed(input):
			return true
	return false

func _on_damage_anim_finished() -> void:
	if is_dead:
		return
	Reference.log("PLAYER", "damage anim finished, resuming state: %s" % fsm.curr_state.name)
	fsm.curr_state.enter_state()

#region Stats & Leveling

func upgrade_stat(stat: StatType) -> void:
	if curr_points <= 0:
		return
	curr_points -= 1
	match stat:
		StatType.STR:
			strength_value += 1
			damage += 1.5
			max_health += 3.0
			reset_health()
		StatType.DEX:
			dexterity_value += 1
			move_speed += 2.0
			crit_chance += 2.0
		StatType.INT:
			intelligence_value += 1
			max_mana += 15.0
			crit_damage += 5
			reset_mana()
	EventBus.on_player_stats_updated.emit()

func downgrade_stat(stat: StatType) -> void:
	match stat:
		StatType.STR:
			if strength_value <= 0:
				return
			strength_value -= 1
			damage -= 1.5
			max_health -= 3.0
			reset_health()
		StatType.DEX:
			if dexterity_value <= 0:
				return
			dexterity_value -= 1
			move_speed -= 2.0
			crit_chance -= 2.0
		StatType.INT:
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
	Reference.log("PLAYER", "leveled up! level: %d | next level exp: %.1f" % [curr_level, next_level_exp])
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

#endregion

#region Combat


func use_skill(index: int) -> void:
	if index < 0 or index >= GameData.skill_slots.size():
		return
	var skill: SkillData = GameData.skill_slots[index]
	if not skill:
		return
	if GameData.skill_cooldowns[index] > 0.0:
		return
	if not selected_enemy:
		return
	if curr_mana < skill.mana_cost:
		return
	use_mana(skill.mana_cost)
	GameData.skill_cooldowns[index] = skill.cooldown
	var total_dmg = get_damage(skill.base_dmg)
	selected_enemy.health_component.take_damage(total_dmg)
	if skill.explosion_effect:
		var exp_effect: Node2D = skill.explosion_effect.instantiate()
		exp_effect.global_position = selected_enemy.global_position
		get_tree().root.add_child(exp_effect)
	Reference.create_damage_text(selected_enemy.global_position,total_dmg)

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
	Reference.log("PLAYER", "EnemyAttackArea monitoring: %s" % value)
	enemy_attack_area.monitoring = value

#endregion

#region Lifecycle

func _on_health_component_on_health_changed(curr_health: float) -> void:
	Reference.log("PLAYER", "health changed: %.1f / %.1f" % [curr_health, max_health])
	EventBus.on_player_health_updated.emit(curr_health, max_health)
	animator.play_damage_anim()

func _on_health_component_on_dead() -> void:
	Reference.log("PLAYER", "died")
	is_dead = true
	fsm.curr_state.exit_state()
	animator.play_dead_anim()

func _on_dead_anim_finished() -> void:
	Reference.log("PLAYER", "dead anim finished, removing")
	queue_free()

func _on_enemy_attack_area_area_entered(area: Area2D) -> void:
	var enemy = area as Enemy
	if not enemy:
		Reference.log("PLAYER ATTACK", "area entered but not Enemy: %s" % area.name)
		return
	if enemy in hit_enemies_this_attack:
		Reference.log("PLAYER ATTACK", "already hit %s this swing, skipping" % enemy.name)
		return
	hit_enemies_this_attack.append(enemy)
	var dmg = get_damage()
	Reference.log("PLAYER ATTACK", "hit %s for %.1f dmg | enemy health after: %.1f" % [enemy.name, dmg, enemy.health_component.curr_health - dmg])
	enemy.health_component.take_damage(dmg)
	Reference.create_damage_text(enemy.global_position, dmg)

#endregion
