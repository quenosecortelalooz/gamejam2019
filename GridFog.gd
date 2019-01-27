extends Node

var shown = {}
var max_illumination = 45
var tilemap = null
var timer = null

func _init(tiles, size):
	tilemap = tiles

	tiles.clear()
	var topleft = tiles.world_to_map(size.position)
	var bottomright = tiles.world_to_map(size.end)
	for x in range(topleft.x, bottomright.x):
		for y in range(topleft.y, bottomright.y):
			tiles.set_cell(x, y, 0)

	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", self, "periodic")
	timer.set_wait_time(0.2)
	timer.start()
	
	set_physics_process(true)

func sum(arr):
	var s = 0
	for v in arr:
		s += v
	return s

func periodic():
	for k in shown.keys():
		for i in range(len(shown[k])):
			shown[k][i] -= 1
			if shown[k][i] < 0:
				shown[k][i] = 0
		if shown[k][0] + shown[k][1] == 0:
			shown.erase(k)

func _physics_process(delta):
	for k in shown.keys():
		var total_illumination = sum(shown[k])
		tilemap.set_cell(int(k.split(",")[0]), int(k.split(",")[1]), int(round((float(total_illumination)/max_illumination)*10)) )	

func _ready():
	pass

func illuminateTiles(center, radius, torch_index):
	# index: 0 = player torch
	# index: 1 = terrain torch
	if tilemap != null && radius > 0:
		for x in range(-radius, radius + 1):
			for y in range(-radius, radius + 1):
				var d2 = x * x + y * y
				var r2 = radius * radius
				if (d2 <= r2):
					var X = int(round(center.x / 32 + x))
					var Y = int(round(center.y / 32 + y))
					var i = str(X) + "," + str(Y)
					if ! (i in shown):
						shown[i] = [0, 0]
					shown[i][torch_index] = max_illumination - (d2/r2)*15
					var total_illumination = sum(shown[i])
					# tilemap.set_cell(X, Y, int(round((float(total_illumination)/max_illumination)*10)))
