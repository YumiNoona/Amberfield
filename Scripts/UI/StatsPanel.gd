extends PanelContainer
class_name StatsPanel

@onready var dmg_label: Label = %DMGLabel
@onready var hp_label: Label = %HPLabel
@onready var vel_label: Label = %VelLabel
@onready var mana: Label = %Mana
@onready var crit_label: Label = %CritLabel
@onready var c_dmg_label: Label = %CDmgLabel


@onready var current_level: Label = %CurrentLevel
@onready var current_points: Label = %CurrentPoints

@onready var strength_points: Label = %StrengthPoints
@onready var dexterity_points: Label = %DexterityPoints
@onready var intelligence_points: Label = %IntelligencePoints


func _on_strength_plus_button_pressed() -> void:
	pass # Replace with function body.


func _on_dexterity_plus_button_pressed() -> void:
	pass # Replace with function body.


func _on_intelligence_plus_button_pressed() -> void:
	pass # Replace with function body.
