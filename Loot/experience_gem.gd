extends Area2D

@export var experience = 1

var speed = -0.5
var target = null

@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var sound =  $snd_collected

func _ready() -> void:
	if experience >= 10:
		sprite.set_frame(2)
	elif experience >= 5: 
		sprite.set_frame(1)
	else:
		sprite.set_frame(0)
 
func _physics_process(delta: float) -> void:
	if not target == null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += delta * 2
		
func collect():
	sound.play()
	collision.set_deferred("disabled",false)
	sprite.visible = false     
	return experience

func _on_snd_collected_finished() -> void:
	queue_free()
