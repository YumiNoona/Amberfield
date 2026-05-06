extends CanvasLayer
class_name HUD


@onready var health_label: Label = %HealthLabel
@onready var mana_label: Label = %ManaLabel

@onready var health_bar: ProgressBar = $HealthBar
@onready var mana_bar: ProgressBar = $ManaBar
@onready var exp_bar: ProgressBar = $ExpBar

@onready var equipment_panel: PanelContainer = %EquipmentPanel
@onready var inventory_panel: InventoryPanel = %InventoryPanel
@onready var stats_panel: StatsPanel = %StatsPanel
@onready var skills_panel: SkillsPanel = %SkillsPanel


func _ready() -> void:
	EventBus.on_player_health_updated.connect(on_player_health_updated)
	EventBus.on_player_mana_updated.connect(on_player_mana_updated)
	EventBus.on_player_new_level.connect(on_player_new_level)

func _on_equipment_pressed() -> void:
	equipment_panel.visible = not equipment_panel.visible


func _on_inventory_pressed() -> void:
	inventory_panel.visible = not inventory_panel.visible


func _on_stats_pressed() -> void:
	stats_panel.visible = not stats_panel.visible


func _on_skills_pressed() -> void:
	skills_panel.visible = not skills_panel.visible
	

func on_player_health_updated(curr: float, max: float) -> void:
	health_bar.value = curr / max
	health_label.text = "%d / %d" % [curr,max]
	
func on_player_mana_updated(curr: float, max: float) -> void:
	mana_bar.value = curr / max
	mana_label.text = "%d / %d" % [curr,max]

func on_player_new_level(curr: float, new_level: float) -> void:
	exp_bar.value = curr / new_level
