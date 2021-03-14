extends Node

export(String, FILE, "*.json") var dialogue_path = ""
export (bool) var needs_interact = true
export (NodePath) var interact_script

var repeated = false

var file = File.new()

var dialogue_data
var dialogue_nodes
var dialogue_box
var dialogue_box_holder
var choices_box
var choice_boxes = {}
var choices_container
var choices
var syndibox
var choice_index = 0
var chose_next = false

var current_node_id = -1 # handles the current node we are traversing Note: -1 exits the dialogue
var current_node_name # name of the speaker 
var current_node_text # dialogue text
var current_node_next_id # connect to the next node Note: ignored if curent_node_choices has things inside
var current_node_choices = [] # If you want more than one possible answear, you should fill this up

func grab_node(id):
	for node in dialogue_nodes:
		if node["id"] == id:
			current_node_name = node["name"]
			current_node_text = node["text"]
			current_node_next_id = node["next_id"]
			current_node_choices = node["choices"]
	
func _ready():
	file.open(dialogue_path, File.READ)
	dialogue_data = JSON.parse(file.get_as_text())
	file.close()
	if dialogue_data.error != OK:
		print_debug("Corrupted file")
	else:
		dialogue_data = dialogue_data.result
		dialogue_nodes = dialogue_data["Nodes"]
		dialogue_box = get_node("../Player/DialogueBox/Canvas/SyndiBox")
		dialogue_box_holder = dialogue_box.get_parent()
		choices_box = dialogue_box_holder.get_node("Choices")
		choice_boxes[4] = choices_box.get_child(0)
		choice_boxes[3] = choices_box.get_child(1)
		choice_boxes[2] = choices_box.get_child(2)
		choices_container = choices_box.get_child(0)
		dialogue_box.connect("text_finished", self, "advance_dialogue")
		dialogue_box.connect("turn_on_choices", self, "turn_on_choice_box")
		if needs_interact:
			interact_script = get_node(interact_script)
			print()
			interact_script.connect("interact", self, "start_dialogue")

func update_ui():
	#print(current_node_name)
	dialogue_box.change_name(current_node_name)
	dialogue_box.start(current_node_text)
	
func advance_dialogue():
	if chose_next:
		chose_next = false
	elif current_node_choices == []:
		current_node_id = current_node_next_id
	else:
		dialogue_box.waiting_for_response = true
		#current_node_id = current_node_next_id
	grab_node(current_node_id)
	if current_node_id >= 0:
		update_ui()
	else:
		dialogue_box_holder.visible = false
	
func turn_on_choice_box():
	#choices_box.scale.y = len(current_node_choices) * 0.3
	#choices_box.set_texture(ResourceLoad.choice_boxes[len(current_node_choices)])
	choices = []
	choices_box = choice_boxes[len(current_node_choices)]
	choices_box.visible = true
	choices_container = choices_box.get_child(0)
	for n in choices_container.get_children():
		choices_container.remove_child(n)
		n.queue_free()
	for choice in current_node_choices:
		var text = ResourceLoad.choice_template.instance()
		text.text = choice["text"]
		choices_container.add_child(text)
		choices.append([text, choice["next_id"]])
	choice_index = 0
	choices[choice_index][0].get_child(0).visible = true
	choices_box.visible = true
	
func start_dialogue():
	current_node_id = 0
	grab_node(current_node_id)
	if current_node_choices != []:
		dialogue_box.waiting_for_response = true
		print("wait")
	update_ui()
	dialogue_box_holder.visible = true
	
func _input(event):
	if dialogue_box.choice_box_open:
		if event.is_action_pressed("ui_down"):
			choices[choice_index][0].get_child(0).visible = false
			choice_index -= 1
			if choice_index == -1:
				choice_index = len(current_node_choices) - 1
			choices[choice_index][0].get_child(0).visible = true
		elif event.is_action_pressed("ui_up"):
			choices[choice_index][0].get_child(0).visible = false
			choice_index += 1
			if choice_index == len(current_node_choices):
				choice_index = 0
			choices[choice_index][0].get_child(0).visible = true
		elif event.is_action_pressed("ui_accept"):
			current_node_id = choices[choice_index][1]
			dialogue_box.waiting_for_response = false
			dialogue_box.choice_box_open = false
			choices_box.visible = false
			chose_next = true
			#print(current_node_next_id)
			#advance_dialogue()