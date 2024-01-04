extends Spatial

#@export_group("FOV")
export var change_fov_on_run : bool
export var normal_fov : float = 75.0
export var run_fov : float = 90.0

const CAMERA_BLEND : float = 0.05

onready var spring_arm : SpringArm = $SpringArm
onready var camera : Camera = $SpringArm/Camera

func android_check():
	var root_node = get_tree().get_root().get_child(0) # Prototype, root node of main script
	
	var root_android_mode = root_node.android_mode
	
	if root_android_mode: return true
	else: return false

onready var is_android_mode : bool = android_check()

func _ready():
	if not is_android_mode:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if not is_android_mode:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * 0.005)
			spring_arm.rotate_x(-event.relative.y * 0.005)
			spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)
		
		if event is InputEventKey and event.is_action_pressed("ui_cancel"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(_delta):
	if change_fov_on_run:
		if owner.is_on_floor():
			if Input.is_action_pressed("run"):
				camera.fov = lerp(camera.fov, run_fov, CAMERA_BLEND)
			else:
				camera.fov = lerp(camera.fov, normal_fov, CAMERA_BLEND)
		else:
			camera.fov = lerp(camera.fov, normal_fov, CAMERA_BLEND)
