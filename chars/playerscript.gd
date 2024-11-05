extends CharacterBody2D


const SPEED = 200
const SLOWDOWN = 30
const EPSILON = 1e-6
const SLIDE_MULT = 1.8

var current_top_speed : float = SPEED
var movement_multiplier : float = 1.0

var directionx : float
var directiony : float
var direction : Vector2

var is_asked_to_move : bool = false
var is_moving : bool = false
var is_sliding : bool = false

var tween_slide : Tween

var look_there : Vector2 = Vector2(0, 1)

@onready var anim_tree = $AnimationTree
@onready var cursor = $"../cursor"

func _physics_process(delta: float) -> void:

	directionx = Input.get_axis("LEFT", "RIGHT")
	directiony = Input.get_axis("UP", "DOWN")
	direction = Vector2(directionx, directiony)

	if Input.is_action_just_pressed("SLIDE"):
		if !is_sliding:
			tween_slide = create_tween() 
			tween_slide.tween_callback(func(): movement_multiplier=SLIDE_MULT)
			tween_slide.tween_callback(func(): is_sliding=true)
			tween_slide.tween_callback(func(): is_moving=true)
			tween_slide.tween_property(self, "movement_multiplier", SLIDE_MULT*0.9, 0.5)
			tween_slide.tween_property(self, "movement_multiplier", SLIDE_MULT*0.5, 0.02)
			tween_slide.tween_callback(func(): is_sliding=false)
	
	velocity = speed_calc(direction, velocity, delta, movement_multiplier)
	# avoid diagonal superspeed and set conditions for animations
	if direction.length() > EPSILON:
		is_asked_to_move = true
		current_top_speed = SPEED
		if is_sliding:
			current_top_speed = SPEED * movement_multiplier
		if velocity.length() > current_top_speed:
			velocity = velocity.normalized() * current_top_speed
	else:
		is_asked_to_move = false
		#if !is_sliding:
			#is_asked_to_move = false
			#is_sliding = false
	
	is_moving = velocity.length() > EPSILON
	if is_sliding:
		if !is_asked_to_move:
			look_there = -(cursor.global_position - self.global_position).normalized()
		else:
			look_there = -direction.normalized()
		anim_tree.set("parameters/conditions/is_idle", false)
		anim_tree.set("parameters/conditions/is_moving", false)
		anim_tree.set("parameters/conditions/is_sliding", true)
		pass_look_vector_to_animation(anim_tree, look_there)
	elif is_moving:
		#look_there = -velocity.normalized()
		if !is_asked_to_move:
			look_there = (cursor.global_position - self.global_position).normalized()
		else:
			look_there = -direction.normalized()
		anim_tree.set("parameters/conditions/is_idle", false)
		anim_tree.set("parameters/conditions/is_moving", true)
		anim_tree.set("parameters/conditions/is_sliding", false)
		pass_look_vector_to_animation(anim_tree, look_there)
	else:
		look_there = (cursor.global_position - self.global_position).normalized()
		#if !is_asked_to_move:
			#look_there = (cursor.global_position - self.global_position).normalized()
		#else:
			#look_there = -velocity.normalized()
		anim_tree.set("parameters/conditions/is_moving", false)
		anim_tree.set("parameters/conditions/is_idle", true)
		anim_tree.set("parameters/conditions/is_sliding", false)
		pass_look_vector_to_animation(anim_tree, look_there)
	move_and_slide()

func speed_calc(dir: Vector2, vel_dirred: Vector2, delta: float, mult : float) -> Vector2:
	if dir.length() > EPSILON:
		vel_dirred = dir * SPEED * mult
	else:
		vel_dirred.x = move_toward(vel_dirred.x, 0, SLOWDOWN * delta * 60)
		vel_dirred.y = move_toward(vel_dirred.y, 0, SLOWDOWN * delta * 60)
	vel_dirred *= delta * 60
	return (vel_dirred)

func pass_look_vector_to_animation(at: AnimationTree, dir: Vector2) -> void:
	## idle animation is stupid and inverts up and down.
	at.set("parameters/Idle/blend_position", Vector2(dir.x, -dir.y))
	## walk animation is stupid and inverts left and right.
	at.set("parameters/Walk/blend_position", Vector2(-dir.x, dir.y))
	## slide animation is stupid and inverts left and right.
	at.set("parameters/Slide/blend_position", Vector2(-dir.x, dir.y))
