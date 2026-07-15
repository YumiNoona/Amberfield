extends PanelContainer
class_name StatsPanel

@onready var dmg_label: Label = %DMGLabel
@onready var hp_label: Label = %HPLabel
@onready var vel_label: Label = %VelLabel
@onready var mana_label: Label = %ManaLabel
@onready var crit_label: Label = %CritLabel
@onready var c_dmg_label: Label = %CDmgLabel



@onready var current_level: Label = %CurrentLevel
@onready var current_points: Label = %CurrentPoints

@onready var strength_points: Label = %StrengthPoints
@onready var dexterity_points: Label = %DexterityPoints
@onready var intelligence_points: Label = %IntelligencePoints

func _ready() -> void:
	EventBus.on_player_created.connect(_on_player_created)
	EventBus.on_player_stats_updated.connect(_on_player_stats_updated)


func update_stats() -> void:
	if not is_instance_valid(Reference.player):
		return

	dmg_label.text = "DMG: %s" % str(Reference.player.damage)
	hp_label.text = "HP: %s" % str(Reference.player.max_health)
	vel_label.text = "VEL: %s" % str(Reference.player.move_speed)
	mana_label.text = "Mana: %s" % str(Reference.player.max_mana)

	crit_label.text = "CRIT: %s" % str(Reference.player.crit_chance)
	c_dmg_label.text = "C. DMG: %s" % str(Reference.player.crit_damage)

	current_level.text = "Level %s" % str(Reference.player.curr_level)
	current_points.text = "Points: %s" % str(Reference.player.curr_points)

	strength_points.text = str(Reference.player.strength_value)
	dexterity_points.text = str(Reference.player.dexterity_value)
	intelligence_points.text = str(Reference.player.intelligence_value)

func _on_strength_plus_button_pressed() -> void:
	Reference.player.upgrade_stat(Player.StatType.STR)

func _on_strength_minus_button_pressed() -> void:
	Reference.player.downgrade_stat(Player.StatType.STR)

func _on_dexterity_plus_button_pressed() -> void:
	Reference.player.upgrade_stat(Player.StatType.DEX)

func _on_dexterity_minus_button_pressed() -> void:
	Reference.player.downgrade_stat(Player.StatType.DEX)

func _on_intelligence_plus_button_pressed() -> void:
	Reference.player.upgrade_stat(Player.StatType.INT)

func _on_intelligence_minus_button_pressed() -> void:
	Reference.player.downgrade_stat(Player.StatType.INT)

func _on_player_created() -> void:
	update_stats()

func _on_player_stats_updated() -> void:
	update_stats()
