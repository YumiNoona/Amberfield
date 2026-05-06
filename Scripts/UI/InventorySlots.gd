extends Button
class_name InventorySlots

@warning_ignore("unused_signal")
signal on_slot_clicked(slot_index: int, button: int)

@warning_ignore("unused_signal")
signal on_slot_hovered(slot_index: int)


@onready var item_icon: TextureRect = $ItemIcon
@onready var amount_label: Label = $AmountLabel
@onready var selecter: TextureRect = $Selecter

var slot_index: int = -1
var slot_data: SlotData

func load_data(data: SlotData) -> void:
	slot_data = data
	
	if slot_data and slot_data.item:
		item_icon.texture = slot_data.item.icon
		item_icon.show()

		if slot_data.quantity > 1:
			amount_label.text = str(slot_data.quantity)
			amount_label.show()
		else:
			amount_label.hide()
	else:
		clear_slot()

func clear_slot() -> void:
	slot_data = null
	
	item_icon.texture = null
	item_icon.hide()
	amount_label.hide()
