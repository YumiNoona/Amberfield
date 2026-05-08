extends Area2D
class_name Enemy

@warning_ignore("unused_signal")
signal on_enemy_died

@export var max_health: float = 10.0
@export var damage: float = 2.0
@export var exp_amount: float = 20.0

@onready var selector: Sprite2D = $Selector
@onready var health_component: HealthComponent = $HealthComponent
@onready var fsm: FSM = $FSM
@onready var anim_sprite: AnimatedSprite2D = $AnimSprite

var enemy_zone : EnemyZone

func _ready() -> void:
	health_component.setup(max_health)

func _process(delta: float) -> void:
	if fsm.curr_state:
		fsm.curr_state.process_state(delta)
		
func update_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			anim_sprite.play("Walk_Right")
		else:
			anim_sprite.play("Walk_Left")
	else:
		if dir.y > 0:
			anim_sprite.play("Walk_Down")
		else:
			anim_sprite.play("Walk_Up")

func select_enemy() -> void:
	selector.show()


func deselect_enemy() -> void:
	selector.hide()

func _on_health_component_on_dead() -> void:
	on_enemy_died.emit()
	queue_free()
