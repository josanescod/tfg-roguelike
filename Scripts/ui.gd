extends CanvasLayer


@onready var player : CharacterBody2D = get_tree().get_first_node_in_group("Player")

@onready var LevelBuilder : Node = $"../LevelBuilder"
@onready var grid : PackedScene = load("res://Nodes/mini_map_grid.tscn")

var elapsed_time : float = 0.0


func _ready() -> void:
	$"TimeBar/Timer".wait_time = 0.1
	$"TimeBar/Timer".start()
	generate_mini_map()
	

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

	$MiniMap/Label.text = "LEVEL " + str(Global.level) 
	update_minimap()

# handle time
func _on_timer_timeout() -> void:
	elapsed_time += 0.1
	var minutes = int(elapsed_time / 60)
	var seconds = int(elapsed_time) % 60
	#var milliseconds = int((elapsed_time - int(elapsed_time)) * 100)
	#$"TimeBar/Time".text = '%02d:%02d:%02d' % [minutes, seconds, milliseconds]
	$"TimeBar/Time".text = '%02d:%02d' % [minutes, seconds]
	
func on_player_escaped() -> void:
	$"TimeBar/Timer".stop()
	#print("Total time: ", $"TimeBar/Time".text)

# handle MiniMap
func generate_mini_map() -> void:
	$MiniMap/GridContainer.columns = LevelBuilder.ship_width
	for i in range(LevelBuilder.ship_heigth):
		for j in range(LevelBuilder.ship_width):
			var panel = grid.instantiate()
			if LevelBuilder.ship_map[j][i] == false:
				panel.modulate = "ffffff00" # room doesn't exist
			else:
				panel.is_room = true
			panel.pos = Vector2i(j, i)
			$MiniMap/GridContainer.add_child(panel)

func update_minimap() -> void:
	var pos : Vector2i = (player.global_position / 816) # to get the position in the map array
	var panels = $MiniMap/GridContainer.get_children()
	for panel in panels:
		if panel.is_room:
			panel.modulate = "ffffff"
		if panel.pos == pos:
			panel.modulate = "fdd5cf"
