extends Area3D

@export var speed = 25.0
var damage = 1

func _ready():
	body_entered.connect(_on_body_entered)
	# Self-destruct after 5 seconds
	$Timer.wait_time = 5.0
	$Timer.one_shot = true
	$Timer.timeout.connect(queue_free)
	$Timer.start()

func _physics_process(delta):
	position += -transform.basis.z * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
	
	# Destroy the star if it hits anything that's not an enemy
	if not body.is_in_group("enemies"):
		queue_free()
