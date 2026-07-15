extends Button
class_name EquippedSkillButton

@export var number: int

@onready var empty: Panel = $Empty
@onready var skill_icon: TextureRect = $SkillIcon
@onready var label: Label = $Label
@onready var cooldown_overlay: ColorRect = $CooldownOverlay

var equipped_data: SkillData

func _ready() -> void:
	label.text = str(number)
	cooldown_overlay.visible = false

func _process(_delta: float) -> void:
	var cd: float = GameData.skill_cooldowns[number - 1]
	var skill: SkillData = GameData.skill_slots[number - 1]
	if cd > 0.0 and skill and skill.cooldown > 0.0:
		cooldown_overlay.visible = true
		cooldown_overlay.size.y = (cd / skill.cooldown) * skill_icon.size.y
	else:
		cooldown_overlay.visible = false


func equip_skill(data: SkillData) -> void:
	equipped_data = data

	empty.hide()

	skill_icon.texture = data.icon
	skill_icon.show()


func reset_skill_button() -> void:
	empty.show()
	skill_icon.hide()


func _on_pressed() -> void:

	# Remove equipped skill from slot
	if equipped_data:
		GameData.skill_slots[number - 1] = null

		equipped_data = null

		reset_skill_button()
