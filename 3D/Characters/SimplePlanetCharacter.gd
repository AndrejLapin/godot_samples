class_name SimplePlanetCharacter extends RigidBody3D

var jump_initial_impulse: float = 50.0
var move_speed: float = 15.0
var rotation_speed: float = 5.0

#enum state {
	#jumping
#}

var local_gravity: Vector3 = Vector3.ZERO
var _move_direction: Vector3 = Vector3.ZERO
var _last_strong_direction: Vector3 = Vector3.ZERO

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	local_gravity = state.get_total_gravity().normalized()
	
	if _move_direction.length() > 0.2:
		_last_strong_direction = _move_direction.normalized()
	
	_move_direction = _get_model_oriented_input()
	_orient_character_to_direction(_last_strong_direction, state.step)
	
	if is_jumping(state):
		jump()
		apply_central_impulse(-local_gravity * jump_initial_impulse)
	if is_on_floor(state) and not is_falling():
		apply_central_force(_move_direction * move_speed)
	#model.velocity = state.linear_velocity


func _get_model_oriented_input() -> Vector3:
	var raw_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var input := Vector3(raw_input.x, 0, raw_input.y)
	
	#input.x = raw_input.x * sqrt(1.0 - raw_input.y * raw_input.y / 2.0)
	#input.z = raw_input.y * sqrt(1.0 - raw_input.x * raw_input.x / 2.0)
	
	# might break because this is Vector2
	input = transform.basis * input
	return input


func _orient_character_to_direction(direction: Vector3, delta: float) -> void:
	var left_axis := -local_gravity.cross(direction)
	print(direction)
	var rotation_basis := Basis(left_axis, -local_gravity, direction).orthonormalized()
	transform.basis = Basis(transform.basis.get_rotation_quaternion().slerp(rotation_basis, \
						delta * rotation_speed))


func is_jumping(state: PhysicsDirectBodyState3D) -> bool:
	return false


func is_on_floor(state: PhysicsDirectBodyState3D) -> bool:
	for contact in state.get_contact_count():
		var contact_normal = state.get_contact_local_normal(contact)
		if contact_normal.dot(-local_gravity) > 0.5:
			return true
	return false


func is_falling() -> bool:
	return false


func jump() -> void:
	pass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
