extends Node
class_name HealthComponent

signal on_health_changed(curr_health: float)
signal on_dead

var max_health: float
var curr_health: float
var is_dead: bool = false

func setup(value: float) -> void:
	max_health = value
	curr_health = value
	is_dead = false

func take_damage(value: float) -> void:
	if is_dead:
		return
	curr_health = max(curr_health - value, 0)
	on_health_changed.emit(curr_health)
	if curr_health <= 0:
		is_dead = true
		on_dead.emit()

func heal(value: float) -> void:
	if is_dead:
		return
	curr_health += value
	curr_health = min(curr_health, max_health)
	on_health_changed.emit(curr_health)
