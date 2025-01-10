extends Node

@onready var room_scene : PackedScene = load("res://Nodes/room.tscn")
@onready var door_scene : PackedScene = load("res://Nodes/door.tscn")
@onready var key_scene : PackedScene = load("res://Nodes/key.tscn")
@onready var algorithm_manager = $"../AlgorithmManager"

var starship_width : int = 7
var starship_heigth : int = 7
var TILE_SIZE = 48
var ROOM_SIZE = TILE_SIZE * 17
var rooms_to_build : int = randi_range(12,15 ) # 6,12
var room_counter: int = 0
var initial_room_position : Vector2
var rooms_instantiated : bool = false
var init_x : int = randi_range(0,6)
var init_y : int = randi_range(0,6)
var algorithm_execution_time : float = 0
var starship_map : Array
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

var testResults = []

func _ready():
	#create_csv_file()
	#run_test_algo()
	generate_map()

func generate_map() -> void:
	algorithm_manager.setup(starship_width, starship_heigth, rooms_to_build)
	algorithm_manager.set_algorithm(Global.algorithm)  # "random_walk" o "agent_based" o "cellular"
	var result = algorithm_manager.generate(Vector2(init_x, init_y))
	process_generation_result(result)

func process_generation_result(result: Dictionary) -> void:
	starship_map = result.starship_map
	initial_room_position = result.initial_room_position
	algorithm_execution_time = result.execution_time
	instantiate_rooms()
	player_position = Vector2(init_x, init_y)
	$"../Player".global_position = (initial_room_position * ROOM_SIZE) + Vector2(262, 262)
	instantiate_key_and_exit_door()
	print_test_generation()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		print("pressing ESC")
		if Global.game_paused == false:
			print("Showing Pause Menu")
			Sfx.get_child(1).stop()
			$"../UI/PauseMenu".visible = true
			$"../UI/TimeBar/Timer".paused = true
			Global.game_paused = true
		else:
			print("Hiding Pause Menu")
			Sfx.get_child(1).play()
			$"../UI/PauseMenu".visible = false
			$"../UI/TimeBar/Timer".paused = false
			Global.game_paused = false

func instantiate_rooms() -> void:
	if rooms_instantiated:
		return
	rooms_instantiated = true	
	for x in range(starship_width):
		for y in range (starship_heigth):
			if starship_map[x][y] == false:
				continue
			var room = room_scene.instantiate()
			room.position = Vector2(x, y) * ROOM_SIZE # 48 tile size * 17 (total number of tiles)
			if y > 0 and starship_map[x][y - 1] == true:
				room.north()
			if y < starship_heigth - 1 and starship_map[x][y + 1] == true:
				room.south()
			if x > 0 and starship_map[x - 1][y] == true:
				room.west()
			if x < starship_width - 1 and starship_map[x + 1][y] == true:
				room.east()

			if initial_room_position != Vector2(x, y):
				room.LevelBuilder = self
			else:
				room.show_instructions_on_the_floor()
			$"..".call_deferred("add_child", room)
			room_nodes.append(room)

func instantiate_key_and_exit_door() -> void:
	var available_rooms = []
	for x in range (starship_width):
		for y in range (starship_heigth):
			if starship_map[x][y]:
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
		print("key_room:", key_room, " - exit_door:", exit_door_room)
		# key
		if key_room:
			var key = key_scene.instantiate()
			var key_x = TILE_SIZE * randi_range(2, 8) - 24
			var key_y = TILE_SIZE * randi_range(2, 8) - 24
			key.global_position = key_room * ROOM_SIZE + Vector2(key_x, key_y)
			$"..".call_deferred("add_child", key)
		# exit_door
		if exit_door_room:
			var exit_door = door_scene.instantiate()
			var exit_door_x = TILE_SIZE * randi_range(2, 8) - 24
			var exit_door_y = TILE_SIZE * randi_range(2, 8) - 24
			exit_door.global_position = exit_door_room * ROOM_SIZE + Vector2(exit_door_x, exit_door_y)
			$"../Player".exit_door_room_position = exit_door.global_position
			$"..".call_deferred("add_child", exit_door)

# Auxiliary functions for testing and analyzing algorithms

func print_test_generation() -> void:
	var density = float(rooms_to_build) / float(starship_width * starship_heigth) * 100
	var preview = "\nGenerated map (" + str(starship_width) + "x" + str(starship_heigth) + "):\n"
	preview += "+" + "-" .repeat(starship_width * 3) + "+\n"
	for j in range(starship_heigth):  #  Traverse array from left to right by columns from top to bottom
		preview += "|"
		for i in range(starship_width):
			if (i == initial_room_position.x and j == initial_room_position.y):
				preview += "🟨" # player
			else:
				preview += "⬜" if starship_map[i][j] else "⬛"  # ⬜ room ⬛ wall
		preview += "|\n"
	preview += "+" + "-" .repeat(starship_width * 3) + "+\n"
	# Legend
	preview += "🟨 = Player\n"
	preview += "⬜ = Room\n"
	preview += "⬛ = Empty\n"
	# Stats
	preview += "+" + "-" .repeat(starship_width * 3) + "+\n"
	preview += "Player position: " + str(init_x) + " " + str(init_y) + "\n"
	preview += "Total rooms: " + str(rooms_to_build) + "\n"
	preview += "Density map: " + str("%0.2f" % density) + " %\n"
	preview += "Execution time: " + str(algorithm_execution_time) + " ms\n"
	preview += "Procedural algorithm: " + Global.algorithm + "\n"
	print(preview)
	print("best initial time: ", Global.best_time)

func create_csv_file() -> void:
	var file = FileAccess.open("user://test_results.csv", FileAccess.WRITE)
	if file:
		file.store_string("Algorithm,Rooms,Density,Execution Time\n")
		file.close()
		# Get and print the absolute path
		var path = OS.get_user_data_dir()
		var full_path = path.path_join("test_results.csv")
		print("CSV file saved in path: ", full_path)
	else:
		print("Error: Could not create CSV file.")

func save_results_to_csv(algorithm: String, n_rooms: int, density: float, execution_time: float) -> void:
	var file = FileAccess.open("user://test_results.csv", FileAccess.READ_WRITE)
	if file:
		file.seek_end()  # Move to the end of the file
		var line = "%s,%d,%.2f,%.2f\n" % [algorithm, n_rooms, density, execution_time]
		file.store_string(line)
		file.close()
	else:
		print("Error: Could not open file for writing.")

func run_test_algo() -> void:
	var max_R = 41
	# Test each algorithm with different room counts
	var algorithms = ["random_walk", "cellular", "agent_based"]
	for algorithm in algorithms:
		for r in range(1, max_R):
			rooms_to_build = r
			test_algorithm(algorithm, r)

func test_algorithm(algorithm:String, n_rooms:int) -> void:
	rooms_to_build = n_rooms
	Global.algorithm = algorithm
	algorithm_manager.setup(starship_width, starship_heigth, rooms_to_build)
	algorithm_manager.set_algorithm(Global.algorithm)  # "random_walk" or "cellular" or "agent_based"
	var result = algorithm_manager.generate(Vector2(init_x, init_y))
	starship_map = result.starship_map
	initial_room_position = result.initial_room_position
	algorithm_execution_time = result.execution_time
	player_position = Vector2(init_x, init_y)
	var density = float(rooms_to_build) / float(starship_width * starship_heigth) * 100
	save_results_to_csv(algorithm, n_rooms, density, algorithm_execution_time)
	print_test_generation()
