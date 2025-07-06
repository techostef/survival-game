extends Area2D

var travelled_distance = 0
const SPEED = 500
const RANGE = 300

func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComposition:
		var attack = Attack.new()
		attack.attack_damage = 12
		var hasTakeDamage = area.has_method("take_damage")
		print("hasTakeDamage", hasTakeDamage)
		area.take_damage(attack)
		queue_free() # Destroy the arrow after it hits a hitbox
