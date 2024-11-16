extends CharacterBody2D

# Main function to be executed in each physics frame
func _physics_process(_delta):
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

# Function to move the character in the specified direction, performing raycasting to detect collisions.
func move(direction : Vector2) -> void: 
	var space_rid = get_world_2d().space # raycasting documentation -> https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html
	var space_state = PhysicsServer2D.space_get_direct_state(space_rid)
	var ray_query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(48, 48) * direction)
	var intersection_result = space_state.intersect_ray(ray_query)
	
	if intersection_result and intersection_result.collider.is_in_group("ShipWall"):
		return			
	else:
		position += 48 * direction

	
