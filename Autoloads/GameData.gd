extends Node


var equipment: Dictionary[String, EquipData] = {
	"helmet": null,
	"armour": null,
	"weapon": null,
	"legs": null,
	"ring": null,
}

var skill_slots: Array[SkillData] = [null, null, null, null]
var skill_cooldowns: Array[float] = [0.0, 0.0, 0.0, 0.0]

var coins: float = 500.0
