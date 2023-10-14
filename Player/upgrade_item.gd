extends Resource

class_name Upgrade

@export var name:String = "N/A"
@export var level:int = 0
@export var icon:Texture2D
@export var prerequisite:Array[String] = []
@export var effect_call:Array[UpgradeEffect] = []
@export var description_name:String = "Name"
@export_multiline var description:String = """Description:"""
@export var display_in_tray:bool = true
