extends Node

var font
var choice_template
var dialogue_profiles = {}
var profiles_dir = Directory.new()
var profile_dir = Directory.new()
var green_bar
var yellow_bar
var red_bar

func _enter_tree():
	font = load("res://addons/SyndiBox/Assets/TextDefault.tres")
	choice_template = load("res://src/Choice.tscn")
	green_bar = load("res://assets/green bar.png")
	yellow_bar = load("res://assets/yellow bar.png")
	red_bar = load("res://assets/red bar.png")
	if profiles_dir.open("res://assets/Profiles") == OK:
		profiles_dir.list_dir_begin(true)
		var file_name = profiles_dir.get_next()
		while file_name != "":
			if profiles_dir.current_is_dir():
				dialogue_profiles[file_name] = {}
				profile_dir.open(profiles_dir.get_current_dir() + "/" + file_name)
				profile_dir.list_dir_begin(true)
				var file_name2 = profile_dir.get_next()
				while file_name2 != "":
					if file_name2.ends_with(".jpg") or file_name2.ends_with(".png"):
						dialogue_profiles[file_name][file_name2.get_basename()] = load(profile_dir.get_current_dir() + "/" + file_name2)
					file_name2 = profile_dir.get_next()
				profile_dir.list_dir_end()
			file_name = profiles_dir.get_next()
		profiles_dir.list_dir_end()
		#print(dialogue_profiles)
	else:
		print_debug("Can't open profiles")
