extends Area2D
class_name HitboxComposition
signal onEnter
@export var health_component: HealthComposition

func take_damage(attack: Attack):
	print("HitboxComposition take_damage", attack)
	if health_component:
		health_component.take_damage(attack)


func _on_area_entered(area: Area2D) -> void:
	print("Something entered:", area.name)
	onEnter.emit(area)
