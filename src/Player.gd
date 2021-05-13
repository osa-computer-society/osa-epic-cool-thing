class_name Player
extends KinematicBody2D

signal player_killed
signal won
export (int) var speed = 100

var velocity := Vector2.ZERO
var treasures := 0
var extents : Vector2
var dead := false

var happiness = 100
var max_happiness = 100

var in_dialogue = false

var interact_in_range = []

func _ready():
	#Global.player = self
	update_happiness(happiness)
	
func get_extents():
	return $CollisionShape2D.shape.extents

func get_input():
	velocity = Vector2()
	if not in_dialogue:
		if Input.is_action_pressed("ui_right"):
			velocity.x += 1
		if Input.is_action_pressed("ui_left"):
			velocity.x -= 1
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1
		if Input.is_action_pressed("ui_up"):
			velocity.y -= 1
	velocity = velocity.normalized() * speed


func _physics_process(_delta):
	get_input()
	velocity = move_and_slide(velocity)


func die(obj, signal_str):
	if not dead:
		dead = true
		set_physics_process(false)
		print("player killed")
		if obj != null:
			yield(obj, signal_str)
		emit_signal("player_killed")


# must be called during idle period
func disable():
	visible = false
	$CollisionShape2D.disabled = true


func enable():
	dead = false
	visible = true
	set_physics_process(true)
	$CollisionShape2D.disabled = false


#func count_treasures():
#	treasures = 0
#	for level in Global.treasures:
#		treasures += Global.treasures[level].size()
#	Global.emit_signal("update_treasure")
#
#
#func add_treasure():
#	treasures += 1
#	Global.emit_signal("update_treasure")
#	if treasures >= Global.ALL_TREASURES:
#		emit_signal("won")


func update_camera_limits(rect : Rect2):
	$Camera2D.limit_top = rect.position.y
	$Camera2D.limit_left = rect.position.x
	$Camera2D.limit_bottom = rect.end.y
	$Camera2D.limit_right = rect.end.x

func update_happiness(new_happiness):
	happiness = new_happiness
	$HUD.update_bar("Happiness", new_happiness, max_happiness)

func _input(event):
	if event.is_action_pressed("ui_down"):
		update_happiness(max(happiness - 10, 0))
	elif event.is_action_pressed("ui_up"):
		update_happiness(min(happiness + 10, 100))
	if event.is_action_pressed("interact") and interact_in_range != [] and not in_dialogue:
		interact_in_range[0]._on_interact() 
