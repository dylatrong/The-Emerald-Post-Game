extends CharacterBody3D

# --- STATE MACHINE ---
enum State {IDLE, CHASING}
var current_state = State.IDLE

# --- Movement & Health ---
@export var speed = 3.0
@export var health = 5
@export var melee_damage = 1

# --- Node References ---
@onready var vision_area = $VisionArea
@onready var raycast = $RayCast3D
@onready var collision_shape = $CollisionShape3D
@onready var mesh = $MeshInstance3D
# --- NEW: Add reference to attack cooldown timer ---
@onready var attack_cooldown_timer = $AttackCooldownTimer
# Add sound players if they exist in this scene
@onready var hit_sound_player = $HitSoundPlayer if has_node("HitSoundPlayer") else null
@onready var death_sound_player = $DeathSoundPlayer if has_node("DeathSoundPlayer") else null

# --- NEW: Cooldown flag ---
var can_attack = true

var player_in_area = false
var player_ref = null
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	# Connect the timer's timeout signal in the editor
	pass

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	match current_state:
		State.IDLE:
			velocity.x = 0
			velocity.z = 0
			if can_see_player():
				current_state = State.CHASING
		State.CHASING:
			if not can_see_player():
				current_state = State.IDLE
				return
			
			var direction_to_player = (player_ref.global_transform.origin - global_transform.origin).normalized()
			velocity.x = direction_to_player.x * speed
			velocity.z = direction_to_player.z * speed
			look_at(Vector3(player_ref.global_transform.origin.x, global_transform.origin.y, player_ref.global_transform.origin.z))

	move_and_slide()
	
	# --- NEW: Check for melee collision after moving ---
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		# Check if we collided with a body that has a take_damage function and we can attack
		if collision.get_collider().has_method("take_damage") and can_attack:
			# Check if the body is the player
			if collision.get_collider().is_in_group("player"):
				# Deal damage, disable attacking, and start the cooldown
				collision.get_collider().take_damage(melee_damage)
				can_attack = false
				attack_cooldown_timer.start()


# --- THIS SECTION IS NOW COMPLETE ---

func take_damage(amount: int):
	# Don't take damage if already dying
	if health <= 0:
		return

	health -= amount
	print("Melee Enemy took damage, health is now: ", health)
	
	if health <= 0:
		die()
	else:
		# If we have a hit sound player, play the sound
		if hit_sound_player:
			hit_sound_player.play()

func die():
	# Stop moving
	velocity = Vector3.ZERO
	# Disable collision so it doesn't block anything
	collision_shape.disabled = true
	# Hide the mesh
	mesh.hide()
	$Knife.hide()
	
	# If we have a death sound player, play the sound and wait for it to finish
	if death_sound_player:
		death_sound_player.play()
		await death_sound_player.finished
	
	# Safely delete the enemy
	queue_free()


# --- The rest of your functions are correct ---

func can_see_player():
	if not player_in_area or not is_instance_valid(player_ref):
		return false
	raycast.target_position = to_local(player_ref.global_transform.origin)
	raycast.force_raycast_update()
	if raycast.is_colliding() and raycast.get_collider() == player_ref:
		return true
	return false

func _on_vision_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = true
		player_ref = body

func _on_vision_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		player_ref = null
		current_state = State.IDLE

# --- NEW: Function to re-enable attacking after cooldown ---
func _on_attack_cooldown_timer_timeout():
	can_attack = true
