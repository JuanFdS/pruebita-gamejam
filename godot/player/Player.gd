extends CharacterBody2D

const SPEED = 300.0
const TURN_SPEED = 1.0

var direccion: Vector2 = Vector2.UP

func _physics_process(delta):
	velocity = direccion * SPEED
	
	var target_direccion = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	direccion = direccion.move_toward(target_direccion, delta * TURN_SPEED)
	rotation = direccion.angle() + PI/2

	move_and_slide()

