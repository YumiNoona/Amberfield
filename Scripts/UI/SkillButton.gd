extends Button
class_name SkillButton

@export var is_free: bool
@export var skill_data: SkillData

@onready var skill_icon: TextureRect = $SkillIcon
@onready var lock_icon: TextureRect = $LockIcon

var skill: SkillData
var is_unlocked: bool

func _ready() -> void:
	enable_skill(false)
	
	if skill_data:
		load_data(skill_data)
	if is_free:
		enable_skill(true)

func load_data(data: SkillData) -> void:
	skill = data
	skill_icon.texture = data.icon


func enable_skill(value: bool) -> void:
	skill_icon.self_modulate = (Color.WHITE if value else Color("787878"))
	lock_icon.visible = not value


func _on_pressed() -> void:

	# Unlock skill if player has enough coins
	if not is_unlocked:

		if GameData.coins >= skill.price:
			GameData.coins -= skill.price

			is_unlocked = true

			enable_skill(true)

	# Equip unlocked skill
	else:
		Reference.hud.equip_skill_to_empty_slot(skill)
