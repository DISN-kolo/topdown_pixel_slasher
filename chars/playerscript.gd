extends CharacterBody2D


const SPEED = 200
const SLOWDOWN = 30
const EPSILON = 1e-6
var directionx
var directiony

var is_moving : bool

@onready var anim_tree = $AnimationTree
@onready var cursor = $"../cursor"

func _physics_process(delta: float) -> void:

	directionx = Input.get_axis("LEFT", "RIGHT")
	directiony = Input.get_axis("UP", "DOWN")
	velocity.x = speed_calc(directionx, velocity.x)
	velocity.y = speed_calc(directiony, velocity.y)

	# avoid diagonal superspeed
	if directionx > EPSILON or directiony > EPSILON or directionx < -EPSILON or directiony < -EPSILON:
		if velocity.length() > SPEED:
			velocity = velocity.normalized() * SPEED
	
	is_moving = velocity.length() > EPSILON
	
	if is_moving:
		anim_tree.set("parameters/conditions/is_idle", false)
		anim_tree.set("parameters/conditions/is_moving", true)
		anim_tree.set("parameters/Walk/blend_position",
			-velocity.normalized())
	else:
		anim_tree.set("parameters/conditions/is_moving", false)
		anim_tree.set("parameters/conditions/is_idle", true)
		anim_tree.set("parameters/Idle/blend_position",
			(cursor.global_position - self.global_position).normalized())
	move_and_slide()

func speed_calc(dir: float, vel_dirred: float) -> float:
	if -EPSILON > dir or dir > EPSILON:
		vel_dirred = dir * SPEED
	else:
		vel_dirred = move_toward(vel_dirred, 0, SLOWDOWN)
	return (vel_dirred)
