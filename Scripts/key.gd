extends Area2D


func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.has_key = true
		print("You found the key!")
		queue_free()
