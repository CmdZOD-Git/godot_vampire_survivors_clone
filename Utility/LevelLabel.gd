extends Label

@onready var player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	player.level_change.connect(update)
			
func update(level):
	set_text("Level :%s" % str(level))
