extends PanelContainer
class_name InventoryPanel

@onready var inventory_container: GridContainer = %InventoryContainer
@onready var gold_label: Label = %GoldLabel

var slots: Array[InventorySlots]

func _ready() -> void:
	Inventory.on_inventory_changed.connect(_on_inventory_changed)
	for i in inventory_container.get_child_count():
		var slot: InventorySlots = inventory_container.get_child(i)
		slot.on_slot_clicked.connect(_on_slot_clicked)
		slot.on_slot_hovered.connect(_on_slot_hovered)
		slot.slot_index = i
		slots.append(slot)


func _on_inventory_changed() -> void:
	for i in slots.size():
		var slot: SlotData = Inventory.get_slot(i)
		slots[i].load_data(slot)


func _on_slot_clicked() -> void:
	pass
	

func _on_slot_hovered() -> void:
	pass
