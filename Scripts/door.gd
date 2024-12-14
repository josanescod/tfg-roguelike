extends Area2D


func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_key:
			print("You are free!")
		else:
			print("Door is closed.")
