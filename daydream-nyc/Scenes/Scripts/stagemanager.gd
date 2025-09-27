extends Node

@export var levels: Array[PackedScene] = []
@export var player: CharacterBody2D

var current_stage_index: int = 0
var current_level: Node = null

func _ready() -> void:
	load_stage(0)

func load_stage(index: int) -> void:
	if current_level:
		current_level.queue_free()

	if index < 0 or index >= levels.size():
		print("No more stages!")
		return

	current_stage_index = index
	current_level = levels[index].instantiate()
	get_tree().get_root().add_child(current_level)
	
	var start_pos = current_level.get_node("startPos")
	if start_pos and player:
		player.global_position = start_pos.global_position
		player.velocity = Vector2(0, 0)
	else:
		print("Start pos not foond: Error!!!!!!!!")
	
	
