extends Control


func _ready() -> void:
	update_ui_text()

func update_ui_text():
	$Start/MsgDied.text = tr("MSG_DIED")
	$Start/Stats/Stats1.text = tr("STAT_LEVEL") + ": " + str(Global.level) 
	$Start/Stats/Stats2.text = tr("STAT_ENEMIES") + ": " + str(Global.enemies_defeated)
	$Start/Stats/Stats3.text =  tr("STAT_COINS") + ": "  + str(Global.coins)
	$Start/Stats/Stats4.text =  tr("STAT_TIME") + ": "  + format_time(Global.best_time)
	$Start/Buttons/BackMenu.text = tr("BTN_MENU")

func _on_back_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func format_time(time : float) -> String:
	if time == INF:
		return "--"
	var minutes = int(time/ 60)
	var seconds = int(time) % 60
	return '%02d:%02d' % [minutes, seconds]
