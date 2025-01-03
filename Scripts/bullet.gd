extends CharacterBody2D

var damage: int = 1
var is_player_bullet: bool = true

func _process(_delta: float) -> void:
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not self.visible:
		return

	if is_player_bullet and body.is_in_group("Enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage, false)
			get_parent().reset_bullet(self)

	elif not is_player_bullet and body.is_in_group("Player") and self.visible:
		if body.has_method("take_damage"):
			body.take_damage(damage)
			get_parent().reset_bullet(self)
	
	elif body.is_in_group("Wall"):
		get_parent().reset_bullet(self)
		
