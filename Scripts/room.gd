extends Node2D


var inside_width : int = 9
var inside_height : int = 9

@onready var LevelBuilder : Node

@export var enemy_item : PackedScene
@export var coin_item : PackedScene
@export var heart_item: PackedScene

var used_position : Array

func _ready():
	if LevelBuilder:
		populate_room_with_items()

func north():
	$NorthDoor.visible = true
	$NorthWall.queue_free()
	
func south():
	$SouthDoor.visible = true
	$SouthWall.queue_free()

func east():
	$EastDoor.visible = true
	$EastWall.queue_free()
	
func west():
	$WestDoor.visible = true
	$WestWall.queue_free()
	
func show_instructions_on_the_floor():
	$Instructions_Floor.visible = true

# populate the interior of the rooms with enemies, coins and hearts
func populate_room_with_items() -> void:
	if randf_range(0, 1) < LevelBuilder.enemy_spawn_probability:
		spawn_item(enemy_item, 1, LevelBuilder.max_enemies_per_room)
	if randf_range(0, 1) < LevelBuilder.coin_spawn_probability:
		spawn_item(coin_item, 1, LevelBuilder.max_coins_per_room)
	if randf_range(0, 1) < LevelBuilder.heart_spawn_probability:
		spawn_item(heart_item, 1, LevelBuilder.max_hearts_per_room)

func spawn_item(item_scene : PackedScene, min_ins : int = 0, max_ins : int = 0) -> void:
	var num : int = 1
	if min_ins != 0 or max_ins != 0:
		num = randi_range(min_ins, max_ins)

	for i in range(num):
		var item = item_scene.instantiate()
		# position where items can be generated
		var pos : Vector2 = Vector2(48 * randi_range(2, inside_width - 1) - 24, 48 * randi_range(2, inside_height - 1) - 24 )
		while pos in used_position:
			pos = Vector2(48 * randi_range(2, inside_width - 1) - 24, 48 * randi_range(2, inside_height - 1) - 24 )
		item.position = pos
		used_position.append(pos)
		add_child(item)
	# if item is an enemy, add it to the enemies array
	if item_scene == enemy_item:
		get_tree().get_first_node_in_group("Enemy_Manager").check_enemies()
