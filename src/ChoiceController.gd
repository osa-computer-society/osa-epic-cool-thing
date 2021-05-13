extends VBoxContainer

var choices = []
export var active = false
var choice_index = 0

signal accept_choice(index)

func _ready():
	if get_child_count() > 0:
		for child in get_children():
			choices.append(child)
		choices[0].get_child(0).get_child(0).visible = true
	
func _input(event):
	if active:
		if event.is_action_pressed("ui_up"):
			choices[choice_index].get_child(0).get_child(0).visible = false
			choice_index -= 1
			if choice_index == -1:
				choice_index = len(choices) - 1
			choices[choice_index].get_child(0).get_child(0).visible = true
		elif event.is_action_pressed("ui_down"):
			choices[choice_index].get_child(0).get_child(0).visible = false
			choice_index += 1
			if choice_index == len(choices):
				choice_index = 0
			choices[choice_index].get_child(0).get_child(0).visible = true
		elif event.is_action_pressed("ui_accept"):
			emit_signal("accept_choice", choice_index)
			active = false
