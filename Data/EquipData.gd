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

func get_equip_key() -> String:
	match equip_type:
		EquipType.HELMET:
			return "helmet"

		EquipType.ARMOUR:
			return "armour"

		EquipType.LEGS:
			return "legs"

		EquipType.WEAPON:
			return "weapon"

		EquipType.RING:
			return "ring"

	return ""
