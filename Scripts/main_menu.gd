extends Control


func _ready() -> void:
	initialize_menu()


func initialize_menu() -> void:
	TranslationServer.set_locale(Global.language)
	$Start/Buttons/Play.text = tr("BTN_PLAY")
	$Start/Buttons/Quit.text = tr("BTN_QUIT")
	$Options/Buttons/Algo.text = tr("BTN_ALGO")
	$Options/Buttons/Back.text = tr("BTN_BACK")
	update_continue_button_state()



func update_continue_button_state() -> void:
	if Global.algorithm == "":
		$Options/Buttons/Continue.disabled = true
	else:
		$Options/Buttons/Continue.disabled = false

func _on_play_pressed() -> void:
	Global.algorithm = ""
	$Start.visible = false
	$Options.visible = true


func _on_quit_pressed() -> void:
	if OS.get_name() == "Web":
		JavaScriptBridge.eval("window.location.href='https://github.com/josanescod/tfg-roguelike/index.html'")
	else:
		get_tree().quit()

func _on_language_pressed() -> void:
	if Global.language=="en":
		$Start/Buttons/Language.text = "es"
		Global.language = "es"

	elif Global.language=="es":
		$Start/Buttons/Language.text = "ca"
		Global.language = "ca"

	else:
		$Start/Buttons/Language.text = "en"
		Global.language = "en"
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_algo_pressed() -> void:
	match Global.algorithm:
		"":
			$Options/Buttons/Algo.text = "Random Walk"
			Global.algorithm = "random_walk"
		"random_walk":
			$Options/Buttons/Algo.text = "Cellular"
			Global.algorithm = "cellular"
		"cellular":
			$Options/Buttons/Algo.text = "Agent Based"
			Global.algorithm = "agent_based"
		"agent_based":
			$Options/Buttons/Algo.text = "Random Walk"
			Global.algorithm = "random_walk"
	update_continue_button_state()


func _on_continue_pressed() -> void:
	if $Options/Buttons/Continue.disabled:
		print("Please select an algorithm before continuing.")
		return  # Prevent scene change if algorithm is empty
	Global.health = Global.max_health
	Global.level = 1
	Global.coins = 0
	Global.enemies_defeated = 0
	Global.game_paused = false
	Global.best_time = INF
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_back_pressed() -> void:
	Global.language = "en"
	$Start.visible = true
	$Options.visible = false
