extends CharacterBody3D

# --- NEW: Health and Shooting ---
signal player_died

@export var laser_bolt_scene: PackedScene
@export var max_health = 10
var current_health: int
var start_position: Vector3

# --- EXISTING: Player movement variables ---
@export var speed = 7.0
@export var jump_strength = 20.0 # Using the Godot 4-adjusted value
@export var sprint_multiplier := 2.5

# --- EXISTING: Jump tolerance features ---
@export var jump_buffer_time := 0.15
@export var coyote_time := 0.15
var jump_buffer_timer := 0.0
var coyote_timer := 0.0

# --- EXISTING: Hover system ---
@export var hover_max_time = 10.0
@export var hover_velocity_threshold = 0.5
var is_hovering = false
var hover_timer = 0.0

# --- EXISTING: Mouse look variables ---
@export var mouse_sensitivity = 0.002 # Radians/pixel

# --- Node references ---
@onready var camera: Camera3D = $Camera3D
@onready var laser_spawn_point: Node3D = $Camera3D/LaserSpawnPoint # Make sure this node exists!
@onready var fire_sound_player = $Camera3D/FireSoundPlayer


var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	# NEW: Initialize health and starting position
	start_position = global_transform.origin
	current_health = max_health
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent):
	# NEW: Shooting logic
	# Use _unhandled_input so it doesn't interfere with other UI
	if event.is_action_pressed("fire"): # Add "fire" to your Input Map
		shoot()

func _input(event: InputEvent):
	# EXISTING: Mouse look logic
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta: float):
	# --- THIS IS YOUR FULL MOVEMENT CODE, NOW RESTORED ---

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Update coyote timer
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	# Update jump buffer timer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta
		
	# Get input direction vector
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Handle sprinting
	var current_speed = speed
	if Input.is_action_pressed("sprint"):
		current_speed *= sprint_multiplier
	
	# Apply horizontal velocity
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.1)
		velocity.z = lerp(velocity.z, 0.0, 0.1)

	# Reset hover state when on the ground
	if is_on_floor():
		is_hovering = false
		hover_timer = 0.0

	# Check for jump (using coyote time and jump buffer)
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = jump_strength
		coyote_timer = 0
		jump_buffer_timer = 0

	# Hovering Logic (only applies when in the air)
	if not is_on_floor():
		if not is_hovering and Input.is_action_pressed("jump") and abs(velocity.y) < hover_velocity_threshold:
			is_hovering = true
			hover_timer = 0.0
		
		if is_hovering:
			velocity.y = 0.0
			hover_timer += delta
			
			if not Input.is_action_pressed("jump") or hover_timer >= hover_max_time:
				is_hovering = false

	# The essential final step for movement
	move_and_slide()

# --- NEW FUNCTIONS FOR HEALTH AND SHOOTING ---

func shoot():
	fire_sound_player.play()
	if not laser_bolt_scene:
		print("ERROR: Laser bolt scene not set on player script.")
		return
		
	var new_laser = laser_bolt_scene.instantiate()
	get_tree().get_root().add_child(new_laser)
	new_laser.global_transform = laser_spawn_point.global_transform

func take_damage(amount: int):
	current_health -= amount
	print("Player took damage! Health is now: ", current_health)
	if current_health <= 0:
		die()

func die():
	print("Player has died!")
	current_health = max_health
	global_transform.origin = start_position
	emit_signal("player_died")
