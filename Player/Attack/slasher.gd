extends Area2D

var level = 1
var hp = 10
var speed = 50
var damage = 10
var knockback_amount = 75
var attack_size = 1.0

enum ACTION_STATE {WALKING, ATTACKING, INIT}

var target = Vector2.ZERO
var angle = Vector2.ZERO

signal remove_from_array(object)

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $AnimatedSprite2D
@onready var hit_box = $HitBox
@onready var seek_area = $SeekArea
@onready var action_timer = $ActionTimer
@onready var label = $OverheadText

var action_state = ACTION_STATE.INIT

# Behaviour plan
# 1. Walk a bit -> Timer for walk time, no collision
# 2. Seek target -> Expanding collision to seek target ?
# 3. Charge target -> switch anime, move toward target, activate collision
# 4. Die when no more life -> LifeTimer over -> Queue free

func _ready():
	state_manager()
	
func set_random_walk_target(starting_position, distance):
	return starting_position + Vector2.from_angle(randf_range(-PI,PI)) * distance
	
func _physics_process(delta):
	if target != null:
		position += position.direction_to(target) * delta * speed
	
func state_manager():
	match  action_state:
		ACTION_STATE.WALKING:
			hit_box.set_deferred("disabled", true)
			target = set_random_walk_target(player.global_position,50)
			sprite.play("idle")
			action_timer.wait_time = 2
			action_timer.start()
			label.set_text("W")
		
		ACTION_STATE.ATTACKING:
			hit_box.set_deferred("disabled", false)
			target = get_target_closish()
			sprite.play("active")
			action_timer.wait_time = 1
			action_timer.start()
			label.set_text("A")
		
		ACTION_STATE.INIT:
			action_state = ACTION_STATE.WALKING
			hit_box.set_deferred("disabled", true)
			target = set_random_walk_target(player.global_position,50)
			sprite.play("idle")
			action_timer.start()
			label.set_text("I")
			
func get_target_closish():
	var target_list = seek_area.get_overlapping_bodies()
	for item in target_list:
		if item.is_in_group("Enemy"):
			return item.global_position
	
func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array", self)
		queue_free()

func _on_life_timer_timeout() -> void:
	emit_signal("remove_from_array", self)
	queue_free()

func _on_action_timer_timeout() -> void:
	if action_state == ACTION_STATE.WALKING:
		action_state = ACTION_STATE.ATTACKING
	else:
		action_state = ACTION_STATE.WALKING

	state_manager()
