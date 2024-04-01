class_name PlanetPlayer extends RigidBody3D

const JUMP_VELOCITY: float = 5.0
const MOVE_SPEED: float = 25.0
const SENSTIVITY: float = 0.003
const FLOOR_ANGLE_THRESHOLD: float = 0.01
const ROTATION_SPEED: float = 5.0

@export_range(0, 180, 0.001, "radians_as_degrees") var floor_max_angle: float = deg_to_rad(60)

@onready var head: Node3D = $Head

var y_rotate_amount: float = 0.0
var on_the_floor: bool = false

var _gravity_direction: Vector3 = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	axis_lock_angular_y = true
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		var mouse_motion: InputEventMouseMotion = event
		y_rotate_amount += -mouse_motion.relative.x
		head.rotate_x(-mouse_motion.relative.y * SENSTIVITY)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-60), deg_to_rad(60))


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	rotate_object_local(Vector3.UP, y_rotate_amount * SENSTIVITY)
	y_rotate_amount = 0.0
	
	_gravity_direction = state.get_total_gravity().normalized()
	var up_vector = -_gravity_direction
	var forward_vector := up_vector.cross(Vector3.RIGHT)
	print("Up vector: " + str(-_gravity_direction))
	print("Forward vector: " + str(transform.basis.z))
	_orient_character_to_direction(transform.basis.z, state.step)
	
	on_the_floor = false
	for index in state.get_contact_count():
		var localized_collision = state.get_contact_local_normal(index)
		var floor_angle: float = abs(localized_collision.angle_to(-_gravity_direction))
		if floor_angle <= floor_max_angle:
			on_the_floor = true


func _orient_character_to_direction(forward: Vector3, delta: float) -> void:
	var left_axis := -_gravity_direction.cross(forward)
	var rotation_basis := Basis(left_axis, -_gravity_direction, forward).orthonormalized()
	transform.basis = Basis(transform.basis.get_rotation_quaternion().slerp(rotation_basis, \
						delta * ROTATION_SPEED))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") and on_the_floor:
		print(JUMP_VELOCITY * mass * -_gravity_direction)
		apply_central_impulse(JUMP_VELOCITY * mass * -_gravity_direction)
		#linear_velocity.y = JUMP_VELOCITY * -_gravity_direction
	
	if on_the_floor:
		var raw_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var direction = (transform.basis * Vector3(raw_input.x, 0, raw_input.y))
		apply_central_force(direction * mass * MOVE_SPEED)
