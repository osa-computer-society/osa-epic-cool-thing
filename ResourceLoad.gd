extends Node

var font
var choice_template

func _enter_tree():
	font = load("res://addons/SyndiBox/Assets/TextDefault.tres")
	choice_template = load("res://src/Choice.tscn")
