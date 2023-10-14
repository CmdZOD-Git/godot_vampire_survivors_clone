extends Area2D

var level = 1
var hp = 2
var speed = 200
var damage = 1
var knockback_amount = 75
var attack_size = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO

signal remove_from_array(object)

@onready var player = get_tree().get_first_node_in_group("player")
@onready var animation = $AnimationPlayer

func _ready():
	angle = position.direction_to(target)
	rotation = angle.angle()
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1) * attack_size * 4,0.25).set_trans(tween.TRANS_LINEAR)
	tween.play()
	
	animation.play("Move")
	
func _physics_process(delta):
	position += angle * speed * delta
	
func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array", self)
		queue_free()

func _on_timer_timeout():
	emit_signal("remove_from_array", self)
	queue_free()
