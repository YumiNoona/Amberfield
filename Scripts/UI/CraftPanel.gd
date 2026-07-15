extends Control
class_name CraftPanel

@export var recipes: Array[CraftData]

@onready var container: GridContainer = %Container
@onready var materials_container: VBoxContainer = %MaterialsContainer

@onready var craft_icon: TextureRect = %CraftIcon
@onready var craft_name: Label = %CraftName

@onready var material_1_icon: TextureRect = %Material1Icon
@onready var material_1_name: Label = %Material1Name
@onready var material_1_quantity: Label = %Material1Quantity

@onready var material_2_icon: TextureRect = %Material2Icon
@onready var material_2_name: Label = %Material2Name
@onready var material_2_quantity: Label = %Material2Quantity

@onready var amount_label: Label = %AmountLabel

func _on_close_button_pressed() -> void:
	pass # Replace with function body.
