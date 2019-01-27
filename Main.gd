extends Node2D

var Level = load("res://Level.tscn")
var level = null
var level_num = 1

func _ready():
	$Label.text = 'APRETA ESPACIO PARA JUGAR'
	$Label.visible = true


func startLevel():
	level = Level.instance()
	# number of rooms, light_decay, wolf probability, Initial text
	if level_num == 1:
		level.init(2, 0.0001, 0, "NIVEL 1\nQuien apago la LOOZ??\nTengo que volver a casa!", 0)
	if level_num == 2:
		level.init(3, 0.04, 0, "NIVEL 2\nSe me apaga la antorcha!\npero puedo recargarla acercandome a otra", 0)
	if level_num == 3:
		level.init(5, 0.02, 1, "NIVEL 3\nFUCK!\nLOBOS!", 0)
	if level_num == 4:
		level.init(9, 0.04, 0.8, "NIVEL 3\nSHIT!\nSe hace mas dificil!", 0.2)
	if level_num == 5:
		level.init(15, 0.04, 2, "NIVEL 4\nOMG!\nFucking lobos!", 0.4)
	if level_num == 5:
		level.init(15, 0.04, 5, "NIVEL 5\n.....", 0.4)
	level.connect("gameOver", self, "_on_Level_gameOver")
	level.connect("gameWin", self, "_on_Level_gameWin")
	add_child(level)

func endLevel():
	remove_child(level)
	level = null

func _input(event):
	if event.is_action_pressed('ui_select'):
		$Label.visible = false
		$TextureRect.visible = false
		if !level:
			startLevel()
		else:
			endLevel()
			yield(get_tree().create_timer(1), 'timeout')
			startLevel()
	if event.is_action_pressed('ui_cancel'):
		if level:
			$Label.text = 'APRETA ESPACIO PARA JUGAR'
			$Label.visible = true
			$TextureRect.visible = true
			endLevel()
		else:
			get_tree().quit()

func _on_Level_gameOver():
	$EndTimer.start()


func _on_EndTimer_timeout():
	endLevel()
	yield(get_tree().create_timer(1), 'timeout')
	startLevel()

func _on_Level_gameWin():
	level_num += 1
	endLevel()
	yield(get_tree().create_timer(1), 'timeout')
	startLevel()
