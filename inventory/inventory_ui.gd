extends Control

var inventory: Inventory
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var is_open = false

func _ready() -> void:
	# Get inventory reference from the player
	var player = get_parent()
	if player and "inventory" in player:
		inventory = player.inventory
		inventory.update.connect(update_slot)
		update_slot()
	else:
		print("ERROR: Could not find player inventory reference")
	close()
	
func update_slot():
	for i in range(min(inventory.slots.size(), slots.size())):
		slots[i].update(inventory.slots[i])
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			close()
		else:
			open()
	
func open():
	visible = true
	is_open = true
	
func close():
	visible = false
	is_open = false
