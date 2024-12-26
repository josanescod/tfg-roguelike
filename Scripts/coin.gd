extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.coins += 1
		print("coins: ", Global.coins)
		queue_free()
