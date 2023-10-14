extends Label

var displayed_time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	EVENT.connect("TIME_PLUS_ONE", Callable(self,"time_plus_one"))
#	EVENT.connect("TIME_PLUS_ONE", Callable(self,"time_plus_one"))
	MAIN_BUS.TIME_PLUS_ONE_SIGNAL.connect(time_plus_one)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func time_plus_one(total_time):
	var minute:int = floor(total_time / 60)
	var second:int = total_time % 60
	var minute_text:String = str(minute).lpad(2,"0")
	var second_text:String = str(second).lpad(2,"0")
		
	text = "%s:%s" % [minute_text, second_text]
