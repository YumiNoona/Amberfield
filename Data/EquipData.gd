extends ItemData
class_name EquipData

enum EquipType {
	HELMET,
	ARMOUR,
	WEAPON,
	LEGS,
	RING
}

@export var equip_type: EquipType
@export var bonus_damage: float = 0.0


func _init() -> void:
	type = Type.EQUIPMENT
	max_stack = 1
