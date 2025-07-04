extends StaticBody2D

var player_in_area = false
@export var item: InventoryItem
var player = null

func _physics_process(delta: float) -> void:
	var is_picked = player_in_area and Input.is_action_just_pressed("pick")
	if is_picked:
		player.collect(item)
		queue_free()


func _on_pickable_area_body_entered(body: Node2D) -> void:
	player_in_area = true
	if body.has_method("player_check"):
		player = body
