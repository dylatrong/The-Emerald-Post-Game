extends CharacterBody3D

# --- UPDATED: Health is now 5 ---
@export var health = 5
@export var speed = 3.0

# --- UPDATED: Get references to BOTH audio player nodes ---
@onready var death_sound_player = $DeathSoundPlayer
@onready var hit_sound_player = $HitSoundPlayer

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var start_position: Vector3
var player: CharacterBody3D

func _ready():
	start_position = global_transform.origin
	player = get_tree().get_root().find_child("Player", true, false)

func _physics_process(delta):
	# (All the movement code remains the same)
	if not is_instance_valid(player):
		if not is_on_floor():
			velocity.y -= gravity * delta
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	var direction_to_player = (player.global_transform.origin - global_transform.origin).normalized()
	velocity.x = direction_to_player.x * speed
	velocity.z = direction_to_player.z * speed
	look_at(Vector3(player.global_transform.origin.x, global_transform.origin.y, player.global_transform.origin.z))
	move_and_slide()

# --- UPDATED: take_damage() now plays the "hit" sound ---
func take_damage(amount: int):
	# Don't do anything if we're already in the process of dying
	if health <= 0:
		return

	health -= amount
	print("Enemy took damage, health is now: ", health)
	
	if health <= 0:
		die()
	else:
		# If not dead, play the "ouch" sound
		hit_sound_player.play()

# --- die() function remains mostly the same, just plays the death sound ---
func die():
	# Prevent it from taking more damage or blocking things
	collision_layer = 0
	
	# Hide the enemy visually
	$MeshInstance3D.hide()
	$Knife.hide()
	
	# Stop the enemy from moving
	velocity = Vector3.ZERO
	
	# Play the death sound and WAIT for it to finish
	death_sound_player.play()
	await death_sound_player.finished
	
	# Now that the sound is done, safely delete the enemy node
	queue_free()

func reset():
	pass
