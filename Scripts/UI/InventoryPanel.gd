extends PanelContainer
class_name InventoryPanel

@onready var inventory_container: GridContainer = %InventoryContainer
@onready var gold_label: Label = %GoldLabel

@export var grabbed_slot : InventorySlots

var slots: Array[InventorySlots]
var selected_slot_index:int = -1


func _ready() -> void:
	Inventory.on_inventory_changed.connect(_on_inventory_changed)
	for i in inventory_container.get_child_count():
		var slot: InventorySlots = inventory_container.get_child(i)
		slot.on_slot_clicked.connect(_on_slot_clicked)
		slot.on_slot_hovered.connect(_on_slot_hovered)
		slot.slot_index = i
		slots.append(slot)



func _process(_delta: float) -> void:
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position()



func select_slot(slot_index: int) -> void:
	deselect_slot()

	selected_slot_index = slot_index

	var slot: SlotData = Inventory.get_slot(slot_index)

	grabbed_slot.load_data(slot)
	grabbed_slot.show()



func deselect_slot() -> void:
	selected_slot_index = -1
	grabbed_slot.hide()



func handle_left_button(slot_index: int) -> void:
	# If a slot is selected, try to swap or merge
	if selected_slot_index >= 0 and selected_slot_index != slot_index:
		var from_item = Inventory.get_slot_item(selected_slot_index)
		var to_item = Inventory.get_slot_item(slot_index)

		if from_item and to_item and from_item == to_item:
			Inventory.merge_slots(selected_slot_index, slot_index)
		else:
			Inventory.swap_slots(selected_slot_index, slot_index)

		deselect_slot()

	else:
		# Select / Deselect slot
		if selected_slot_index == slot_index:
			deselect_slot()
		else:
			# Only select if the slot has an item
			if Inventory.get_slot(slot_index):
				select_slot(slot_index)



func handle_right_button(slot_index: int) -> void:
	var item = Inventory.get_slot_item(slot_index)

	if not item:
		return

	if item is EquipData:
		Inventory.equip_item(slot_index)
	else:
		Inventory.use_item(slot_index)

		EventBus.on_inventory_used_item.emit(item)



func _on_inventory_changed() -> void:
	for i in slots.size():
		var slot: SlotData = Inventory.get_slot(i)
		slots[i].load_data(slot)


func _on_slot_clicked(slot_index: int, button: int) -> void:
	match button:
		MOUSE_BUTTON_LEFT:
			handle_left_button(slot_index)

		MOUSE_BUTTON_RIGHT:
			handle_right_button(slot_index)


func _on_slot_hovered(_slot_index: int) -> void:
	pass
