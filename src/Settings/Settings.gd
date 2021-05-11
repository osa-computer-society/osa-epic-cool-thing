extends Control

func pause():
	visible = true
	get_tree().paused = true
	
func _on_Resume_pressed():
	visible = false
	get_tree().paused = false 
	print("yuh")
