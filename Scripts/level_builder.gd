extends Node

@onready var room_scene : PackedScene = load("res://Nodes/room.tscn")
@onready var door_scene : PackedScene = load("res://Nodes/door.tscn")
@onready var key_scene : PackedScene = load("res://Nodes/key.tscn")
@onready var algorithm_manager = $"../AlgorithmManager"

var ship_width : int = 7
var ship_heigth : int = 7
var rooms_to_build : int = randi_range(3,5) # 6,12
var room_counter: int = 0
var initial_room_position : Vector2
var rooms_instantiated : bool = false
# random start position player
var init_x : int = randi_range(0,6)
var init_y : int = randi_range(0,6)
# time taken by algorithms
var algorithm_execution_time : float = 0
var ship_map : Array
var room_nodes: Array
var player_position: Vector2

# probability of each object being spawned
@export var enemy_spawn_probability : float
@export var coin_spawn_probability: float
@export var heart_spawn_probability : float
# number of objects per room
@export var max_enemies_per_room: int
@export var max_coins_per_room: int
@export var max_hearts_per_room: int

func _ready():
	generate_map()

func generate_map() -> void:
	algorithm_manager.setup(ship_width, ship_heigth, rooms_to_build)
	algorithm_manager.set_algorithm("random_walk")  # o "bsp" o "cellular"
	var result = algorithm_manager.generate(Vector2(init_x, init_y))
	process_generation_result(result)

func process_generation_result(result: Dictionary) -> void:
	ship_map = result.ship_map
	initial_room_position = result.initial_room_position
	algorithm_execution_time = result.execution_time
	# continue level construction
	instantiate_rooms()
	player_position = Vector2(init_x, init_y)
	$"../Player".global_position = (initial_room_position * 816) + Vector2(262, 262)
	instantiate_key_and_exit_door()
	print_test_generation()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		print("pressing ESC")
		if Global.game_paused == false:
			print("Showing Pause Menu")
			Sfx.get_child(5).stop()
			$"../UI/PauseMenu".visible = true
			$"../UI/TimeBar/Timer".paused = true
			Global.game_paused = true
		else:
			print("Hiding Pause Menu")
			Sfx.get_child(5).play()
			$"../UI/PauseMenu".visible = false
			$"../UI/TimeBar/Timer".paused = false
			Global.game_paused = false

func instantiate_rooms() -> void:
	if rooms_instantiated:
		return
	rooms_instantiated = true	
	for x in range(ship_width):
		for y in range (ship_heigth):
			if ship_map[x][y] == false:
				continue			
			var room = room_scene.instantiate()
			room.position = Vector2(x, y) * 816 # 48 tile size * 17 (total number of tiles)			
			if y > 0 and ship_map[x][y - 1] == true:
				room.north()
			if y < ship_heigth - 1 and ship_map[x][y + 1] == true:
				room.south()
			if x > 0 and ship_map[x - 1][y] == true:
				room.west()
			if x < ship_width - 1 and ship_map[x + 1][y] == true:
				room.east()
				
			if initial_room_position != Vector2(x, y):
				room.LevelBuilder = self
			else:
				room.show_instructions_on_the_floor()
			$"..".call_deferred("add_child", room)
			room_nodes.append(room)

func instantiate_key_and_exit_door() -> void:
	var available_rooms = []
	for x in range (ship_width):
		for y in range (ship_heigth):
			if ship_map[x][y]:
				var room_position = Vector2(x,y)
				# Exclude Player's room and key's room
				if room_position != player_position:
					available_rooms.append(room_position)
	if available_rooms.size() > 1:
		# maximum distance between rooms
		var max_distance = -1
		var key_room = null
		var exit_door_room = null
		for i in range(available_rooms.size()):
			for j in range(i + 1, available_rooms.size()):
				var distance = available_rooms[i].distance_to(available_rooms[j])
				if distance > max_distance:
					key_room = available_rooms[i]
					exit_door_room = available_rooms[j]
		print("key_room:", key_room, " - door_room:", exit_door_room)
		# key
		if key_room:
			var key = key_scene.instantiate()
			var key_x = randi_range(100,400)
			var key_y = randi_range(100,400)
			key.global_position = key_room * 816 + Vector2(key_x, key_y)
			$"..".call_deferred("add_child", key)
		# exit_door
		if exit_door_room:
			var exit_door = door_scene.instantiate()
			var exit_door_x = randi_range(100,400)
			var exit_door_y = randi_range(100,400)
			exit_door.global_position = exit_door_room * 816 + Vector2(exit_door_x, exit_door_y)
			$"..".call_deferred("add_child", exit_door)

func print_test_generation() -> void:
	var density = float(rooms_to_build) / float(ship_width * ship_heigth) * 100
	var preview = "\nGenerated map (" + str(ship_width) + "x" + str(ship_heigth) + "):\n"
	preview += "+" + "-" .repeat(ship_width * 3) + "+\n"
	for j in range(ship_heigth):  #  Traverse array from left to right by columns from top to bottom
		preview += "|"
		for i in range(ship_width):
			if (i == initial_room_position.x and j == initial_room_position.y):
				preview += "🟨" # player
			else:
				preview += "⬜" if ship_map[i][j] else "⬛"  # ⬜ room ⬛ wall
		preview += "|\n"
	preview += "+" + "-" .repeat(ship_width * 3) + "+\n"
	# Legend
	preview += "🟨 = Player\n"
	preview += "⬜ = Room\n"
	preview += "⬛ = Empty\n"
	# Stats
	preview += "+" + "-" .repeat(ship_width * 3) + "+\n"
	preview += "Player position: " + str(init_x) + " " + str(init_y) + "\n"
	preview += "Total rooms: " + str(rooms_to_build) + "\n"
	preview += "Density map: " + str("%0.2f" % density) + " %\n"
	preview += "Execution time: " + str(algorithm_execution_time) + " ms\n"
	print(preview)
	print("best initial time: ", Global.best_time)
