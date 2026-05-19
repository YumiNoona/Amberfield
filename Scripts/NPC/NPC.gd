extends Area2D
class_name  NPC

enum NPCType {
	ROAM,
	SHOP,
	QUEST,
	CRAFTING
}

@export var type: NPCType
@export var dialogue: DialogueData


@export_group("Movement")

@export var can_move: bool
@export var move_speed: float = 30.0
@export var wait_time: float = 3.0

@onready var anim_sprite: AnimatedSprite2D = $AnimSprite
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent
@onready var timer: Timer = $Timer

var last_direction: String = "Down"

func _ready() -> void:

	# Skip movement setup if NPC cannot move
	if not can_move:
		return

	await get_tree().process_frame

	set_new_target()


func _process(delta: float) -> void:
	if not can_move:
		return
	if is_waiting_for_next_move():
		play_animation("Idle") 
		return
	if has_reached_target():
		if timer.is_stopped():
			timer.start(wait_time)
		return
	var next_path_pos: Vector2 = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_pos)
	global_position += direction * move_speed * delta
	update_direction(direction)
	play_animation("Walk") 


func set_new_target() -> void:

	if not Reference.navigation:
		return

	# Get all used navigation cells
	var used_cells: Array[Vector2i] = (Reference.navigation.get_used_cells())
	if used_cells.is_empty():
		return
		
	var random_cell: Vector2i = used_cells.pick_random()
	var world_pos: Vector2 = Reference.navigation.to_global(Reference.navigation.map_to_local(random_cell))
	
	navigation_agent.target_position = world_pos

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.is_pressed() \
	and event.button_index == MOUSE_BUTTON_LEFT:

		if dialogue:
			EventBus.on_dialogue_started.emit(dialogue)

func is_waiting_for_next_move() -> bool:
	return not timer.is_stopped()


func has_reached_target() -> bool:
	return navigation_agent.is_navigation_finished()


func play_animation(anim: String) -> void:
	var anim_name = anim.capitalize()  # "idle" -> "Idle", "walk" -> "Walk"
	if last_direction == "Left":
		anim_sprite.flip_h = true
		anim_sprite.play("%s%s" % [anim_name, "Right"])
	else:
		anim_sprite.flip_h = false
		anim_sprite.play("%s%s" % [anim_name, last_direction.capitalize()])

func update_direction(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		last_direction = "Right" if dir.x > 0 else "Left"
	else:
		last_direction = "Down" if dir.y > 0 else "Up"


func _on_timer_timeout() -> void:
	set_new_target()
