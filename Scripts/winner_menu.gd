extends Control



func _ready() -> void:
	$Start/Buttons/Stats.text = "Level Reached: " + str(Global.level) + "\nEnemies Defeated: " + str(Global.enemies_defeated) + "\nCoins Collected: " + str(Global.coins)



func _on_back_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
