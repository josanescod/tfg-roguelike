extends Node

@onready var room_scene : PackedScene = load("res://Nodes/room.tscn")
@onready var door_scene : PackedScene = load("res://Nodes/door.tscn")
@onready var key_scene : PackedScene = load("res://Nodes/key.tscn")
#@onready var enemy_scene : PackedScene = load("res://Nodes/enemy.tscn")

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


# Procedural generation algorithms
enum GenerationAlgorithm {
	RANDOM_WALK,
	BSP,     # Binary Space Partitioning 
	CELLULAR_AUTOMATA # Celular Automata         
}

func _ready():
	initialize_map()
	generate(GenerationAlgorithm.RANDOM_WALK)
	test_generate_rooms()

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

func initialize_map():
	ship_map.clear()
	for i in range(ship_width):
		ship_map.append([])
		for j in range (ship_heigth):
			ship_map[i].append(false)
			
func generate(algorithm: int) -> void:	
	match algorithm:
		GenerationAlgorithm.RANDOM_WALK:
			algorithm_execution_time = measure_time(generate_random_walk)
		GenerationAlgorithm.BSP:
			algorithm_execution_time = measure_time(generate_bsp)
		GenerationAlgorithm.CELLULAR_AUTOMATA:
			algorithm_execution_time = measure_time(generate_cellular)			
				
	instantiate_rooms()
	player_position = Vector2(init_x, init_y)
	$"../Player".global_position = (initial_room_position * 816) + Vector2(262, 262)
	get_tree().create_timer(1)
	instantiate_key_and_exit_door()


# Ramdom Walk 
func generate_random_walk() -> void:
	var current_x = int(ship_width / 2.0)
	var current_y = int(ship_heigth / 2.0)
	current_x = init_x
	current_y = init_y
	var rooms_created = 0
	var first_room_created = false
	
	while rooms_created < rooms_to_build:
		if not ship_map[current_x][current_y]:
			ship_map[current_x][current_y] = true
			rooms_created += 1
			# Set initial_room_position to the first room created
			if not first_room_created:
				initial_room_position = Vector2(current_x, current_y)
				first_room_created = true
		# Random movement
		var direction = randi() % 4
		match direction:
			0: current_x = clamp(current_x + 1, 0, ship_width - 1)
			1: current_x = clamp(current_x - 1, 0, ship_width - 1)
			2: current_y = clamp(current_y + 1, 0, ship_heigth - 1)
			3: current_y = clamp(current_y - 1, 0, ship_heigth - 1)

# BSP 
# https://abitawake.com/news/articles/procedural-generation-with-godot-create-dungeons-using-a-bsp-tree
func generate_bsp() -> void:
	pass

# CELLULAR AUTOMATA
func generate_cellular() -> void:
	pass


func measure_time(func_algorithm : Callable) -> float:
	var start_time = Time.get_ticks_usec() #https://forum.godotengine.org/t/is-there-anyway-you-can-get-the-elasped-time/14091/3
	func_algorithm.call()
	var end_time = Time.get_ticks_usec()	
	algorithm_execution_time = (end_time - start_time) / 1000.0 # microseconds to miliseconds	
	return algorithm_execution_time
	
func test_generate_rooms() -> void:	
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
	preview += "⬛ = Wall\n"
	# Stats
	preview += "+" + "-" .repeat(ship_width * 3) + "+\n"
	preview += "Player position: " + str(init_x) + " " + str(init_y) + "\n"
	preview += "Total rooms: " + str(rooms_to_build) + "\n"
	preview += "Density map: " + str("%0.2f" % density) + " %\n"
	preview += "Execution time: " + str(algorithm_execution_time) + " ms\n"
	
	print(preview)
	print("INITIAL TIME: " + str(Global.best_time))

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
		print("Key Room:", key_room, "Exit Door Room:", exit_door_room)
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
