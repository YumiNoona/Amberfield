extends Area2D
class_name DropItem

@export var item: ItemData
@export var amount: int = 1

@export var shine_speed := 0.6
@export var shine_freq := 2.0

@onready var icon: Sprite2D = $Icon


func _ready() -> void:
	setup()
	shine_item()

func setup() -> void:
	if item and item.icon:
		icon.texture = item.icon

func load_item(data: LootData) -> void:
	item = data.item
	amount = data.amount
	
func shine_item() -> void:
	var shine_tween := create_tween().set_loops()
	shine_tween.tween_property(icon.material,"shader_parameter/shine_progress",1.0,shine_speed).set_delay(shine_freq)
	shine_tween.tween_property(icon.material,"shader_parameter/shine_progress",0.0,0.0)
	


func _on_body_entered(_body: Node2D) -> void:
	Inventory.add_item(item, amount)
	queue_free()
