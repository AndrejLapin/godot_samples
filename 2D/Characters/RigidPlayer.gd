extends RigidBody2D

const JUMP_VELOCITY: float = 1000.0
const MOVE_SPEED: float = 500.0
const FLOOR_ANGLE_THRESHOLD: float = 0.01
const floor_check_distance: float = 0.01
const MAX_ANGLE: float = deg_to_rad(60)

var on_the_floor: bool = false

var _gravity_vector: Vector2 = Vector2.ZERO
var _jump_vector: Vector2 = Vector2.ZERO
var _jump_pressed_frames: int = 0

var _shape: Shape2D = null

@export_range(0, 180, 0.001, "radians_as_degrees") var floor_max_angle: float = deg_to_rad(60)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for shape in get_shape_owners():
		_shape = shape_owner_get_shape(shape, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _floor_check() -> void:
	var space_state = get_world_2d().direct_space_state
	var params :=  PhysicsShapeQueryParameters2D.new()
	params.shape_rid = _shape.get_rid()
	params.transform = transform
	params.motion = floor_check_distance * _gravity_vector
	print(params.motion)
	params.exclude = [self.get_rid()]
	var result = space_state.get_rest_info(params)
	on_the_floor = false
	if result.size() > 0:
		var shape_collision_angle := (-_gravity_vector).angle_to(result.normal)
		on_the_floor = shape_collision_angle <= MAX_ANGLE and \
						shape_collision_angle >= -MAX_ANGLE
	#on_the_floor = result.size() > 0


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	_gravity_vector = state.total_gravity.normalized()
	rotate(-_gravity_vector.angle_to(Vector2(0, 1)) - rotation)
	
	on_the_floor = false
	for index in state.get_contact_count():
		var contact_normal = state.get_contact_local_normal(index)
		var floor_angle: float = abs((-_gravity_vector).angle_to(contact_normal))
		if floor_angle <= floor_max_angle:
			on_the_floor = true
	#_floor_check()
	
	#velocity_to_apply
	
		#linear_velocity += -JUMP_VELOCITY * _gravity_vector


func _physics_process(_delta: float) -> void:
	if on_the_floor and _jump_pressed_frames <= 0:
		var input_dir: Vector2 = Input.get_axis("move_left", "move_right") * \
														_gravity_vector.orthogonal()
		#apply_central_force(3000.0 * input_dir * mass)
		print(_gravity_vector.orthogonal())
		print(_jump_vector)
		linear_velocity = input_dir * MOVE_SPEED + linear_velocity * _jump_vector
		#_jump_vector = Vector2.ZERO
	
	_jump_pressed_frames -= 1
	if Input.is_action_just_pressed("jump") and on_the_floor:
		linear_velocity += -JUMP_VELOCITY * _gravity_vector
		_jump_pressed_frames = 2
		#on_the_floor = false
		#_jump_vector = _gravity_vector
		#apply_central_impulse(-JUMP_VELOCITY * _gravity_vector)
