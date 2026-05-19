extends Control
class_name DialoguePanel

@onready var npc_portrait: AnimatedSprite2D = $"NPC Potrait"
@onready var npc_name: Label = $"NPC Name"
@onready var dialogue_label: Label = %DialogueLabel

var curr_dialogue: DialogueData
var curr_line_index: int = 0
var curr_page_index: int = 0
var pages: Array[String] = []
var typing_speed: float = 0.03
var is_typing: bool
var tween: Tween

const MAX_CHARS: int = 120  # adjust this to fit your dialogue box size

func _ready() -> void:
	hide()
	EventBus.on_dialogue_started.connect(_on_dialogue_started)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		if is_typing:
			complete_line()
		else:
			next_page()

func _on_dialogue_started(data: DialogueData) -> void:
	curr_dialogue = data
	curr_line_index = 0
	npc_name.text = data.npc_name
	if data.npc_sprite_frames:
		npc_portrait.sprite_frames = data.npc_sprite_frames
	show()
	show_line()

func split_into_pages(text: String) -> Array[String]:
	var result: Array[String] = []
	# Split by words
	var words = text.split(" ")
	var current_page = ""
	for word in words:
		var test = current_page + ("" if current_page == "" else " ") + word
		if test.length() > MAX_CHARS:
			result.append(current_page)
			current_page = word
		else:
			current_page = test
	if current_page != "":
		result.append(current_page)
	return result

func show_line() -> void:
	if curr_line_index >= curr_dialogue.lines.size():
		end_dialogue()
		return
	# Split current line into pages
	pages = split_into_pages(curr_dialogue.lines[curr_line_index])
	curr_page_index = 0
	play_emotion()
	show_page()

func play_emotion() -> void:
	var anim = curr_dialogue.default_animation if curr_dialogue.default_animation != "" else "Talk"
	if curr_line_index < curr_dialogue.emotions.size():
		var emotion = curr_dialogue.emotions[curr_line_index]
		if emotion != "":
			anim = emotion
	if npc_portrait.sprite_frames and npc_portrait.sprite_frames.has_animation(anim):
		npc_portrait.play(anim)

func show_page() -> void:
	var text = pages[curr_page_index]
	dialogue_label.text = text
	dialogue_label.visible_characters = 0
	is_typing = true
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(dialogue_label, "visible_characters",
		text.length(), text.length() * typing_speed)
	tween.finished.connect(func(): is_typing = false, CONNECT_ONE_SHOT)

func next_page() -> void:
	curr_page_index += 1
	if curr_page_index < pages.size():
		# More pages in this line — same emotion keeps playing
		show_page()
	else:
		# All pages done — move to next line
		curr_line_index += 1
		show_line()

func complete_line() -> void:
	if tween:
		tween.kill()
	dialogue_label.visible_characters = -1
	is_typing = false

func end_dialogue() -> void:
	npc_portrait.stop()
	hide()
	curr_dialogue = null
	EventBus.on_dialogue_finished.emit()
