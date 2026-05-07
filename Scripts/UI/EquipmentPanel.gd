extends PanelContainer
class_name EquipmentPanel


@onready var slots: Array[EquipmentSlot] = [
	%"Helmet Slot", 
	%"Armour Slot", 
	%"Sword Slot", 
	%"Legs Slot", 
	%"Ring Slot"
]


func _ready() -> void:
	Inventory.on_equipment_changed.connect(_on_equipment_changed)

	for slot: EquipmentSlot in slots:
		slot.pressed.connect(_on_slot_pressed.bind(slot))


func _on_equipment_changed() -> void:
	pass


func _on_slot_pressed(slot: EquipmentSlot) -> void:
	pass
