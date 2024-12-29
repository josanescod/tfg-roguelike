extends CharacterBody2D

@onready var bullet_pool = get_node("BulletManager")
# signal to emit
signal player_moved

# initial condition Player has not the key
var has_key : bool = false
var has_gun : bool = false
var num_bullets : int = 0

# to save last movement up by default
var last_direction : Vector2 = Vector2.UP

var enemies = []

func _ready() -> void:
	# background music
	Sfx.get_child(5).play()


# Main function to be executed in each physics frame
func _physics_process(_delta):
	if Global.game_paused:
		return
	player_input()

# Function to manage player input and determine the direction of motion
func player_input() -> void:
	var move_direction = Vector2.ZERO  	
	if Input.is_action_just_pressed("move_left"):
		move_direction = Vector2.LEFT
		move(move_direction)
	elif Input.is_action_just_pressed("move_up"):
		move_direction = Vector2.UP
		move(move_direction)
	elif Input.is_action_just_pressed("move_right"):
		move_direction = Vector2.RIGHT
		move(move_direction)
	elif Input.is_action_just_pressed("move_down"):
		move_direction = Vector2.DOWN
		move(move_direction)
	
	if move_direction != Vector2.ZERO:
		last_direction = move_direction
		# print("last direction:", last_direction)
	
	# space bar and last direction 
	if Input.is_action_just_pressed("attack"):
		get_node("SpawnPoint").position = last_direction*30
		match last_direction:
			Vector2.LEFT:
				if has_gun:
					shoot_bullet(Vector2.LEFT)
				else:
					try_attack(Vector2.LEFT)
				print("left attack!")
			Vector2.DOWN:
				if has_gun:
					shoot_bullet(Vector2.DOWN)
				else:
					try_attack(Vector2.DOWN)
				print("down attack!")
			Vector2.RIGHT:
				if has_gun:
					shoot_bullet(Vector2.RIGHT)
				else:
					try_attack(Vector2.RIGHT)
				print("right attack!")
			Vector2.UP:
				if has_gun:
					shoot_bullet(Vector2.UP)
				else:
					try_attack(Vector2.UP)
				print("up attack!")
		print("health: ", Global.health)

# Function to move the character in the specified direction, performing raycasting to detect collisions.
func move(direction : Vector2) -> void: 
	var space_rid = get_world_2d().space # raycasting documentation -> https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html
	var space_state = PhysicsServer2D.space_get_direct_state(space_rid)
	var ray_query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(48, 48) * direction)
	var intersection_result = space_state.intersect_ray(ray_query)
	
	if intersection_result and intersection_result.collider.is_in_group("Wall"):
		return
	else:
		position += 48 * direction
		$SFX.stream = load("res://Assets/Sounds/walk.ogg")
		$SFX.play()
		check_enemy_proximity()
		player_moved.emit()

# Shoot
func shoot_bullet(direction: Vector2) -> void:
	if num_bullets > 0:
		print("num_bullets: ", num_bullets)
		var bullet_temp: Node = bullet_pool.get_bullet()
		bullet_temp.velocity = direction * 300
		bullet_temp.global_position = get_node("SpawnPoint").global_position
		bullet_temp.show()
		num_bullets -= 1
	else:
		has_gun = false

# Attack
func try_attack(direction : Vector2) -> void:
	var space_rid = get_world_2d().space # raycasting documentation -> https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html
	var space_state = PhysicsServer2D.space_get_direct_state(space_rid)
	var ray_query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(48, 48) * direction)
	var intersection_result = space_state.intersect_ray(ray_query)
	
	if intersection_result:
		if intersection_result.collider.is_in_group("Enemy"):
			intersection_result.collider.take_damage(1)

# Function take damage
func take_damage(damage_taken : int) -> void:
	Global.health -= damage_taken
	print('Player health: ', Global.health)
	$SFX.stream = load("res://Assets/Sounds/hit.ogg")
	$SFX.play()
	$AnimationPlayer.play("Hit")
	if Global.health <= 0:
		Sfx.get_child(4).play()
		call_deferred("reload_scene")

func reload_scene() -> void:
	print("You died!")
	print(Global.best_time)
	Sfx.get_child(5).stop()
	get_tree().change_scene_to_file("res://Scenes/death_menu.tscn")

func check_enemy_proximity() -> void:
	# all possible directions
	var directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN,Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)]
	# Raycasting to all directions
	for direction in directions:
		var space_rid = get_world_2d().space
		var space_state = PhysicsServer2D.space_get_direct_state(space_rid)
		var ray_query = PhysicsRayQueryParameters2D.create(global_position, global_position + 48 * direction)
		var intersection_result = space_state.intersect_ray(ray_query)
		# proximity damage
		if intersection_result:
			if intersection_result.collider.is_in_group("Enemy"):
				print("Enemy detected in direction ", direction)
				take_damage(1)
				print("proximity attack!")
				print("health: ", Global.health)

# Function to remove the enemy from the list
func remove_enemy(enemy):
	enemies.erase(enemy)
