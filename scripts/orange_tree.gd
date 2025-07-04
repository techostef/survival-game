extends Node2D

var state = 'no_oranges' #no_oranges, oranges
var player_in_area = false
@onready var spawn_orange_area: Marker2D = $spawn_orange_area

func _ready() -> void:
	if state == 'no_oranges':
		$growth_timer.start()
		
		
		
func _process(delta: float) -> void:
	if state == "no_oranges":
		$AnimatedSprite2D.play("tree_no_orange")

	if state == "oranges":
		$AnimatedSprite2D.play("tree_orange")
		if player_in_area == true:
			const ORANGE = preload("res://scenes/orange.tscn")
			var new_orange = ORANGE.instantiate()
			var is_pick = Input.is_action_just_pressed('pick')
			new_orange.global_position = spawn_orange_area.global_position + Vector2(0, 10)

			if is_pick:
				state = 'no_oranges'
				$growth_timer.start()
				get_tree().current_scene.add_child(new_orange)


func _on_pickable_area_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.has_method("player_check"):
		player_in_area = true


func _on_pickable_area_body_exited(body: Node2D) -> void:
	if body.has_method("player_check"):
		player_in_area = false


func _on_growth_timer_timeout() -> void:
	if state == 'no_oranges':
		state = 'oranges'
