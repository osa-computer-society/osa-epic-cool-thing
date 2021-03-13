extends Node

var font
var choice_boxes = {}
var choice_template

func _enter_tree():
	font = load("res://addons/SyndiBox/Assets/TextDefault.tres")
	choice_boxes[2] = load("res://assets/vert border filled 2.png")
	choice_boxes[3] = load("res://assets/vert border filled 3.png")
	choice_boxes[4] = load("res://assets/vert border filled.png")
	choice_template = load("res://src/Choice.tscn")
