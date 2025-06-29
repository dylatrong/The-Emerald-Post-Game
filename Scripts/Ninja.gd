extends CharacterBody3D

# --- STATE MACHINE ---
enum State {IDLE, CHASING, STRAFING, ATTACKING}
var current_state = State.IDLE

# --- Movement, Health, & Combat ---
@export var speed = 5.0
@export var health = 5
@export var ninja_star_scene: PackedScene

# --- Node References ---
@onready var state_timer = $StateTimer
@onready var attack_timer = $AttackTimer
@onready var vision_area = $VisionArea
@onready var raycast = $RayCast3D
# --- References for sounds ---
@onready var hit_sound_player = $HitSoundPlayer
@onready var death_sound_player = $DeathSoundPlayer

# --- AI State ---
var player_in_area = false
var player_ref = null
var strafe_direction = 1.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	state_timer.wait_time = randf_range(3.0, 5.0)
	attack_timer.wait_time = randf_range(2.0, 4.0)
	state_timer.start()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	match current_state:
		State.IDLE:
			velocity.x = 0
			velocity.z = 0
			if can_see_player():
				transition_to_state(State.CHASING)
		State.CHASING:
			if not can_see_player():
				transition_to_state(State.IDLE)
				return
			look_at_player()
			var direction = -transform.basis.z
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		State.STRAFING:
			if not can_see_player():
				transition_to_state(State.IDLE)
				return
			look_at_player()
			var direction = transform.basis.x * strafe_direction
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		State.ATTACKING:
			look_at_player()
			velocity.x = 0
			velocity.z = 0

	move_and_slide()

func take_damage(amount: int):
	# Don't do anything if we're already in the process of dying
	if health <= 0:
		return

	health -= amount
	print("Ninja took damage, health is now: ", health)
	
	if health <= 0:
		die()
	else:
		# If not dead, play the "ouch" sound
		hit_sound_player.play()

func die():
	# Stop the AI timers
	state_timer.stop()
	attack_timer.stop()
	
	# Prevent it from taking more damage or blocking things
	collision_layer = 0
	
	# Hide the enemy visually
	$MeshInstance3D.hide()
	$Star.hide()
	
	# Stop the enemy from moving
	velocity = Vector3.ZERO
	
	# Play the death sound and WAIT for it to finish
	death_sound_player.play()
	await death_sound_player.finished
	
	# Now that the sound is done, safely delete the enemy node
	queue_free()

func transition_to_state(new_state):
	if current_state == new_state:
		return
	current_state = new_state
	state_timer.start()
	match new_state:
		State.IDLE:
			attack_timer.stop()
		State.CHASING:
			attack_timer.start()
		State.STRAFING:
			strafe_direction = 1.0 if randf() > 0.5 else -1.0
			attack_timer.start()
		State.ATTACKING:
			attack_timer.stop()
			_on_attack_timer_timeout()

func can_see_player():
	if not player_in_area or not is_instance_valid(player_ref):
		return false
	raycast.target_position = to_local(player_ref.global_transform.origin)
	raycast.force_raycast_update()
	if raycast.is_colliding() and raycast.get_collider() == player_ref:
		return true
	return false

func look_at_player():
	if is_instance_valid(player_ref):
		look_at(Vector3(player_ref.global_transform.origin.x, global_transform.origin.y, player_ref.global_transform.origin.z))

func _on_vision_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = true
		player_ref = body
		if current_state == State.IDLE:
			transition_to_state(State.CHASING)

func _on_vision_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		player_ref = null
		transition_to_state(State.IDLE)

func _on_state_timer_timeout():
	if current_state == State.CHASING or current_state == State.STRAFING:
		if randf() > 0.5:
			transition_to_state(State.CHASING)
		else:
			transition_to_state(State.STRAFING)

func _on_attack_timer_timeout():
	if current_state == State.ATTACKING or not can_see_player():
		return
	var old_state = current_state
	current_state = State.ATTACKING
	if ninja_star_scene:
		var star = ninja_star_scene.instantiate()
		get_tree().get_root().add_child(star)
		star.global_transform = $AttackSpawnPoint.global_transform
	await get_tree().create_timer(0.5).timeout
	current_state = old_state
	attack_timer.start()
