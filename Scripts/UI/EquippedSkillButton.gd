extends Button
class_name EquippedSkillButton

@onready var empty: Panel = $Empty
@onready var skill_icon: TextureRect = $SkillIcon
@onready var label: Label = $Label

@export var number: int

func _ready() -> void:
	label.text =str(number)
