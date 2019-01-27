extends Node2D

var Level = preload("res://Level.tscn")
var level = null

func startLevel():
	level = Level.instance()
	level.connect("gameOver", self, "_on_Level_gameOver")
	add_child(level)

func endLevel():
	remove_child(level)
	level = null

func _input(event):
	if event.is_action_pressed('ui_select'):
		startLevel()
	if event.is_action_pressed('ui_cancel'):
		if level:
			endLevel()
		else:
			get_tree().quit()

func _on_Level_gameOver():
	print("gameover")
	endLevel()
