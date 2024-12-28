extends Area2D


func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_key:
			if Global.level == Global.max_level - 1:
				Sfx.get_child(6).play()
			else:
				Sfx.get_child(3).play()
			print("You have finished this level!")
			Global.level +=1
			get_tree().get_first_node_in_group("UI").on_timer_stoped()
			if Global.level == Global.max_level:
				Sfx.get_child(5).stop()
				call_deferred("load_winner_scene")
			else:
				get_tree().call_deferred("reload_current_scene")
		else:
			print("Door is closed.")


func load_winner_scene() -> void:
	get_tree().change_scene_to_file("res://Scenes/winner_menu.tscn")
