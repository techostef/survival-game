extends Node
class_name HealthComposition

@export var MAX_HEALTH = 20.0
@export var health: float

func _ready() -> void:
	health = MAX_HEALTH

func take_damage(damage: Attack):
	health -= damage.attack_damage
	print("health", health)
	if health <= 0:
		get_parent().queue_free() 
