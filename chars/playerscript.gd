extends CharacterBody2D


const SPEED = 200
const SLOWDOWN = 30
const EPSILON = 1e-6
var directionx
var directiony


func _physics_process(delta: float) -> void:

	directionx = Input.get_axis("LEFT", "RIGHT")
	directiony = Input.get_axis("UP", "DOWN")
	velocity.x = speed_calc(directionx, velocity.x)
	velocity.y = speed_calc(directiony, velocity.y)

	# avoid diagonal superspeed
	if directionx > EPSILON or directiony > EPSILON or directionx < -EPSILON or directiony < -EPSILON:
		if velocity.length() > SPEED:
			velocity = velocity.normalized() * SPEED

	move_and_slide()

func speed_calc(dir: float, vel_dirred: float) -> float:
	if -EPSILON > dir or dir > EPSILON:
		vel_dirred = dir * SPEED
	else:
		vel_dirred = move_toward(vel_dirred, 0, SLOWDOWN)
	return (vel_dirred)
