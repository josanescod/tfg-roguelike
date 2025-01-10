extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Sfx.get_child(0).play() # 0 array of elements in Sfx
		Global.coins += 1
		print("coins: ", Global.coins)
		queue_free()
