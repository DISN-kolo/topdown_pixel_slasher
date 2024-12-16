extends Camera2D

@onready var char = $"../CharacterBody2D"
@onready var curs = $cursor
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	self.global_position = lerp(char.global_position, curs.global_position, 0.1)
	pass
