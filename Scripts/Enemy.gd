extends CharacterBody3D

# --- STATE MACHINE ---
enum State {IDLE, CHASING, ATTACKING, DYING}
var current_state = State.IDLE

# --- Movement & Health ---
@export var speed = 6.0
@export var health = 5
@export var melee_damage = 1

# --- Node References ---
@onready var vision_area = $VisionArea
@onready var raycast = $RayCast3D
@onready var collision_shape = $CollisionShape3D
@onready var animation_player = $Melee_Enemy/AnimationPlayer
@onready var attack_cooldown_timer = $AttackCooldownTimer
@onready var hit_sound_player = $HitSoundPlayer if has_node("HitSoundPlayer") else null
@onready var death_sound_player = $DeathSoundPlayer if has_node("DeathSoundPlayer") else null
@onready var model = $Melee_Enemy

# --- Cooldown flag ---
var can_attack = true

var player_in_area = false
var player_ref = null
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	animation_player.play("Idle")


func _physics_process(delta):
	if current_state == State.DYING:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	match current_state:
		State.IDLE:
			animation_player.play("Idle")
			velocity.x = 0
			velocity.z = 0
			if can_see_player():
				current_state = State.CHASING
		State.CHASING:
			animation_player.play("Run")
			
			if not can_see_player():
				current_state = State.IDLE
				return
			
			var direction_to_player = (player_ref.global_transform.origin - global_transform.origin).normalized()
			velocity.x = direction_to_player.x * speed
			velocity.z = direction_to_player.z * speed
			look_at(Vector3(player_ref.global_transform.origin.x, global_transform.origin.y, player_ref.global_transform.origin.z))
		
		State.ATTACKING:
			animation_player.play("Fight")
			velocity = Vector3.ZERO

	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider().has_method("take_damage") and can_attack:
			if collision.get_collider().is_in_group("player"):
				current_state = State.ATTACKING
				collision.get_collider().take_damage(melee_damage)
				can_attack = false
				attack_cooldown_timer.start()


func take_damage(amount: int):
	if current_state == State.DYING:
		return

	health -= amount
	print("Melee Enemy took damage, health is now: ", health)
	
	if health <= 0:
		die()
	else:
		if hit_sound_player:
			hit_sound_player.play()

func die():
	current_state = State.DYING
	
	# --- Current: Logic for when there is NO death animation ---
	# When adding a "Death" animation, uncomment these lines.
	# animation_player.play("Death")
	# await animation_player.animation_finished
	
	velocity = Vector3.ZERO
	collision_shape.disabled = true
	model.hide()
	
	if death_sound_player:
		death_sound_player.play()
		# Wait for the sound to finish before disappearing
		await death_sound_player.finished
	
	queue_free()


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

func _on_attack_cooldown_timer_timeout():
	can_attack = true
	if player_in_area:
		current_state = State.CHASING
	else:
		current_state = State.IDLE
