extends Button
class_name SkillButton

@export var is_free: bool
@export var skill_data: SkillData

@onready var skill_icon: TextureRect = $SkillIcon
@onready var lock: TextureRect = $Lock

var skill: SkillData
var is_unlocked: bool

func _ready() -> void:
	enable_skill(false)
	
	if skill_data:
		load_data(skill)
	if is_free:
		enable_skill(true)

func load_data(data: SkillData) -> void:
	skill = data
	skill_icon.texture = data.icon


func enable_skill(value: bool) -> void:
	skill_icon.self_modulate = (Color.WHITE if value else Color("787878"))
	lock.visible = not value
