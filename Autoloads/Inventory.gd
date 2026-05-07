extends Node

@warning_ignore("unused_signal")
signal on_inventory_changed

@warning_ignore("unused_signal")
signal on_equipment_changed

const INVENTORY_SIZE: int = 30

var inventory: Array[SlotData]

func _ready() -> void:
	inventory.clear()
	inventory.resize(INVENTORY_SIZE)


#region Inventory Queries

func get_empty_slot_indexes() -> Array[int]:
	var empty: Array[int] = []

	for i in inventory.size():
		if inventory[i] == null:
			empty.append(i)

	return empty


# Search for an item and return the indices where it is found.
# If with_space is true, only return stacks that can hold more items.
func find_item_indexes(item: ItemData, with_space: bool = false) -> Array[int]:
	var found: Array[int] = []

	for i in inventory.size():
		var slot = inventory[i]

		if slot and slot.item == item:
			if with_space:
				if slot.quantity < item.max_stack:
					found.append(i)
			else:
				found.append(i)

	return found


func get_slot_item(index: int) -> ItemData:
	var slot = get_slot(index)

	if slot:
		return slot.item

	return null


func get_slot(index: int) -> SlotData:
	if index >= 0 and index < inventory.size():
		return inventory[index]

	return null

#endregion


#region Item Management

func add_item(item: ItemData, amount: int = 1) -> void:
	if not item:
		return

	var remaining = amount

	# 1. Stack onto existing stacks that have available space
	if item.max_stack > 1:
		for index in find_item_indexes(item, true):
			if remaining <= 0:
				break

			var slot = inventory[index]
			var space = item.max_stack - slot.quantity
			var to_give = min(space, remaining)

			slot.quantity += to_give
			remaining -= to_give

	# 2. Use empty slots for the remaining items
	if remaining > 0:
		for index in get_empty_slot_indexes():
			if remaining <= 0:
				break

			var to_give = min(item.max_stack, remaining)

			inventory[index] = SlotData.new(item, to_give)

			remaining -= to_give

	var added = amount - remaining

	if added > 0:
		on_inventory_changed.emit()


func use_item(slot_index) -> void:
	var slot: SlotData = inventory[slot_index]

	if not slot:
		return

	if not slot.item.is_consumable:
		return

	slot.quantity -= 1

	if slot.quantity <= 0:
		inventory[slot_index] = null

	on_inventory_changed.emit()


func can_use_item(slot_index: int) -> bool:
	var slot: SlotData = get_slot(slot_index)

	return slot and slot.item.is_consumable

#endregion


#region Slot Operations

func swap_slots(from_index: int, to_index: int) -> void:
	if from_index < 0 or from_index >= inventory.size():
		return

	if to_index < 0 or to_index >= inventory.size():
		return

	var temp = inventory[from_index]

	inventory[from_index] = inventory[to_index]
	inventory[to_index] = temp

	on_inventory_changed.emit()


func merge_slots(from_index: int, to_index: int) -> void:
	var from_slot: SlotData = get_slot(from_index)
	var to_slot: SlotData = get_slot(to_index)

	if not from_slot or not to_slot:
		return

	if from_slot.item != to_slot.item:
		return

	var item = from_slot.item

	if item.max_stack <= 1:
		return

	var space = item.max_stack - to_slot.quantity
	var to_move = min(space, from_slot.quantity)

	to_slot.quantity += to_move
	from_slot.quantity -= to_move

	if from_slot.quantity <= 0:
		inventory[from_index] = null
	elif space <= 0:
		swap_slots(from_index, to_index)

	on_inventory_changed.emit()

#endregion

#region Equipment

func equip_item(slot_index: int) -> void:
	var slot: SlotData = get_slot(slot_index)

	if not slot:
		return

	if not slot.item is EquipData:
		return

	var equip: EquipData = slot.item as EquipData
	var equip_key: String = equip.get_equip_key()

	var current_equipped_item = GameData.equipment[equip_key]

	GameData.equipment[equip_key] = equip

	inventory[slot_index] = null

	if current_equipped_item:
		add_item(current_equipped_item, 1)

	on_inventory_changed.emit()
	on_equipment_changed.emit()

#endregion
