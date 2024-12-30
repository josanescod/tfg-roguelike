extends Node

class MapData:
	var ship_map: Array
	var initial_room_position: Vector2
	var width: int
	var height: int
	var rooms_count: int
	
	func _init(w: int, h: int) -> void:
		width = w
		height = h
		initialize_map()
		
	func initialize_map() -> void:
		ship_map = []
		for i in range(width):
			ship_map.append([])
			for j in range (height):
				ship_map[i].append(false)
		
class RandomWalkGenerator:
	static func generate(map_data: MapData, start_pos: Vector2) -> void:
		var current_x = int(start_pos.x)
		var current_y = int(start_pos.y)
		var rooms_created = 0
		var first_room_created = false
		
		while rooms_created < map_data.rooms_count:
			if not map_data.ship_map[current_x][current_y]:
				map_data.ship_map[current_x][current_y] = true
				rooms_created += 1
				if not first_room_created:
					map_data.initial_room_position = Vector2(current_x, current_y)
					first_room_created = true
			
			var direction = randi() % 4
			match direction:
				0: current_x = clamp(current_x + 1, 0, map_data.width - 1)
				1: current_x = clamp(current_x - 1, 0, map_data.width - 1)
				2: current_y = clamp(current_y + 1, 0, map_data.height - 1)
				3: current_y = clamp(current_y - 1, 0, map_data.height - 1)

class BSPGenerator:
	static func generate(_map_data: MapData, _start_pos: Vector2) -> void:
		# Implementación del algoritmo BSP
		pass

class CellularAutomataGenerator:
	static func generate(_map_data: MapData, _start_pos: Vector2) -> void:
		# Implementación del algoritmo Cellular Automata
		pass

var current_algorithm: String = "random_walk"
var map_data: MapData

func measure_time(func_algorithm: Callable) -> float:
	var start_time = Time.get_ticks_usec()
	func_algorithm.call()
	var end_time = Time.get_ticks_usec()
	return (end_time - start_time) / 1000.0

func setup(width: int, height: int, rooms_count: int) -> void:
	map_data = MapData.new(width, height)
	map_data.rooms_count = rooms_count

func execute_generation(start_position: Vector2) -> void:
	match current_algorithm:
		"random_walk":
			RandomWalkGenerator.generate(map_data, start_position)
		"bsp":
			BSPGenerator.generate(map_data, start_position)
		"cellular":
			CellularAutomataGenerator.generate(map_data, start_position)

func generate(start_position: Vector2) -> Dictionary:
	var execution_time = measure_time(func() -> void:
		execute_generation(start_position)
	)
	var result = {
		"ship_map": map_data.ship_map,
		"initial_room_position": map_data.initial_room_position,
		"execution_time": execution_time
	}
	return result

func set_algorithm(algorithm: String) -> void:
	current_algorithm = algorithm
