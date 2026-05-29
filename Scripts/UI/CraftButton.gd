extends Button
class_name CraftButton

@onready var item_icon: TextureRect = $TextureRect

var data: CraftData

func load_data(craft_data: CraftData) -> void:
	data = craft_data
	item_icon.texture = craft_data.craft_item.icon
