extends KinematicBody

const LERP_VALUE : float = 0.15

var snap_vector : Vector3 = Vector3.DOWN
var speed : float
var velocity : Vector3 = Vector3.ZERO
var touch_running : bool = false

#@export_group("Movement variables")
export var walk_speed : float = 2.0
export var run_speed : float = 5.0
export var jump_strength : float = 15.0
export var gravity : float = 50.0
export var rotation_sensitivity : float = 0.03

export (NodePath) var joystickLeftPath
onready var joystick_left : VirtualJoystick = get_node(joystickLeftPath)

export (NodePath) var joystickRightPath
onready var joystick_right : VirtualJoystick = get_node(joystickRightPath)

const ANIMATION_BLEND : float = 7.0

onready var player_mesh : Spatial = $Mesh
onready var spring_arm_pivot : Spatial = $SpringArmPivot
onready var animator : AnimationTree = $AnimationTree
onready var spring_arm : SpringArm = $SpringArmPivot/SpringArm
onready var uinode : Control = $UI

func android_check():
	var root_node = get_tree().get_root().get_child(0) # Prototype, root node of main script
	
	var root_android_mode = root_node.android_mode
	
	if root_android_mode: return true
	else: return false

onready var is_android_mode : bool = android_check()

func _ready():
	if not is_android_mode:
		uinode.hide()
		uinode.set_process(false)
		uinode.set_process_input(false)
	OS.low_processor_usage_mode = OS.get_name() != "Android"
		
func _physics_process(delta):
	var move_direction : Vector3 = Vector3.ZERO
	
	if is_android_mode:
		move_direction.x = Input.get_axis("ui_left", "ui_right")
		move_direction.z = Input.get_axis("ui_up", "ui_down")
	else:
		move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		move_direction.z = Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")
	
	move_direction = move_direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	
	velocity.y -= gravity * delta
	
	if joystick_right and joystick_right._pressed and is_android_mode:

		var rotation_speed = joystick_right._output.x * rotation_sensitivity
		spring_arm_pivot.rotate_y(-rotation_speed)

		var vertical_rotation_speed = joystick_right._output.y * rotation_sensitivity
		spring_arm.rotate_x(-vertical_rotation_speed)
	
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)
	
	if Input.is_action_pressed("run") or (touch_running == true):
		speed = run_speed
	else:
		speed = walk_speed
	
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed
	
	if move_direction:
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)
	
	var is_jumping := is_on_floor() and Input.is_action_just_pressed("jump")
	var just_landed := is_on_floor() and snap_vector == Vector3.ZERO
	velocity = move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true)
	
	if is_jumping:
		velocity.y = jump_strength
		snap_vector = Vector3.ZERO
	elif just_landed:
		snap_vector = Vector3.DOWN
	
#	apply_floor_snap()
#	move_and_slide(velocity)
	animate(delta)

func animate(delta):
	if is_on_floor():
		animator.set("parameters/ground_air_transition/current", "0")
#
		if velocity.length() > 0:
			if speed == run_speed:
				animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 1.0, delta * ANIMATION_BLEND))
			else:
				animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 0.0, delta * ANIMATION_BLEND))
		else:
			animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), -1.0, delta * ANIMATION_BLEND))
	else:
		animator.set("parameters/ground_air_transition/current", "1")

func _on_TouchSprint_pressed():
	touch_running = true

func _on_TouchSprint_released():
	touch_running = false
