extends Resource

class_name  UpgradeEffect

enum effect_name_list {
	hp_up,
	defence_up,
	attack_up,
	weapon_ammo_up,
	weapon_attack_area_up,
	rocket_level,
	rocket_ammo,
	rocket_damage,
	plasma_level,
	plasma_damage,
	plasma_ammo,
	slasher_level,
	slasher_damage,
	slasher_ammo,
	heal,
}

@export var upgrade_effect:effect_name_list
@export var effect_value:int
