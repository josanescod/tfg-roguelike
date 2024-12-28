extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if Global.health < Global.max_health:
			Sfx.get_child(1).play() # element 1 in array of sounds in Sfx
			Global.health +=1
			print("Player health: ", Global.health)
			queue_free()
