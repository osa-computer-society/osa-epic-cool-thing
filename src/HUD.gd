extends CanvasLayer

var settings

func update_bar(bar_name, value, max_value):
	get_node("Holder/Bars/" + bar_name).update_ui(value, max_value)
	
func _ready():
	settings = get_node("../Settings/Holder")

func _on_Settings_pressed():
	if not settings.visible:
		settings.pause()
	else:
		settings._on_Resume_pressed()
