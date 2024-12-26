extends Node


var enemies : Array
var player: CharacterBody2D

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	player.connect("player_moved", Callable(self, "on_player_moved"))
	check_enemies()
	

func check_enemies() -> void:
	enemies = get_tree().get_nodes_in_group("Enemy")

func on_player_moved() -> void:
	# To filter out any null or freed enemies
	enemies = enemies.filter(func (enemy): return enemy != null )
	for enemy in enemies:
		if enemy:
			enemy.move()
