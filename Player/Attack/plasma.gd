extends Area2D

var level = 1
var hp = 9999
var speed = 40
var damage = 3
var knockback_amount = 30
var attack_size = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO
var side_angle = Vector2.ZERO
var wave_accumulator = 0
var wave_height = 1.5
var wave_frequency = 2
var wave_strength = 0.5

signal remove_from_array(object)

@onready var player = get_tree().get_first_node_in_group("player")
@onready var animation = $AnimationPlayer

func _ready():
	angle = Vector2.from_angle(randf_range(-PI,PI))
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1) * attack_size * 2,5).set_trans(tween.TRANS_LINEAR)
	tween.play()
	
func _physics_process(delta):
	wave_accumulator += delta
	side_angle = angle.orthogonal() * cos(wave_accumulator * wave_frequency) * wave_height
	position += angle * speed * delta
	position += side_angle * speed * delta
	
func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array", self)
		queue_free()

func _on_plasma_timer_timeout():
	emit_signal("remove_from_array", self)
	queue_free()
