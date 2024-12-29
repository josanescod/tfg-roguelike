extends Control


func _ready() -> void:
	TranslationServer.set_locale(Global.language)
	$Start/Buttons/Play.text = tr("BTN_PLAY")
	$Start/Buttons/Quit.text = tr("BTN_QUIT")
	$Options/Buttons/Algo.text = tr("BTN_ALGO")
	$Options/Buttons/Back.text = tr("BTN_BACK")

func _on_play_pressed() -> void:
	$Start.visible = false
	$Options.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_algo_1_pressed() -> void:
	pass # Replace with function body.
	Global.health = Global.max_health
	Global.level = 1
	Global.coins = 0
	Global.enemies_defeated = 0
	Global.game_paused = false
	get_tree().change_scene_to_file("res://Scenes/world.tscn")


func _on_algo_2_pressed() -> void:
	pass # Replace with function body.


func _on_back_pressed() -> void:
	$Start.visible = true
	$Options.visible = false


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
