extends Node

class MapData:
	var starship_map: Array
	var initial_room_position: Vector2
	var width: int
	var height: int
	var rooms_count: int
	var rooms: Array
	
	func _init(w: int, h: int) -> void:
		width = w
		height = h
		initialize_map()
		
	func initialize_map() -> void:
		starship_map = []
		for i in range(width):
			starship_map.append([])
			for j in range (height):
				starship_map[i].append(false)
		
class RandomWalkGenerator:
	static func generate(map_data: MapData, start_pos: Vector2) -> void:
		print("Executing random_walk")
		var current_x = int(start_pos.x)
		var current_y = int(start_pos.y)
		var rooms_created = 0
		var first_room_created = false
		
		while rooms_created < map_data.rooms_count:
			if not map_data.starship_map[current_x][current_y]:
				map_data.starship_map[current_x][current_y] = true
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


class AgentBasedGenerator:
	const DIRECTIONS = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
	static func generate(map_data: MapData, start_pos: Vector2) -> void:
		print("Executing agent_based")
		var rooms_created = 0
		var current_pos = Vector2(start_pos)
		# Place initial room
		map_data.starship_map[int(current_pos.x)][int(current_pos.y)] = true
		map_data.initial_room_position = current_pos
		rooms_created += 1
		while rooms_created < map_data.rooms_count:
			if try_place_adjacent_room(map_data, current_pos):
				rooms_created += 1
				current_pos = find_last_placed_room(map_data)
			else:
				var new_pos = find_new_position(map_data)
				if new_pos == Vector2(-1, -1):
					break
				current_pos = new_pos
		ensure_connectivity(map_data)

	static func try_place_adjacent_room(map_data: MapData, pos: Vector2) -> bool:
		var directions = DIRECTIONS.duplicate()
		directions.shuffle()
		for dir in directions:
			var new_pos = Vector2(
				int(pos.x + dir.x),
				int(pos.y + dir.y)
			)

			if is_valid_room_position(map_data, new_pos):
				map_data.starship_map[new_pos.x][new_pos.y] = true
				return true

		return false

	static func is_valid_room_position(map_data: MapData, pos: Vector2) -> bool:
		if not (pos.x >= 0 and pos.x < map_data.width and pos.y >= 0 and pos.y < map_data.height):
			return false

		if map_data.starship_map[pos.x][pos.y]:
			return false

		var adjacent_rooms = 0
		var diagonal_rooms = 0

		for x in range(-1, 2):
			for y in range(-1, 2):
				if x == 0 and y == 0:
					continue

				var check_pos = Vector2(pos.x + x, pos.y + y)
				if is_valid_position(map_data, check_pos) and map_data.starship_map[check_pos.x][check_pos.y]:
					if abs(x) == 1 and abs(y) == 1:
						diagonal_rooms += 1
					else:
						adjacent_rooms += 1

		return adjacent_rooms > 0 and adjacent_rooms < 4 and diagonal_rooms < 2

	static func is_valid_position(map_data: MapData, pos: Vector2) -> bool:
		return (pos.x >= 0 and pos.x < map_data.width and
				pos.y >= 0 and pos.y < map_data.height)

	static func find_new_position(map_data: MapData) -> Vector2:
		var room_positions = []
		for x in range(map_data.width):
			for y in range(map_data.height):
				if map_data.starship_map[x][y]:
					room_positions.append(Vector2(x, y))
		room_positions.shuffle()
		for pos in room_positions:
			for dir in DIRECTIONS:
				var new_pos = Vector2(int(pos.x + dir.x), int(pos.y + dir.y))
				if is_valid_room_position(map_data, new_pos):
					return pos
		return Vector2(-1, -1)

	static func find_last_placed_room(map_data: MapData) -> Vector2:
		for x in range(map_data.width - 1, -1, -1):
			for y in range(map_data.height - 1, -1, -1):
				if map_data.starship_map[x][y]:
					return Vector2(x, y)
		return Vector2(0, 0)

	static func ensure_connectivity(map_data: MapData) -> void:
		var regions = find_regions(map_data)
		if regions.size() <= 1:
			return
		var main_region = regions[0]
		for i in range(1, regions.size()):
			connect_regions(map_data, main_region, regions[i])

	static func find_regions(map_data: MapData) -> Array:
		var regions = []
		var visited = []
		for x in range(map_data.width):
			visited.append([])
			for y in range(map_data.height):
				visited[x].append(false)
		for x in range(map_data.width):
			for y in range(map_data.height):
				if map_data.starship_map[x][y] and not visited[x][y]:
					var new_region = flood_fill(map_data, visited, x, y)
					regions.append(new_region)
		return regions

	static func flood_fill(map_data: MapData, visited: Array, start_x: int, start_y: int) -> Array:
		var region = []
		var stack = [[start_x, start_y]]

		while not stack.is_empty():
			var current = stack.pop_back()
			var x = current[0]
			var y = current[1]

			if visited[x][y]:
				continue

			visited[x][y] = true
			region.append([x, y])
			for dir in DIRECTIONS:
				var nx = x + int(dir.x)
				var ny = y + int(dir.y)
				if is_valid_position(map_data, Vector2(nx, ny)):
					if map_data.starship_map[nx][ny] and not visited[nx][ny]:
						stack.append([nx, ny])
		return region

	static func connect_regions(map_data: MapData, region1: Array, region2: Array) -> void:
		var best_distance = INF
		var best_tile1 = null
		var best_tile2 = null
		for tile1 in region1:
			for tile2 in region2:
				var dist = abs(tile1[0] - tile2[0]) + abs(tile1[1] - tile2[1])
				if dist < best_distance:
					best_distance = dist
					best_tile1 = tile1
					best_tile2 = tile2
		create_connection(map_data, best_tile1, best_tile2)

	static func create_connection(map_data: MapData, start: Array, end: Array) -> void:
		var current_x = start[0]
		var current_y = start[1]

		while current_x != end[0] or current_y != end[1]:
			map_data.starship_map[current_x][current_y] = true

			if current_x < end[0]:
				current_x += 1
			elif current_x > end[0]:
				current_x -= 1
			elif current_y < end[1]:
				current_y += 1
			else:
				current_y -= 1

class CellularAutomataGenerator:
	const BIRTH_LIMIT = 4
	const DEATH_LIMIT = 4
	const ITERATIONS = 4
	static func generate(map_data: MapData, start_pos: Vector2) -> void:
		print("Executing cellular")
		var target_rooms = map_data.rooms_count
		var density = 0.45
		var max_attempts = 10
		var attempts = 0

		while attempts < max_attempts:
			for x in range(map_data.width):
				for y in range(map_data.height):
					map_data.starship_map[x][y] = false

			randomize_initial_state(map_data, density)
			for i in range(ITERATIONS):
				simulate_step(map_data)
			ensure_connectivity(map_data)
			var room_count = count_rooms(map_data)
			if room_count >= target_rooms:
				trim_excess_rooms(map_data, target_rooms)
				set_initial_room(map_data, start_pos)
				return
			density += 0.05
			attempts += 1
		fallback_generation(map_data, start_pos)
	static func simulate_step(map_data: MapData) -> void:
		var new_map = []
		for x in range(map_data.width):
			new_map.append([])
			for y in range(map_data.height):
				new_map[x].append(false)
		for x in range(map_data.width):
			for y in range(map_data.height):
				var neighbors = count_neighbors(map_data, x, y)
				if map_data.starship_map[x][y]:
					new_map[x][y] = neighbors >= DEATH_LIMIT
				else:
					new_map[x][y] = neighbors > BIRTH_LIMIT
		for x in range(map_data.width):
			for y in range(map_data.height):
				map_data.starship_map[x][y] = new_map[x][y]
	static func count_neighbors(map_data: MapData, x: int, y: int) -> int:
		var count = 0
		for i in range(-1, 2):
			for j in range(-1, 2):
				if i == 0 and j == 0:
					continue
				var nx = x + i
				var ny = y + j
				if nx >= 0 and nx < map_data.width and ny >= 0 and ny < map_data.height:
					if map_data.starship_map[nx][ny]:
						count += 1
		return count
	static func ensure_connectivity(map_data: MapData) -> void:
		var regions = find_regions(map_data)
		if regions.size() <= 1:
			return
		var main_region = regions[0]
		for i in range(1, regions.size()):
			connect_regions(map_data, main_region, regions[i])
	static func find_regions(map_data: MapData) -> Array:
		var regions = []
		var visited = []
		for x in range(map_data.width):
			visited.append([])
			for y in range(map_data.height):
				visited[x].append(false)
		for x in range(map_data.width):
			for y in range(map_data.height):
				if map_data.starship_map[x][y] and not visited[x][y]:
					var new_region = flood_fill(map_data, visited, x, y)
					regions.append(new_region)
		return regions
	static func flood_fill(map_data: MapData, visited: Array, start_x: int, start_y: int) -> Array:
		var region = []
		var stack = [[start_x, start_y]]
		while not stack.is_empty():
			var current = stack.pop_back()
			var x = current[0]
			var y = current[1]
			if visited[x][y]:
				continue
			visited[x][y] = true
			region.append([x, y])
			var directions = [[0, 1], [1, 0], [0, -1], [-1, 0]]
			for dir in directions:
				var nx = x + dir[0]
				var ny = y + dir[1]
				if nx >= 0 and nx < map_data.width and ny >= 0 and ny < map_data.height:
					if map_data.starship_map[nx][ny] and not visited[nx][ny]:
						stack.append([nx, ny])
		return region

	static func count_rooms(map_data: MapData) -> int:
		var count = 0
		for x in range(map_data.width):
			for y in range(map_data.height):
				if map_data.starship_map[x][y]:
					count += 1
		return count

	static func trim_excess_rooms(map_data: MapData, target_rooms: int) -> void:
		var current_rooms = count_rooms(map_data)
		while current_rooms > target_rooms:
			var x = randi() % map_data.width
			var y = randi() % map_data.height

			if map_data.starship_map[x][y]:
				if not would_disconnect(map_data, x, y):
					map_data.starship_map[x][y] = false
					current_rooms -= 1

	static func would_disconnect(map_data: MapData, x: int, y: int) -> bool:
		map_data.starship_map[x][y] = false
		var regions = find_regions(map_data)
		map_data.starship_map[x][y] = true
		return regions.size() > 1

	static func connect_regions(map_data: MapData, region1: Array, region2: Array) -> void:
		var best_distance = INF
		var best_tile1 = null
		var best_tile2 = null

		for tile1 in region1:
			for tile2 in region2:
				var dist = abs(tile1[0] - tile2[0]) + abs(tile1[1] - tile2[1])
				if dist < best_distance:
					best_distance = dist
					best_tile1 = tile1
					best_tile2 = tile2

		create_path(map_data, best_tile1, best_tile2)

	static func create_path(map_data: MapData, start: Array, end: Array) -> void:
		var current_x = start[0]
		var current_y = start[1]

		while current_x != end[0] or current_y != end[1]:
			map_data.starship_map[current_x][current_y] = true

			if current_x < end[0]:
				current_x += 1
			elif current_x > end[0]:
				current_x -= 1
			elif current_y < end[1]:
				current_y += 1
			else:
				current_y -= 1

	static func set_initial_room(map_data: MapData, _start_pos: Vector2) -> void:
		for x in range(map_data.width):
			for y in range(map_data.height):
				if map_data.starship_map[x][y]:
					map_data.initial_room_position = Vector2(x,y)
					return

	static func randomize_initial_state(map_data: MapData, density: float = 0.45) -> void:
		for x in range(map_data.width):
			for y in range(map_data.height):
				map_data.starship_map[x][y] = randf() < density

	static func fallback_generation(map_data: MapData, start_pos: Vector2) -> void:
		var current_x = int(start_pos.x)
		var current_y = int(start_pos.y)
		var rooms_created = 0

		while rooms_created < map_data.rooms_count:
			if not map_data.starship_map[current_x][current_y]:
				map_data.starship_map[current_x][current_y] = true
				rooms_created += 1

			var direction = randi() % 4
			match direction:
				0: current_x = clamp(current_x + 1, 0, map_data.width - 1)
				1: current_x = clamp(current_x - 1, 0, map_data.width - 1)
				2: current_y = clamp(current_y + 1, 0, map_data.height - 1)
				3: current_y = clamp(current_y - 1, 0, map_data.height - 1)


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
		"agent_based":
			AgentBasedGenerator.generate(map_data, start_position)
		"cellular":
			CellularAutomataGenerator.generate(map_data, start_position)

func generate(start_position: Vector2) -> Dictionary:
	var execution_time = measure_time(func() -> void:
		execute_generation(start_position)
	)
	var result = {
		"starship_map": map_data.starship_map,
		"initial_room_position": map_data.initial_room_position,
		"execution_time": execution_time
	}
	return result

func set_algorithm(algorithm: String) -> void:
	current_algorithm = algorithm
