extends MeshInstance3D

# This function will be connected to the player's health_changed signal.
# It receives the player's new health and their maximum possible health.
func update_health(current_health, max_health):
	# Ensure we don't divide by zero if max_health is somehow 0
	if max_health <= 0:
		return

	# Calculate the health percentage (a value from 0.0 to 1.0)
	var health_percentage = float(current_health) / float(max_health)
	
	# We will change the bar's scale on the X-axis to match the health percentage.
	# When health is full, scale.x = 1.0. When health is half, scale.x = 0.5.
	# We use clamp() to make sure the value never goes below 0.
	#!!!THIS CODE WILL NEED TO BE CHANGED IF WE CHOOSE TO USE 2D HUD!!!
	var new_scale_x = clamp(health_percentage, 0.0, 1.0)
	
	# Apply the new scale, keeping the Y and Z scale the same.
	self.scale.x = new_scale_x
