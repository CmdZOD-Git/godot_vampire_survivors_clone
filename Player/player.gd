extends CharacterBody2D

@export var movement_speed = 80.0
@export var hp:float = 40
@export var hp_max = 40
@export var defence = 0
@export var offence = 0
@export var general_ammo = 0
@export var general_attack_size = 0
@export var player_upgrade_list:Array[UpgradeList] = []
var upgrade_taken:Array[String] = []

var enemy_close:Array

#Level Up
var level_up_panel = preload("res://GUI/level_up_panel.tscn")
var level_up_option = preload("res://GUI/level_up_option.tscn")
var option_slot_amount = 3
var option_panel

#Death
var death_panel = preload("res://GUI/death_panel.tscn")

#HP Bar
@onready var hp_bar = get_node("%HPBar")

#UpgradePickedTray
@onready var upgrade_picked_tray = get_tree().get_root().get_node("Main/CanvasLayer/Control/UpgradePicked")

#Attacks
var rocket = preload("res://Player/Attack/rocket.tscn")
var plasma = preload("res://Player/Attack/plasma.tscn")
var slasher = preload("res://Player/Attack/slasher.tscn")

#AttackNodes
@onready var rocketTimer = get_node("%RocketTimer")
@onready var rocketAttackTimer = get_node("%RocketAttackTimer")
@onready var plasmaTimer = get_node("%PlasmaTimer")
@onready var plasmaAttackTimer = get_node("%PlasmaAttackTimer")
@onready var slasherTimer = get_node("%SlasherTimer")
@onready var slasherAttackTimer = get_node("%SlasherAttackTimer")

#Rocket
var rocket_ammo = 0
var rocket_base_ammo  = 1
var rocket_attackspeed = 1
var rocket_level = 0
var rocket_damage = 0

#plasma
var plasma_ammo = 0
var plasma_base_ammo  = 1
var plasma_attackspeed = 2
var plasma_level = 0
var plasma_damage = 0

#slasher
var slasher_ammo = 0
var slasher_base_ammo  = 1
var slasher_attackspeed = 1
var slasher_level =0
var slasher_damage =0

var experience = 0
var experience_level = 1
var collected_experience = 0

@onready var sprite = $Sprite2D
@onready var animation = $AnimationPlayer

signal experience_change(experience_now, experience_to_next)
signal level_change(level)

func _ready():
	pass

func _physics_process(_delta):
	movement()
	attack()
	check_experience()

func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov,y_mov)
	if mov.x > 0:
		sprite.flip_h = false
	elif mov.x < 0:
		sprite.flip_h = true
	
	if mov != Vector2.ZERO:
		animation.play("Move")
	else:
		animation.pause()
		
	velocity = mov.normalized() * movement_speed
	move_and_slide()


func _on_hurt_box_hurt(damage, _angle, _knockback):
	var defence_ratio:float = 10 / (10 + defence as float)
	hp -= damage * defence_ratio
	hp = clamp(hp,0, hp_max)
	hp_bar.set_scale(Vector2(hp / hp_max,1))
	if hp == 0:
		get_tree().set_pause(true)
		var _death_panel = death_panel.instantiate()
		await get_tree().process_frame
		get_tree().get_first_node_in_group("GUI").add_child(_death_panel)
	
func attack():
	if rocket_level > 0:
		rocketTimer.wait_time = rocket_attackspeed
		if rocketTimer.is_stopped():
			rocketTimer.start()
	
	if plasma_level > 0:
		plasmaTimer.wait_time = plasma_attackspeed
		if plasmaTimer.is_stopped():
			plasmaTimer.start()
	
	if slasher_level > 0:
		slasherTimer.wait_time = slasher_attackspeed
		if slasherTimer.is_stopped():
			slasherTimer.start()


func _on_rocket_timer_timeout():
	rocket_ammo += rocket_base_ammo + general_ammo
	rocketAttackTimer.start()

func _on_rocket_attack_timer_timeout():
	if rocket_ammo > 0:
		var rocket_attack = rocket.instantiate()
		rocket_attack.position = position
		rocket_attack.target = get_random_target()
		rocket_attack.level = rocket_level
		rocket_attack.damage += rocket_damage + offence
		rocket_attack.attack_size += general_attack_size*0.1
		get_tree().root.add_child(rocket_attack)
		rocket_ammo -= 1
		if rocket_ammo > 0:
			rocketAttackTimer.start()
		else:
			rocketAttackTimer.stop()
			
func _on_plasma_timer_timeout():
	plasma_ammo += plasma_base_ammo + general_ammo
	plasmaAttackTimer.start()

func _on_plasma_attack_timer_timeout():
	if plasma_ammo > 0:
		var plasma_attack = plasma.instantiate()
		plasma_attack.position = position
		plasma_attack.level = plasma_level
		plasma_attack.damage += plasma_damage + offence
		plasma_attack.attack_size += general_attack_size*0.1
		get_tree().root.add_child(plasma_attack)
		plasma_ammo -= 1
		if plasma_ammo > 0:
			plasmaAttackTimer.start()
		else:
			plasmaAttackTimer.stop()
			
func _on_slasher_timer_timeout():
	slasher_ammo += slasher_base_ammo
	slasherAttackTimer.start()

func _on_slasher_attack_timer_timeout():
	if slasher_ammo > 0:
		var slasher_attack = slasher.instantiate()
		slasher_attack.position = position
		slasher_attack.level = slasher_level
		get_tree().root.add_child(slasher_attack)
		slasher_ammo -= 1
		if slasher_ammo > 0:
			slasherAttackTimer.start()
		else:
			slasherAttackTimer.stop()
		
func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP

func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body):
	enemy_close.erase(body)


func _on_grab_attract_area_area_entered(area: Area2D) -> void:
		if area.is_in_group("Loot"):
			area.target = self

func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Loot"):
		var gem_xp = area.collect()
		collected_experience += gem_xp

func check_experience():
	var exp_required = calculate_expericence_cap()
	
	if collected_experience > 0:
		experience += collected_experience
		collected_experience = 0
		emit_signal("experience_change", experience, exp_required)
	
	if experience >= exp_required:
			experience -= exp_required
			experience_level += 1
			exp_required = calculate_expericence_cap()
			emit_signal("level_change",experience_level)
			emit_signal("experience_change", experience, exp_required)
			level_up()
	
func calculate_expericence_cap():
	var exp_cap
	if experience_level >= 20:
		exp_cap =  100 + experience_level * 10
	elif experience >= 10:
		exp_cap =  50 + experience_level * 5
	else:
		exp_cap =  10 + experience_level * 2

	return exp_cap

func level_up():
	
	option_panel = level_up_panel.instantiate()
	get_tree().get_first_node_in_group("GUI").add_child(option_panel)
	var this_level_upgrade_item:Array
	this_level_upgrade_item.append_array(get_upgrade_item(player_upgrade_list, upgrade_taken))
	
	for i in option_slot_amount:
		var picked_upgrade:Upgrade
		if this_level_upgrade_item.size()>0:
			picked_upgrade = this_level_upgrade_item.pick_random()
			this_level_upgrade_item.erase(picked_upgrade)
		else:
			var food = load("res://Player/Upgrade/Default/food.tres")
			picked_upgrade = food
		
		var option_slot = level_up_option.instantiate()
		option_slot.get_node("%ItemIcon").texture = picked_upgrade.icon
		option_slot.get_node("%Title").text = str("%s" % [picked_upgrade.description_name])
		option_slot.get_node("%LevelMark").text = str("%s" % [picked_upgrade.level])
		option_slot.get_node("%Description").text = picked_upgrade.description
		option_slot.picked_upgrade = picked_upgrade
		option_slot.connect("level_up_choice", Callable(self, "level_up_choice_selected"))
		option_slot.connect("level_up_choice", Callable(upgrade_picked_tray, "level_up_choice_selected"))
		option_panel.get_node("VBoxContainer/OptionContainer").add_child(option_slot)
	
	await get_tree().process_frame
	get_tree().set_pause(true)
	
func level_up_choice_selected(item):
	var effect_list = item.picked_upgrade.effect_call

	if effect_list.size() > 0:
		for effect in effect_list:
			match effect.upgrade_effect:
				UpgradeEffect.effect_name_list["hp_up"]:
					hp_max += effect.effect_value
					hp += effect.effect_value
				UpgradeEffect.effect_name_list["heal"]:
					hp += effect.effect_value
					if hp > hp_max:
						hp = hp_max
						print("hp clamped")
				UpgradeEffect.effect_name_list["defence_up"]:
					defence += effect.effect_value
				UpgradeEffect.effect_name_list["attack_up"]:
					offence += effect.effect_value
				UpgradeEffect.effect_name_list["weapon_ammo_up"]:
					general_ammo += effect.effect_value
				UpgradeEffect.effect_name_list["weapon_attack_area_up"]:
					general_attack_size += effect.effect_value
				UpgradeEffect.effect_name_list["rocket_level"]:
					rocket_level += effect.effect_value
				UpgradeEffect.effect_name_list["rocket_ammo"]:
					rocket_base_ammo += effect.effect_value
				UpgradeEffect.effect_name_list["rocket_damage"]:
					rocket_damage += effect.effect_value
				UpgradeEffect.effect_name_list["plasma_level"]:
					plasma_level += effect.effect_value
				UpgradeEffect.effect_name_list["plasma_ammo"]:
					plasma_base_ammo += effect.effect_value
				UpgradeEffect.effect_name_list["plasma_damage"]:
					plasma_damage += effect.effect_value
				UpgradeEffect.effect_name_list["slasher_level"]:
					slasher_level += effect.effect_value
				UpgradeEffect.effect_name_list["slasher_ammo"]:
					slasher_base_ammo += effect.effect_value
				UpgradeEffect.effect_name_list["slasher_damage"]:
					slasher_damage += effect.effect_value

	upgrade_taken.append(item.picked_upgrade.name)	
	option_panel.queue_free()
	get_tree().set_pause(false)

func get_upgrade_item(actor_upgrade_list, actor_upgrade_taken):
	var return_list:Array = []
	for list in actor_upgrade_list:
		for item in list.upgrade_list:
			if actor_upgrade_taken.has(item.name):
				continue
				
			if item.prerequisite.size() == 0:
				return_list.append(item)
			else:
				for prereq in item.prerequisite:
					if not actor_upgrade_taken.has(prereq):
						break
					else:
						return_list.append(item)
	
	return return_list
