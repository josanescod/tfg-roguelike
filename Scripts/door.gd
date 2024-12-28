extends Area2D


func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_key:
			print("You have finished this level!")
			Global.level +=1
			get_tree().get_first_node_in_group("UI").on_timer_stoped()
			get_tree().call_deferred("reload_current_scene")
		else:
			print("Door is closed.")
