class_name RigidPlayer extends RigidBody3D

const JUMP_VELOCITY: float = 5.0
const MOVE_SPEED: float = 5.0
const SENSTIVITY: float = 0.003
const FLOOR_ANGLE_THRESHOLD: float = 0.01

@export_range(0, 180, 0.001, "radians_as_degrees") var floor_max_angle: float = deg_to_rad(150)

@onready var head: Node3D = $Head

var y_rotate_amount: float = 0.0
var on_the_floor: bool = false


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
	on_the_floor = false
	for index in state.get_contact_count():
		var localized_collision = state.get_contact_local_position(index) - get_position()
		var floor_angle: float = localized_collision.angle_to(Vector3.UP)
		if floor_angle >= floor_max_angle + FLOOR_ANGLE_THRESHOLD:
			on_the_floor = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	self.rotate_y(y_rotate_amount * SENSTIVITY)
	y_rotate_amount = 0.0
	
	if Input.is_action_just_pressed("jump") and on_the_floor:
		self.apply_central_impulse(JUMP_VELOCITY * mass * Vector3.UP)
		#linear_velocity.y = JUMP_VELOCITY
	
	#if on_the_floor:
		#var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		#if direction:
			#linear_velocity.x = direction.x * MOVE_SPEED
			#linear_velocity.z = direction.z * MOVE_SPEED
		#else:
			#linear_velocity.x = 0.0
			#linear_velocity.z = 0.0
