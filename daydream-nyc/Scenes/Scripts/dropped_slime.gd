extends Area2D

var slimeAmount: float = 1
var placedId: int = 0
var scaleFactor: int = 2

func _ready() -> void:
	add_to_group("droppedSlime")
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func incrementSlimeAmount() -> void:
	slimeAmount += 1
	scale += Vector2(scaleFactor, scaleFactor)
	
func addSlimeAmount(amt: float) -> void:
	slimeAmount += amt
	scale += Vector2(amt * scaleFactor, amt * scaleFactor)

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
		if a.is_in_group("droppedSlime") and a.placedId > placedId:
			addSlimeAmount(a.slimeAmount)
			a.queue_free()
