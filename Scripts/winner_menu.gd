extends Control



func _ready() -> void:
	$Start/MsgWon.text = tr("MSG_WON")
	$Start/Stats/Stats1.text = tr("STAT_LEVEL") + ": " + str(Global.level) 
	$Start/Stats/Stats2.text = tr("STAT_ENEMIES") + ": " + str(Global.enemies_defeated)
	$Start/Stats/Stats3.text =  tr("STAT_COINS") + ": "  + str(Global.coins)
	$Start/Buttons/BackMenu.text = tr("BTN_MENU")

func _on_back_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
