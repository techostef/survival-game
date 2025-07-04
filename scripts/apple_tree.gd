extends Node2D

var state = 'no_apples' #no_apples, apples
var player_in_area = false
@onready var spawn_apple_area: Marker2D = $spawn_apple_area

func _ready() -> void:
	if state == 'no_apples':
		$growth_timer.start()
		
		
		
func _process(delta: float) -> void:
	if state == "no_apples":
		$AnimatedSprite2D.play("tree_no_apple")

	if state == "apples":
		$AnimatedSprite2D.play("tree_apple")
		if player_in_area == true:
			const APPLE = preload("res://scenes/apple.tscn")
			var new_apple = APPLE.instantiate()
			var is_pick = Input.is_action_just_pressed('pick')
			new_apple.global_position = spawn_apple_area.global_position + Vector2(0, 10)

			if is_pick:
				state = 'no_apples'
				$growth_timer.start()
				get_tree().current_scene.add_child(new_apple)


func _on_pickable_area_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.has_method("player_check"):
		player_in_area = true


func _on_pickable_area_body_exited(body: Node2D) -> void:
	if body.has_method("player_check"):
		player_in_area = false


func _on_growth_timer_timeout() -> void:
	if state == 'no_apples':
		state = 'apples'
