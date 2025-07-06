extends Area2D
class_name HitboxComposition
signal onEnter
@export var health_component: HealthComposition

func take_damage(attack: Attack):
	if health_component:
		health_component.take_damage(attack)


func _on_area_entered(area: Area2D) -> void:
	onEnter.emit(area)
