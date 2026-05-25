extends Button
class_name PurchaseButton

signal on_item_purchased

@onready var price: Label = %Price
@onready var item_icon: TextureRect = %ItemIcon

var item: ItemData

func load_item(data: ItemData) -> void:
	item = data
	item_icon.texture = data.icon
	price.text = str(data.price)



func _on_shop_button_pressed() -> void:
	if GameData.coins < item.price:
		return

	GameData.coins -= item.price
	Inventory.add_item(item)
	on_item_purchased.emit()
