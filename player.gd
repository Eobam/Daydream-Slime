extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var SLIME_CAPACITY: float = scale[0]
var LOWER_SLIME_CAPACITY: float = scale[0] - 5

var slime_scale_internal: float = scale[0]
var CURRENT_SLIME_SCALE: float:
	get:
		return slime_scale_internal
	set(value):	
		if value > SLIME_CAPACITY:
			value = SLIME_CAPACITY
		if value < LOWER_SLIME_CAPACITY:
			value = LOWER_SLIME_CAPACITY
		slime_scale_internal = value
		scale = Vector2(value, value)

# Interaction state
var can_interact: bool = false
var interact_area: Area2D = null

var nextSlimeId: int = 0

# PackedScene reference for dropped slime
@export var dropped_slime_scene: PackedScene

func _ready() -> void:
	scale = Vector2(scale[0], scale[1])

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		dropSlime()
	if Input.is_action_just_pressed("interact2") and interact_area:
		pickupSlime()

# ----------------------
# Slime interactions
# ----------------------

func dropSlime() -> void:
	if CURRENT_SLIME_SCALE <= LOWER_SLIME_CAPACITY:
		return
	
	# Spawn dropped slime
	if dropped_slime_scene and is_on_floor:
		var slime_instance = dropped_slime_scene.instantiate()
		slime_instance.placedId = nextSlimeId
		nextSlimeId += 1
		get_parent().add_child(slime_instance)
		
		var ray = PhysicsRayQueryParameters2D.new()
		ray.from = global_position
		ray.to = global_position + Vector2(0, 1000)  # cast straight down
		ray.exclude = [self]  # ignore player

		# Perform raycast
		var result = get_world_2d().direct_space_state.intersect_ray(ray)

		if result:
			# Place slime slightly above the floor
			slime_instance.global_position = result.position - Vector2(0, 4)
			
		else:
			# Fallback if no floor detected
			slime_instance.global_position = global_position + Vector2(0, 16)
		
		slime_instance.slimeAmount = 1  
		
		

	# Shrink player
	CURRENT_SLIME_SCALE -= 1

	# Bounce slightly if midair
	if not is_on_floor():
		velocity.y = JUMP_VELOCITY

func pickupSlime() -> void:
	if interact_area and interact_area.slimeAmount > 0:
		CURRENT_SLIME_SCALE += interact_area.slimeAmount
		interact_area.queue_free()
		interact_area = null
		can_interact = false
