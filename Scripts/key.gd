extends Area2D


func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.has_key = true
		Sfx.get_child(2).play()
		print("You found the key!")
		queue_free()
