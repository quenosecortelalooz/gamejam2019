extends Node2D

var fog = []
var n = 0

func _ready():
	var image = load("res://Fog.tscn")
	for x in range(64):
		fog.append([])
		for y in range(64):
			var fog_cell = image.instance()
			fog[x].append(fog_cell)
			add_child(fog_cell)
			fog[x][y].set_frame(n)
			fog[x][y].position = Vector2(y*16, x*16)
			n += 1
	set_process(true)

# func _process(delta):
# 	var area_x = max(get_node("../Player").position.x/16-2,0)
# 	var area_y = max(get_node("../Player").position.y/16-2,0)
# 	var area_w = min(area_x + 5, 64)
# 	var area_h = min(area_y + 5, 64)
# 	for x in range(area_x, area_w, 1):
# 		for y in range(area_y, area_h, 1):
# 			if fog[y][x].is_visible() == true:
# 				fog[y][x].set_hidden(true)
