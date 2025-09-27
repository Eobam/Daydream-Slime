extends Area2D

@export var toggleButton: bool
@export var connectedDoor: CharacterBody2D
@onready var animatedSprite = $AnimatedSprite2D

var btn_state: bool = false
var pressedBySlime: bool = false

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func onPress() -> void:
	if not pressedBySlime:
		btn_state = not btn_state
	else:
		btn_state = true

	if btn_state:
		animatedSprite.play("press")
		connectedDoor.openDoor()
	else:
		animatedSprite.play("press", -1)
		connectedDoor.closeDoor()
		

func _on_body_entered(_body: Node) -> void:
	if _body.name == "Player":
		onPress()
	if _body.is_in_group("droppedSlime"):
		pressedBySlime = true
		if not btn_state:
			onPress()

func _on_body_exited(_body: Node) -> void:
	if not toggleButton and not pressedBySlime :
		onPress()

func _physics_process(_delta: float) -> void:
	var overlappingAreas = get_overlapping_areas()
	if overlappingAreas.size() == 0:
		pressedBySlime = false
	for a in overlappingAreas:
		if a.is_in_group("droppedSlime"):
			pressedBySlime = true
			onPress()
