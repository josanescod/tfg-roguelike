extends Area2D

@onready var ui = get_tree().get_first_node_in_group("UI")

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_key:
			if Global.level == Global.max_level - 1:
				if not body.boss_defeated:
					print("Boss still alive!")
					return
				Sfx.get_child(7).play()
			else:
				Sfx.get_child(3).play()
			print("You have finished this level!")
			Global.level +=1
			save_best_time()
			get_tree().get_first_node_in_group("UI").on_timer_stoped()
			if Global.level == Global.max_level:
				Sfx.get_child(1).stop()
				call_deferred("load_winner_scene")
			else:
				get_tree().call_deferred("reload_current_scene")
		else:
			print("Door is closed.")


func load_winner_scene() -> void:
	get_tree().change_scene_to_file("res://Scenes/winner_menu.tscn")

func save_best_time() -> void:
	var elapsed_time = ui.elapsed_time
	print("Current time:", elapsed_time)
	print("Previous best time:", Global.best_time)
	if elapsed_time < Global.best_time:
		Global.best_time = elapsed_time
		print("New best time:", Global.best_time)
