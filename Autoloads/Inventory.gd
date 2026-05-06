extends Node

signal on_inventory_changed
signal on_equipment_changed

const INVENTORY_SIZE: int = 30

var inventory: Array[SlotData]

func _ready() -> void:
	inventory.clear()
	inventory.resize(INVENTORY_SIZE)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		add_item(preload("uid://dmt3b2d6itqv"), 10)

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

func get_slot(index: int) -> SlotData:
	if index >= 0 and index < inventory.size():
		return inventory[index]

	return null
