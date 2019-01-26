extends Node

var shown = {}
var max_time = 300
var tilemap = null

func _init(tiles, size):
	print(tiles, size)
	tilemap = tiles

func _ready():
	set_process(true)
	set_physics_process(true)

func refreshTiles(center, radius):
	if tilemap != null:
		for x in range(-radius, radius + 1):
			for y in range(-radius, radius + 1):
				if (x * x + y * y <= radius * radius):
					var X = int(round(center.x / 32 + x))
					var Y = int(round(center.y / 32 + y))
					shown[str(X) + "," + str(Y)] = max_time
					tilemap.set_cell(X, Y, 10)

func _physics_process(delta):
	if tilemap:
		for k in shown.keys():
			shown[k] -= 1
			if shown[k] < 0:
				shown[k] = 0
			tilemap.set_cell(int(k.split(",")[0]), int(k.split(",")[1]), int(round((float(shown[k])/max_time)*10)))
			if shown[k] == 0:
				shown.erase(k)
