extends Button

class_name Option_Choice


@onready var upgrade_icon = %ItemIcon
@onready var upgrade_title = $HBoxContainer/VBoxContainer/Title
@onready var upgrade_description = $HBoxContainer/VBoxContainer/Description
@onready var upgrade_level
@onready var upgrade_reference
@onready var picked_upgrade

signal level_up_choice(picked_upgrade)

func _on_button_up() -> void:
	emit_signal("level_up_choice", self)
