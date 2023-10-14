extends GridContainer

var displayed_node_tuple:Array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func level_up_choice_selected(item):
	if item.picked_upgrade.display_in_tray == false:
		return
		
	var item_to_upgrade_tray = load("res://GUI/picked_upgrade_icons.tscn").instantiate()
	var node_to_erase:Array
	
	item_to_upgrade_tray.get_node("Icon").texture = item.picked_upgrade.icon
	item_to_upgrade_tray.get_node("Icon/LevelMark").text = str(item.picked_upgrade.level)
	
	displayed_node_tuple.append([item_to_upgrade_tray, item.picked_upgrade])
	
	for tuple_to_check in displayed_node_tuple:
		if tuple_to_check[1].description_name == item.picked_upgrade.description_name:
			if tuple_to_check[1].level < item.picked_upgrade.level:
				node_to_erase.append(tuple_to_check)
				
	for target in node_to_erase:
		target[0].queue_free()
		displayed_node_tuple.erase(target)
		
	add_child(item_to_upgrade_tray)
