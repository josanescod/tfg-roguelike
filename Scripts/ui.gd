extends CanvasLayer


@onready var player : CharacterBody2D = get_tree().get_first_node_in_group("Player")

@onready var LevelBuilder : Node = $"../LevelBuilder"
var elapsed_time : float = 0.0


func _ready() -> void:
	$"TimeBar/Timer".wait_time = 0.1
	$"TimeBar/Timer".start()
	

func _process(_delta):
	$StatBar/Coins.text = str(Global.coins)	
	
	
	# handle key
	if player.has_key:
		$StatBar/KeySprite.modulate = "ffffff"
	else:
		$StatBar/KeySprite.modulate = "ffffff20"
		

	# handle hearts
	match Global.health:
		6:
			$"HealthBar/Heart1".frame = 2
			$"HealthBar/Heart2".frame = 2
			$"HealthBar/Heart3".frame = 2
		5:
			$"HealthBar/Heart1".frame = 2
			$"HealthBar/Heart2".frame = 2
			$"HealthBar/Heart3".frame = 1
		4: 
			$"HealthBar/Heart1".frame = 2
			$"HealthBar/Heart2".frame = 2
			$"HealthBar/Heart3".frame = 0
		3: 
			$"HealthBar/Heart1".frame = 2
			$"HealthBar/Heart2".frame = 1
			$"HealthBar/Heart3".frame = 0
		2:
			$"HealthBar/Heart1".frame = 2
			$"HealthBar/Heart2".frame = 0
			$"HealthBar/Heart3".frame = 0
		1:
			$"HealthBar/Heart1".frame = 1
			$"HealthBar/Heart2".frame = 0
			$"HealthBar/Heart3".frame = 0
		0: 
			$"HealthBar/Heart1".frame = 0
			$"HealthBar/Heart2".frame = 0
			$"HealthBar/Heart3".frame = 0

# handle time
func _on_timer_timeout() -> void:
	elapsed_time += 0.1
	var minutes = int(elapsed_time / 60)
	var seconds = int(elapsed_time) % 60
	var milliseconds = int((elapsed_time - int(elapsed_time)) * 100)
	$"TimeBar/Time".text = '%02d:%02d:%02d' % [minutes, seconds, milliseconds]
	
func on_player_escaped() -> void:
	$"TimeBar/Timer".stop()
	#print("Total time: ", $"TimeBar/Time".text)
