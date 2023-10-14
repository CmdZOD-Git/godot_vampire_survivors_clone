extends ProgressBar

@onready var player = get_tree().get_first_node_in_group("player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.experience_change.connect(update)
			
func update(exp_now, exp_next):
	var calc = 100 * exp_now / exp_next
	set_value(calc)
