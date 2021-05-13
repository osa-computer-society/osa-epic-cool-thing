extends Node

export(String, FILE, "*.json") var dialogue_path = "" # path of json dialogue file
export (bool) var needs_interact = true # if dialogue needs to start when interacting with something
export (NodePath) var interact_script # set as path of your interact detect ndoe

var repeated = false

var file = File.new()

var player
var dialogue_data
var dialogue_nodes
var dialogue_box
var dialogue_box_holder
var profile_holder
var profile
var name_holder
var name_label
var choices_box
var choice_boxes = {}
var choices_container
var choices = []
var syndibox
var choice_index = 0
var chose_next = false
var choice_controller

var current_node_id = -1 # handles the current node we are traversing Note: -1 exits the dialogue
var current_node_name # name of the speaker 
var current_node_text # dialogue text
var current_node_next_id # connect to the next node Note: ignored if curent_node_choices has things inside
var current_node_choices = [] # If you want more than one possible answer, you should fill this up
var current_node_profile

func grab_node(id):
	for node in dialogue_nodes:
		if node["id"] == id:
			current_node_name = node["name"]
			current_node_text = node["text"]
			current_node_next_id = node["next_id"]
			current_node_choices = node["choices"]
			current_node_profile = node["mood"]
	
func _ready():
	file.open(dialogue_path, File.READ)
	dialogue_data = JSON.parse(file.get_as_text())
	file.close()
	if dialogue_data.error != OK:
		print_debug("Corrupted file")
	else:
		dialogue_data = dialogue_data.result
		dialogue_nodes = dialogue_data["Nodes"]
		player = get_node("../Player")
		dialogue_box = get_node("../Player/DialogueBox/Canvas/SyndiBox")
		dialogue_box_holder = dialogue_box.get_parent()
		choices_box = dialogue_box_holder.get_node("Choices")
		choice_boxes[4] = choices_box.get_child(0)
		choice_boxes[3] = choices_box.get_child(1)
		choice_boxes[2] = choices_box.get_child(2)
		choices_container = choices_box.get_child(0)
		profile_holder = dialogue_box_holder.get_node("Profile BG")
		profile = profile_holder.get_child(0)
		name_holder = dialogue_box_holder.get_node("Name")
		name_label = name_holder.get_child(0)
		dialogue_box.connect("text_finished", self, "advance_dialogue")
		dialogue_box.connect("turn_on_choices", self, "turn_on_choice_box")
		if needs_interact:
			interact_script = get_node(interact_script)
			interact_script.connect("interact", self, "start_dialogue")
		

func update_ui():
	if current_node_profile == "none":
		profile_holder.visible = false
	else:
		profile_holder.visible = true
		#print(ResourceLoad.dialogue_profiles[current_node_name][current_node_profile])
		if profile.set_texture(ResourceLoad.dialogue_profiles[current_node_name][current_node_profile]) == OK:
			print_debug("Profile not found" + ' ' + current_node_name + ' ' + current_node_profile)
	if current_node_name == "none":
		name_holder.visible = false
	else:
		name_holder.visible = true
		name_label.set_text(current_node_name)
	dialogue_box.start(current_node_text)
		
func advance_dialogue():
	if chose_next:
		chose_next = false
	elif current_node_choices == []:
		current_node_id = current_node_next_id
	else:
		dialogue_box.waiting_for_response = true
	grab_node(current_node_id)
	if current_node_id >= 0:
		update_ui()
	else:
		dialogue_box_holder.visible = false
		player.in_dialogue = false
	
func turn_on_choice_box():
	choices_box = choice_boxes[len(current_node_choices)]
	choice_controller = choices_box.get_child(0)
	choice_controller.connect("accept_choice", self, "accept_choice")
	choices_box.visible = true
	choices_container = choices_box.get_child(0)
	choice_controller.choices = []
	choices = []
	choice_controller.active = true
	for n in choices_container.get_children():
		choices_container.remove_child(n)
		n.queue_free()
	for choice in current_node_choices:
		var text = ResourceLoad.choice_template.instance()
		text.text = choice["text"]
		choices_container.add_child(text)
		choice_controller.choices.append(text)
		choices.append(choice["next_id"])
	choice_controller.choice_index = 0
	choice_controller.choices[choice_index].get_child(0).get_child(0).visible = true
	choices_box.visible = true
	
func start_dialogue():
	if not player.in_dialogue:
		player.in_dialogue = true
		current_node_id = 0
		grab_node(current_node_id)
		if current_node_choices != []:
			dialogue_box.waiting_for_response = true
		update_ui()
		dialogue_box_holder.visible = true
	
func accept_choice(index):
	current_node_id = choices[index]
	dialogue_box.waiting_for_response = false
	dialogue_box.choice_box_open = false
	choices_box.visible = false
	chose_next = true
