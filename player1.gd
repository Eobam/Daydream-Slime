extends CharacterBody2D

@onready var animatedSprite = $AnimatedSprite2D
var health = 3
const SPEED_INC = 50.0
const BASE_SPEED = 300.0
var SPEED = BASE_SPEED
const JUMP_VELOCITY = -400.0
var current_level = 0
var levels: Array[PackedScene]
var SLIME_CAPACITY: float
var LOWER_SLIME_CAPACITY: float
var slime_scale_internal: float
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
	
		SPEED = BASE_SPEED + (SLIME_CAPACITY - slime_scale_internal) * SPEED_INC


# Interaction state
var can_interact: bool = false
var interact_area: Area2D = null

var nextSlimeId: int = 0

# PackedScene reference for dropped slime
@export var dropped_slime_scene: PackedScene


func _ready() -> void:
	scale = Vector2(scale[0], scale[1])
	SLIME_CAPACITY = scale.x
	LOWER_SLIME_CAPACITY = scale.x - 2.5
	slime_scale_internal = scale.x

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		animatedSprite.play("jumping", -1)
	

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animatedSprite.play("jumping")

	# Movement
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if direction == -1:
			animatedSprite.play("moving backward")
		elif direction == 1:
			animatedSprite.play("moving forward")
	else:
		if velocity.y == 0:
			animatedSprite.play("moving forward")
			animatedSprite.frame = 2
		velocity.x = 0


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
		
		

#Check Health
func remove_health():
	health -- 1
	
func die():
	var startPos = levels[current_level].get_node("startPos")
	global_position = startPos.global_position
		


	

	# Shrink player
	CURRENT_SLIME_SCALE -= 0.5
	animatedSprite.play("scaling down")

	# Bounce slightly if midair
	if not is_on_floor():
		velocity.y = JUMP_VELOCITY

func pickupSlime() -> void:
	if interact_area and interact_area.slimeAmount > 0:
		CURRENT_SLIME_SCALE += interact_area.slimeAmount / 2
		interact_area.queue_free()
		animatedSprite.play("scaling down", -1)
		interact_area = null
		can_interact = false
        