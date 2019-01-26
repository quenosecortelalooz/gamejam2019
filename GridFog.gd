extends Node

var shown = {}
var max_time = 100
var tilemap = null

func _init(tiles, size):
	print(tiles, size)
	tilemap = tiles

func _ready():
	set_process(true)

func refreshTiles(center, radius):
	if tilemap != null:
		for x in range(-radius, radius):
			for y in range(-radius, radius):
				if (x * x + y * y <= radius * radius):
					var X = int(round(center.x / 32 + x))
					var Y = int(round(center.y / 32 + y))
					shown[str(X) + "," + str(Y)] = max_time
					tilemap.set_cell(X, Y, -1)

func _process(delta):
	if tilemap:
		for k in shown.keys():
			shown[k] -= 1
			if shown[k] == 0:
				shown.erase(k)
				tilemap.set_cell(int(k.split(",")[0]), int(k.split(",")[1]), 0)
