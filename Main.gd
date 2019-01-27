extends Node2D

var Level = load("res://Level.tscn")
var level = null
var level_num = 1

func startLevel():
	level = Level.instance()
	# number of rooms, light_decay, wolf probability, Initial text
	if level_num == 1:
		level.init(2, 0.0001, 0, "Se hizo de noche, tengo que volver a casa!")
	level.connect("gameOver", self, "_on_Level_gameOver")
	add_child(level)

func endLevel():
	remove_child(level)
	level = null

func _input(event):
	if event.is_action_pressed('ui_select'):
		if level:
			endLevel()
		startLevel()
	if event.is_action_pressed('ui_cancel'):
		if level:
			endLevel()
		else:
			get_tree().quit()

func _on_Level_gameOver():
	print("gameover")
	endLevel()
