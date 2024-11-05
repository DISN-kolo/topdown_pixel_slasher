extends CharacterBody2D


const SPEED = 200
const SLOWDOWN = 30
const EPSILON = 1e-6
const SLIDE_MULT = 1.8
var directionx
var directiony
var direction

var is_moving : bool = false
var is_sliding : bool = false

@onready var anim_tree = $AnimationTree
@onready var cursor = $"../cursor"

func _physics_process(delta: float) -> void:

	directionx = Input.get_axis("LEFT", "RIGHT")
	directiony = Input.get_axis("UP", "DOWN")
	direction = Vector2(directionx, directiony)
	velocity = speed_calc(direction, velocity)

	# avoid diagonal superspeed
	if direction.length() > EPSILON:
		if velocity.length() > SPEED:
			velocity = velocity.normalized() * SPEED
		is_moving = true
		if Input.is_action_pressed("SLIDE"):
			is_sliding = true
		else:
			is_sliding = false
	else:
		is_moving = false
	
	if is_moving:
		if is_sliding:
			anim_tree.set("parameters/conditions/is_idle", false)
			anim_tree.set("parameters/conditions/is_moving", false)
			anim_tree.set("parameters/conditions/is_sliding", true)
			anim_tree.set("parameters/Slide/blend_position",
				-velocity.normalized())
			velocity *= delta * 60 * SLIDE_MULT
		else:
			anim_tree.set("parameters/conditions/is_idle", false)
			anim_tree.set("parameters/conditions/is_moving", true)
			anim_tree.set("parameters/conditions/is_sliding", false)
			anim_tree.set("parameters/Walk/blend_position",
				-velocity.normalized())
			velocity *= delta * 60
	else:
		anim_tree.set("parameters/conditions/is_moving", false)
		anim_tree.set("parameters/conditions/is_idle", true)
		anim_tree.set("parameters/conditions/is_sliding", false)
		anim_tree.set("parameters/Idle/blend_position",
			(cursor.global_position - self.global_position).normalized())
	move_and_slide()

func speed_calc(dir: Vector2, vel_dirred: Vector2) -> Vector2:
	if dir.length() > EPSILON:
		vel_dirred = dir * SPEED
	else:
		vel_dirred.x = move_toward(vel_dirred.x, 0, SLOWDOWN)
		vel_dirred.y = move_toward(vel_dirred.y, 0, SLOWDOWN)
	return (vel_dirred)
