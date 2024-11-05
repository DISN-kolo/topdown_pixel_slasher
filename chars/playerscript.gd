extends CharacterBody2D


const SPEED = 200
const SLOWDOWN = 30
const EPSILON = 1e-6
const SLIDE_MULT = 1.8

var current_top_speed : float = SPEED

var directionx : float
var directiony : float
var direction : Vector2

var is_asked_to_move : bool = false
var is_moving : bool = false
var is_sliding : bool = false

@onready var anim_tree = $AnimationTree
@onready var cursor = $"../cursor"

func _physics_process(delta: float) -> void:

	directionx = Input.get_axis("LEFT", "RIGHT")
	directiony = Input.get_axis("UP", "DOWN")
	direction = Vector2(directionx, directiony)
	velocity = speed_calc(direction, velocity, delta)

	# avoid diagonal superspeed and set conditions for animations
	if direction.length() > EPSILON:
		is_asked_to_move = true
		is_sliding = Input.is_action_pressed("SLIDE")
		current_top_speed = SPEED
		if is_sliding:
			current_top_speed = SPEED * SLIDE_MULT
			velocity *= SLIDE_MULT
		if velocity.length() > current_top_speed:
			velocity = velocity.normalized() * current_top_speed
	else:
		is_asked_to_move = false
		is_sliding = false
	
	is_moving = velocity.length() > EPSILON
	
	if is_moving:
		if is_sliding:
			anim_tree.set("parameters/conditions/is_idle", false)
			anim_tree.set("parameters/conditions/is_moving", false)
			anim_tree.set("parameters/conditions/is_sliding", true)
			anim_tree.set("parameters/Slide/blend_position",
				-velocity.normalized())
		else:
			anim_tree.set("parameters/conditions/is_idle", false)
			anim_tree.set("parameters/conditions/is_moving", true)
			anim_tree.set("parameters/conditions/is_sliding", false)
			anim_tree.set("parameters/Walk/blend_position",
				-velocity.normalized())
	else:
		anim_tree.set("parameters/conditions/is_moving", false)
		anim_tree.set("parameters/conditions/is_idle", true)
		anim_tree.set("parameters/conditions/is_sliding", false)
		anim_tree.set("parameters/Idle/blend_position",
			(cursor.global_position - self.global_position).normalized())
	move_and_slide()

func speed_calc(dir: Vector2, vel_dirred: Vector2, delta: float) -> Vector2:
	if dir.length() > EPSILON:
		vel_dirred = dir * SPEED
	else:
		vel_dirred.x = move_toward(vel_dirred.x, 0, SLOWDOWN * delta * 60)
		vel_dirred.y = move_toward(vel_dirred.y, 0, SLOWDOWN * delta * 60)
	vel_dirred *= delta * 60
	return (vel_dirred)
