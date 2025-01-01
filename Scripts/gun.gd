extends Area2D


func _ready() -> void:
	print("Gun initialized at position: ", global_position)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not body.has_gun:
			Sfx.get_child(5).play() # element 1 in array of sounds in Sfx
			body.has_gun = true
			body.num_bullets = 3
			print("Player has a gun!")
			queue_free()
