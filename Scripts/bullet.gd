extends CharacterBody2D

var damage : int = 1

func _process(_delta: float) -> void:
	#self.rotation += 1
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and self.visible:
		if body.has_method("take_damage"):
			body.take_damage(damage, false)
			get_parent().reset_bullet(self)
	
	if body.is_in_group("Wall") and self.visible:
		get_parent().reset_bullet(self)
		
