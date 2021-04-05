extends Area2D

var in_range = false

signal interact

func _on_InteractZone_body_entered(body):
	if body.is_in_group("Player"):
		body.interact_in_range.append(self)

func _on_InteractZone_body_exited(body):
	if body.is_in_group("Player"):
		body.interact_in_range.erase(self)

func _on_interact():
	emit_signal("interact")
