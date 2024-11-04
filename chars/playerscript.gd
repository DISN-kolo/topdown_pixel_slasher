extends CharacterBody2D


const SPEED = 200
const SLOWDOWN = 30


func _physics_process(delta: float) -> void:

	var directionx := Input.get_axis("LEFT", "RIGHT")
	if directionx:
		velocity.x = directionx * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SLOWDOWN)
		
	var directiony := Input.get_axis("UP", "DOWN")
	if directiony:
		velocity.y = directiony * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SLOWDOWN)
	
	if directionx or directiony:
		velocity = velocity.normalized() * SPEED

	move_and_slide()
