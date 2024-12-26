extends Area2D


func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_key:
			print("You are free!")
			get_tree().get_first_node_in_group("UI").on_player_escaped()
		else:
			print("Door is closed.")
