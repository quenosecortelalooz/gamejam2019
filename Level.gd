extends Node2D
signal gameOver
signal lanternPowerChanged

var Room = preload("res://Room.tscn")
var Wolf = preload("res://Wolf.tscn")
var font = preload("res://assets/RobotoBold120.tres")
onready var Map = $TileMap
onready var Fog = $TileFog
onready var initialText = $CanvasLayer/InitialText

var tile_size = 32  # size of a tile in the TileMap
var num_rooms = 50  # number of rooms to generate
var min_size = 6  # minimum room size (in tiles)
var max_size = 10  # maximum room size (in tiles)
var hspread = 0  # horizontal spread (in pixels)
var cull = 0  # chance to cull room

var path  # AStar pathfinding object
var start_room = null
var end_room = null
var play_mode = false
var player = null
var full_rect = Rect2()

export var lantern_power = 4
export var lantern_power_max = 6
var light_decay = 0.01
var wolf_prob = 1
var initial_label = ""
var traceFog = []
var chargers = []

var gridFog = null

func init(num_rooms_param, light_decay_param, wolf_prob_param, initial_label_param):
	num_rooms = num_rooms_param
	light_decay = light_decay_param
	wolf_prob = wolf_prob_param
	initial_label = initial_label_param

func removeInitialText():
	initialText.hide()

func _ready():

	initialText.text = initial_label
	initialText.show()
	var timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", self, "removeInitialText")
	timer.set_wait_time(2)
	timer.start()

	randomize()
	make_rooms()

	yield(get_tree().create_timer(1.5), "timeout")

	make_map()
	gridFog = load("GridFog.gd").new(Fog, full_rect)
	add_child(gridFog)

	player = $Character
	player.set_meta("name", "Player")
	player.position = start_room.position
	play_mode = true
	set_physics_process(true)
	spawn_wolves()


func spawn_wolves():
	for room in $Rooms.get_children():
		if room != start_room and room != end_room and randf() < wolf_prob:
			var wolf = Wolf.instance()
			wolf.set_meta("name", "Wolf")
			wolf.position = room.position
			add_child(wolf)


func make_rooms():
	for i in range(num_rooms):
		var pos = Vector2(rand_range(-hspread, hspread), 0)
		var r = Room.instance()
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.make_room(pos, Vector2(w, h) * tile_size)
		$Rooms.add_child(r)
	# wait for movement to stop
	yield(get_tree().create_timer(1.1), 'timeout')
	# cull rooms
	var room_positions = []
	for room in $Rooms.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room.mode = RigidBody2D.MODE_STATIC
			room_positions.append(Vector3(room.position.x,
										  room.position.y, 0))
	yield(get_tree(), 'idle_frame')
	# generate a minimum spanning tree connecting the rooms
	path = find_mst(room_positions)

func _physics_process(delta):
	if player && gridFog:
		var near_charger = false
		for c in chargers:
			if player.position.distance_to(c) < 80:
				near_charger = true
				break
		if near_charger:
			if lantern_power <= 0:
				lantern_power = 0.4 * lantern_power_max
			if lantern_power < lantern_power_max:
				lantern_power = lantern_power * 1.04
				emit_signal("lanternPowerChanged", lantern_power)
		else:
			lantern_power = lantern_power - light_decay
			if lantern_power < 0:
				lantern_power = 0
				emit_signal("gameOver")
			emit_signal("lanternPowerChanged", lantern_power)

	if player && gridFog:	
		gridFog.illuminateTiles(player.position, lantern_power, 0)
		for c in chargers:
			gridFog.illuminateTiles(c, 2, 1)

func _input(event):
	if event.is_action_pressed('ui_select'):
		if play_mode:
			player.queue_free()
			play_mode = false
		for n in $Rooms.get_children():
			n.queue_free()
		path = null
		start_room = null
		end_room = null
		make_rooms()
	if event.is_action_pressed('ui_focus_next'):
		make_map()
	if event.is_action_pressed('ui_cancel'):
		pass

func find_mst(nodes):
	# Prim's algorithm
	# Given an array of positions (nodes), generates a minimum
	# spanning tree
	# Returns an AStar object

	# Initialize the AStar and add the first point
	var path = AStar.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())

	# Repeat until no more nodes remain
	while nodes:
		var min_dist = INF  # Minimum distance so far
		var min_p = null  # Position of that node
		var p = null  # Current position
		# Loop through points in path
		for p1 in path.get_points():
			p1 = path.get_point_position(p1)
			# Loop through the remaining nodes
			for p2 in nodes:
				# If the node is closer, make it the closest
				if p1.distance_to(p2) < min_dist:
					min_dist = p1.distance_to(p2)
					min_p = p2
					p = p1
		# Insert the resulting node into the path and add
		# its connection
		var n = path.get_available_point_id()
		path.add_point(n, min_p)
		path.connect_points(path.get_closest_point(p), n)
		# Remove the node from the array so it isn't visited again
		nodes.erase(min_p)

	# add random connections to have more paths (some cycles) between rooms
	var points = path.get_points()
	for i in range(3):
		path.connect_points(randi() % len(points), randi() % len(points))
	return path

func make_map():
	# Create a TileMap from the generated rooms and path
	Map.clear()
	find_start_room()
	find_end_room()

	# Fill TileMap with walls, then carve empty rooms
	for room in $Rooms.get_children():
		var r = Rect2(room.position-room.size,
					room.get_node("CollisionShape2D").shape.extents*2)
		full_rect = full_rect.merge(r)
	var topleft = Map.world_to_map(full_rect.position)
	var bottomright = Map.world_to_map(full_rect.end)
	for x in range(topleft.x, bottomright.x):
		for y in range(topleft.y, bottomright.y):
			Map.set_cell(x, y, 1)

	# Carve rooms
	var corridors = []  # One corridor per connection
	for room in $Rooms.get_children():
		var s = (room.size / tile_size).floor()
		var pos = Map.world_to_map(room.position)
		var ul = (room.position / tile_size).floor() - s
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				Map.set_cell(ul.x + x, ul.y + y, 0)
		# Carve connecting corridor
		var p = path.get_closest_point(Vector3(room.position.x, 
											room.position.y, 0))
		for conn in path.get_point_connections(p):
			if not conn in corridors:
				var start = Map.world_to_map(Vector2(path.get_point_position(p).x,
													path.get_point_position(p).y))
				var end = Map.world_to_map(Vector2(path.get_point_position(conn).x,
													path.get_point_position(conn).y))
				carve_path(start, end)
		corridors.append(p)

func carve_path(pos1, pos2):
	# Carve a path between two points
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0: x_diff = pow(-1.0, randi() % 2)
	if y_diff == 0: y_diff = pow(-1.0, randi() % 2)
	# choose either x/y or y/x
	var x_y = pos1
	var y_x = pos2
	var poss = [[pos1, pos2], [pos2, pos1]]
	for i in range(2):
		x_y = poss[i][0]
		y_x = poss[i][1]
		for x in range(pos1.x, pos2.x, x_diff):
			Map.set_cell(x, x_y.y, 0)
			Map.set_cell(x, x_y.y + y_diff*4, 0)
			Map.set_cell(x, x_y.y + y_diff*3, 0)
			Map.set_cell(x, x_y.y + y_diff*2, 0)
			Map.set_cell(x, x_y.y + y_diff, 0)
			Map.set_cell(x, x_y.y - y_diff, 0)
			Map.set_cell(x, x_y.y - y_diff*2, 0)
			Map.set_cell(x, x_y.y - y_diff*3, 0)
			Map.set_cell(x, x_y.y - y_diff*4, 0)
		for y in range(pos1.y, pos2.y, y_diff):
			Map.set_cell(y_x.x, y, 0)
			Map.set_cell(y_x.x + x_diff*4, y, 0)
			Map.set_cell(y_x.x + x_diff*3, y, 0)
			Map.set_cell(y_x.x + x_diff*2, y, 0)
			Map.set_cell(y_x.x + x_diff, y, 0)
			Map.set_cell(y_x.x - x_diff, y, 0)
			Map.set_cell(y_x.x - x_diff*2, y, 0)
			Map.set_cell(y_x.x - x_diff*3, y, 0)
			Map.set_cell(y_x.x - x_diff*4, y, 0)

func find_start_room():
	var min_x = INF
	for room in $Rooms.get_children():
		chargers.append(room.position)
		if room.position.x < min_x:
			start_room = room
			min_x = room.position.x
	# chargers.append(start_room.position)

func find_end_room():
	var max_x = -INF
	for room in $Rooms.get_children():
		if room.position.x > max_x:
			end_room = room
			max_x = room.position.x
	# chargers.append(end_room.position)
