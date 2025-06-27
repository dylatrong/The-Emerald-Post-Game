extends Node3D

@onready var player: CharacterBody3D = $Player

# Store the original scene files for all enemies to re-instance them on reset
var enemy_scenes: Array = []
var enemy_start_positions: Array = []

func _ready():
	# Connect to the player's death signal
	player.player_died.connect(_on_player_died)

	# Store the initial state of all enemies
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy_scenes.append(enemy.scene_file_path)
		enemy_start_positions.append(enemy.global_transform)


func _on_player_died():
	print("Level manager detected player death. Resetting enemies.")
	
	# Get all current enemies and delete them
	var current_enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in current_enemies:
		enemy.queue_free()
		
	# Re-spawn all enemies in their original positions
	for i in range(enemy_scenes.size()):
		var enemy_scene_path = enemy_scenes[i]
		var enemy_start_transform = enemy_start_positions[i]
		
		if not enemy_scene_path:
			continue
			
		var enemy_scene = load(enemy_scene_path)
		var new_enemy = enemy_scene.instantiate()
		add_child(new_enemy)
		new_enemy.global_transform = enemy_start_transform
