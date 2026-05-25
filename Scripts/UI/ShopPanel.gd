extends Control
class_name ShopPanel

@export var items: Array[ItemData]

@onready var container: GridContainer = %Container
@onready var total_coins: Label = %TotalCoins


func _ready() -> void:
	for button in container.get_children():
		button.queue_free()

	load_shop_items()
	total_coins.text = str(GameData.coins)


func load_shop_items() -> void:
	for item: ItemData in items:
		var purchase_button: PurchaseButton = (Reference.PURCHASE_BUTTON_SCENE.instantiate())
		container.add_child(purchase_button)
		purchase_button.load_item(item)
		purchase_button.on_item_purchased.connect(_on_item_purchased)


func _on_item_purchased() -> void:
	total_coins.text = str(GameData.coins)


func _on_close_button_pressed() -> void:
	hide()
