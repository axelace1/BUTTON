extends KinematicBody

var speed
export var default_speed = 7
export var sprint_speed = 16
export var slide_speed = 20
export var crouch_speed = 20
export var acceleration = 20
export var gravity = 9.8
export var jump = 6
export var jumps_available = 2

export var damage = 100

export var default_height = 1.5
export var crouch_height = 0.5

var mouse_sensitivity = 0.05

var direction = Vector3()
var velocity = Vector3()
var fall = Vector3()

onready var head = $head
onready var pcap = $CollisionShape 
onready var bonker = $Headbonker
onready var aimcast = $head/Camera/Aimcast
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	speed = default_speed
	var head_bonked = false
	
	
	
	if is_on_floor():
		jumps_available = 2
	
	direction = Vector3()
	
	if bonker.is_colliding():
		head_bonked = true
	
	if head_bonked:
		fall.y = -2
	
	if not is_on_floor():
		fall.y -= gravity * delta
	
	if Input.is_action_pressed("crouch"):
		pcap.shape.height -= crouch_speed * delta
		speed = slide_speed
	elif not head_bonked:
		pcap.shape.height += crouch_speed * delta
	pcap.shape.height = clamp(pcap.shape.height, crouch_height, default_height)
	
	if Input.is_action_just_pressed("fire_1"):
		if aimcast.is_colliding():
			var target = aimcast.get_collider()
			if target.is_in_group("Enemy"):
				print("hit enemy")
				target.health -= damage
	
	
	if Input.is_action_just_pressed("jump") and jumps_available > 0:
		fall.y = jump
		jumps_available = jumps_available - 1
	
	if Input.is_action_pressed("ability"):
		speed = sprint_speed
	
	
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	
	
	if Input.is_action_pressed("move_forward"):
		
		direction -= transform.basis.z
	elif Input.is_action_pressed("move_backward"):
			direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		
		direction -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
			direction += transform.basis.x
	
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	velocity = move_and_slide(velocity, Vector3.UP)
	
	
	
	
	
	move_and_slide(fall, Vector3.UP)
