extends CharacterBody2D

# Reference player on the script
@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var bullet_pool = get_node("BossBulletManager")

var health : int = 3
var damage : int = 1

var attack_chance : float = 0.5 #0.5

var has_gun: bool = true
var num_bullets: int = 3
# to save last movement up by default
var last_direction : Vector2 = Vector2.UP

func _ready() -> void:
	update_health_label()

func update_health_label() -> void:
	match health:
		6:
			$LabelHealth.text = "6"
		5:
			$LabelHealth.text = "5"
		4:
			$LabelHealth.text = "4"
		3:
			$LabelHealth.text = "3"
		2:
			$LabelHealth.text = "2"
		1:
			$LabelHealth.text = "1"

# Shoot
func shoot_bullet(direction: Vector2) -> void:
	get_node("SpawnPoint").position = last_direction*30
	if num_bullets > 0:
		print("num_bullets: ", num_bullets)
		Sfx.get_child(6).play() # Shot sound
		var bullet_temp: Node = bullet_pool.get_bullet()
		bullet_temp.velocity = direction * 300
		bullet_temp.global_position = get_node("SpawnPoint").global_position
		bullet_temp.show()
		num_bullets -= 1
		if num_bullets == 0:
			print("final boss has no ammo, recharging ...")
			num_bullets += 3


func move() -> void:
	var direction : Vector2 = Vector2.ZERO
	var can_move : bool = false
	
	while(can_move == false):
		direction = get_random_direction()
		last_direction = direction
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
		# Inform the player to remove this enemy from the list
		#player.remove_enemy(self)
		player.boss_defeated = true
		Global.enemies_defeated += 1
		queue_free()
	if allow_counterattack and randf() > attack_chance:
		print("counterattack damage!")
		player.take_damage(damage)
		print("health: ", Global.health)
	move()


func _on_timer_timeout() -> void:
	print("Final boss performing some action")
	#move()
	var ran: int = randi_range(0, 3)
	match ran:
		0:
			print("final boss moving!")
			move()
		1:
			print("final boss shooting!")
			shoot_bullet(last_direction)
		3:
			print("final boss awaiting")
			pass
