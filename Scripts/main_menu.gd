extends Control




func _on_play_pressed() -> void:
	$Start.visible = false
	$Options.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_algo_1_pressed() -> void:
	pass # Replace with function body.
	Global.health = Global.max_health
	Global.level = 1
	Global.coins = 0
	Global.enemies_defeated = 0
	get_tree().change_scene_to_file("res://Scenes/world.tscn")


func _on_algo_2_pressed() -> void:
	pass # Replace with function body.


func _on_back_pressed() -> void:
	$Start.visible = true
	$Options.visible = false
