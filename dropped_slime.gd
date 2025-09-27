extends Area2D

var slimeAmount: int = 1
var placedId: int = 0

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func incrementSlimeAmount() -> void:
	slimeAmount += 1
	scale += Vector2(0.5, 0.5)

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		body.can_interact = true
		body.interact_area = self

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		body.can_interact = false
		body.interact_area = null

func _physics_process(_delta: float):
	var overlapping_areas = get_overlapping_areas()
	for a in overlapping_areas:
		if a.placedId > placedId:
			incrementSlimeAmount()
			a.queue_free()
