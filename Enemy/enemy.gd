extends CharacterBody2D


@export var movement_speed = 40
@export var hp = 5
@export var damage = 5
@export var knockback_recovery = 3.5
@export var xp_value = 3


var knockback: Vector2= Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot = get_tree().get_first_node_in_group("Loot")
@onready var sprite = $Sprite2D
@onready var animation = $AnimationPlayer
@onready var sound_hit = $HitSound

var death_anim = preload("res://Enemy/explosion.tscn")
var loot_gem = preload("res://Loot/experience_gem.tscn")

signal remove_from_array(object)

func _ready():
	animation.play("Move")

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	var direction = global_position.direction_to(player.global_position)
	
	if direction.x > 0:
		sprite.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true
		
	velocity = direction.normalized() * movement_speed
	velocity += knockback
	move_and_slide()

func death():
	emit_signal("remove_from_array", self)
	var enemy_death = death_anim.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	var xp_gem = loot_gem.instantiate()
	xp_gem.global_position = global_position
	xp_gem.experience = xp_value
	await get_tree().process_frame
	loot.add_child(xp_gem)
	queue_free()

func _on_hurt_box_hurt(damage, angle, knockback_amount):
	hp -= damage
	knockback = angle * knockback_amount
#	print("enemy hit HP:%s(dam %s)" % [hp, damage])
	if hp <= 0:
		death()
	else:
		sound_hit.play()
