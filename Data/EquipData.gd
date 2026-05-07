extends ItemData
class_name EquipData

enum EquipType {
	HELMET,
	BODY,
	LEGS,
	WEAPON,
	RING
}

@export var equip_type: EquipType

func _init() -> void:
	type = Type.EQUIPMENT
	max_stack = 1

func get_equip_key() -> String:
	match equip_type:
		EquipType.HELMET:
			return "helmet"

		EquipType.BODY:
			return "body"

		EquipType.LEGS:
			return "legs"

		EquipType.WEAPON:
			return "weapon"

		EquipType.RING:
			return "ring"

	return ""
