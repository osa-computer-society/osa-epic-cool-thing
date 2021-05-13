extends Control

var hud
var start_pos = Vector2(0, -250)
var vis_pos = Vector2(0, 0)
var chose_pos
var chose_dropdown = null
var dropdown_open = false
export var dropdowns = []

func _ready():
	hud = get_node("../../HUD/Holder")
	for i in range(dropdowns.size()):
		dropdowns[i] = get_node(dropdowns[i])
	
func pause():
	visible = true
	get_tree().paused = true
	hud.visible = false
	
func _on_Resume_pressed():
	visible = false
	get_tree().paused = false 
	hud.visible = true


func _on_VBoxContainer_accept_choice(index):
	if index != 4: #index of resume option
		for dropdown in dropdowns:
			dropdown.rect_position = start_pos; 
		chose_dropdown = dropdowns[index]
		chose_pos = vis_pos
		dropdown_open = true
	else:
		_on_Resume_pressed()

func _process(delta):
	if chose_dropdown != null:
		chose_dropdown.rect_position = chose_dropdown.rect_position.linear_interpolate(chose_pos, delta * 2)
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if !visible:
			pause()
		else:
			if dropdown_open:
				chose_pos = start_pos
				$Choices/VBoxContainer.active = true
				dropdown_open = false
			else:
				_on_Resume_pressed()
		
