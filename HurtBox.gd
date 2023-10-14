extends Area2D

@export_enum("Cooldown", "HitOnce", "DisableHitBox") var HurtBoxType = 0

@onready var collision = $HurtBoxShape
@onready var disableTimer = $DisableTimer

signal hurt(damage, angle, knockback)
signal remove_from_array(object)

var hit_once_array: Array = []

func _on_area_entered(area):
	if not area.is_in_group("Attack"):
		return
	if area.get("damage") == null:
		return
			
	match HurtBoxType: 
		0:
			collision.call_deferred("set","disabled",true)
			disableTimer.start()
		1:
			if hit_once_array.has(area) == false:
				hit_once_array.append(area)
				if area.has_signal("remove_from_array"):
					if not area.is_connected("remove_from_array", Callable(self,"remove_from_list")):
						area.connect("remove_from_array", Callable(self,"remove_from_list"))
			else:
				return
		2:
			if area.has_method("tempdisable"):
				area.tempdisable()
	
	var damage = area.damage
	var angle = Vector2.ZERO
	var knockback = 1
	
	if not area.get("angle") == null:
		angle = area.angle
		
	if not area.get("knockback_amount") == null:
		knockback = area.knockback_amount
	
	emit_signal("hurt", damage, angle, knockback)
	
	if area.has_method("enemy_hit"):
		area.enemy_hit(1)

func remove_from_list(object):
	if hit_once_array.has(object):
		hit_once_array.erase(object)

func _on_timer_timeout():
	emit_signal("remove_from_array", self)
	collision.call_deferred("set","disabled",false)
