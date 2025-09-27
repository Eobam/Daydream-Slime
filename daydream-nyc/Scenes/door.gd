extends CharacterBody2D

var open: bool = false
@export var openStyle: String = "down"
@export var move_duration: float = 0.5   # seconds
@onready var collision_shape_2d = $CollisionShape2D

var start_pos: Vector2
var target_pos: Vector2
var timer: float = 0.0
var isMoving: bool = false

func _ready() -> void:
	start_pos = global_position
	target_pos = start_pos

func _physics_process(delta: float) -> void:
	if isMoving:
		timer += delta
		var t = timer / move_duration
		if t >= 1.0:
			t = 1.0
			isMoving = false
			timer = 0.0
		global_position = start_pos.lerp(target_pos, t)

func openDoor() -> void:
	if not open and not isMoving:
		open = true
		start_pos = global_position
		var distance = get_height()  # move by full height
		match openStyle:
			"down":
				target_pos = start_pos + Vector2(0, distance)
			"up":
				target_pos = start_pos - Vector2(0, distance)
			"left":
				target_pos = start_pos - Vector2(distance, 0)
			"right":
				target_pos = start_pos + Vector2(distance, 0)
			_:
				target_pos = start_pos
		timer = 0.0
		isMoving = true

func closeDoor() -> void:
	if open and not isMoving:
		open = false
		start_pos = global_position
		var distance = get_height()  # move back by full height
		match openStyle:
			"down":
				target_pos = start_pos - Vector2(0, distance)
			"up":
				target_pos = start_pos + Vector2(0, distance)
			"left":
				target_pos = start_pos + Vector2(distance, 0)
			"right":
				target_pos = start_pos - Vector2(distance, 0)
			_:
				target_pos = start_pos
		timer = 0.0
		isMoving = true

func get_height() -> float:
	if collision_shape_2d and collision_shape_2d.shape is RectangleShape2D:
		var rect_shape = collision_shape_2d.shape as RectangleShape2D
		return rect_shape.extents.y * 2
	return 64.0  # fallback height
