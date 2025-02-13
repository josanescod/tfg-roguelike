extends CharacterBody2D

# Reference player on the script
@onready var player = get_tree().get_nodes_in_group("Player")[0]

var health : int = 3
var damage : int = 1
var attack_chance : float = 0.5

# drop gun
@export var gun_scene: PackedScene = preload("res://Nodes/gun.tscn")
var drop_chance : float = 1

func _ready() -> void:
	update_health_label()

func update_health_label() -> void:
	match health:
		3:
			$LabelHealth.text = "3"
		2:
			$LabelHealth.text = "2"
		1:
			$LabelHealth.text = "1"

func move() -> void:
	if randf() < 0.5:
		return
	var direction : Vector2 = Vector2.ZERO
	var can_move : bool = false
	while(can_move == false):
		direction = get_random_direction()
		var space_rid = get_world_2d().space # raycasting documentation -> https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html
		var space_state = PhysicsServer2D.space_get_direct_state(space_rid)
		var ray_query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(48, 48) * direction)
		var intersection_result = space_state.intersect_ray(ray_query)
		if not intersection_result and position + 48 * direction != player.position:
			can_move = true
	position += 48 * direction

func get_random_direction() -> Vector2:
	var ran: int = randi_range(0, 3)
	match ran:
		0:
			return Vector2.UP
		1:
			return Vector2.DOWN
		2: 
			return Vector2.LEFT
		3:
			return Vector2.RIGHT
	
	return Vector2.ZERO

func take_damage(damage_taken : int, allow_counterattack: bool = true) -> void:
	$SFX.stream = load("res://Assets/Sounds/hit.ogg")
	$SFX.play()
	health -= damage_taken
	update_health_label()
	$AnimationPlayer.play("Hit")
	print('Enemy health: ', health)
	if health <= 0:
		# % drop weapon
		if randf() < drop_chance:
			drop_gun()
		# Inform the player to remove this enemy from the list
		player.remove_enemy(self)
		Global.enemies_defeated += 1
		queue_free()
	
	if allow_counterattack and randf() > attack_chance:
		print("counterattack damage!")
		player.take_damage(damage)
		print("health: ", Global.health)
	#move()

func drop_gun() -> void:
	if gun_scene:
		var gun_instance = gun_scene.instantiate()
		if gun_instance:
			gun_instance.global_position = global_position
			print("Enemy died at: ", global_position)
			print("Dropping gun at: ", gun_instance.global_position)
			get_node("/root/World").call_deferred("add_child", gun_instance)
		else:
			print("Failed to instantiate gun_scene!")
	else:
		print("gun_scene is null!")
