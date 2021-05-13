extends Control

export var green_to_red = true
onready var new_value = $ProgressBar.value

func update_ui(value, max_value):
	$Number.text = str(value)
	var percent = floor(float(value) / max_value * 100) #convert to percent
	new_value = percent
	#$ProgressBar.value = percent
	if green_to_red:
		if percent > 70:
			update_bar_texture(ResourceLoad.green_bar)
		elif percent > 40:
			update_bar_texture(ResourceLoad.yellow_bar)
		else:
			update_bar_texture(ResourceLoad.red_bar)
func update_bar_texture(new_texture):
	$ProgressBar.texture_progress = new_texture
func _process(delta):
	$ProgressBar.value = lerp($ProgressBar.value, new_value - 2, 0.2)
	#print($ProgressBar.value, new_value)
