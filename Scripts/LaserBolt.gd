extends Area3D

@export var speed = 50.0
var damage = 1

func _ready():
	# Connect the body_entered signal to a function
	body_entered.connect(_on_body_entered)
	# Set the timer to delete the bolt after 3 seconds
	$Timer.wait_time = 3.0
	$Timer.one_shot = true
	$Timer.timeout.connect(queue_free) # queue_free deletes the node
	$Timer.start()

func _physics_process(delta):
	# Move the laser forward based on its own Z-axis
	position += -transform.basis.z * speed * delta

func _on_body_entered(body):
	# Check if the body we hit has a "take_damage" function (i.e., it's an enemy)
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# Destroy the laser bolt on impact with anything
	queue_free()
