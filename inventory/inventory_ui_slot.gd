extends Panel

@onready var item_visible: Sprite2D = $CenterContainer/Panel/item_display
@onready var amount_text: Label = $CenterContainer/Panel/Label

var slot: InventorySlot

func _get_drag_data(_at_position: Vector2) -> Variant:
	if !slot or !slot.item:
		return null
	
	# Create preview drag texture
	var drag_preview = TextureRect.new()
	drag_preview.texture = slot.item.texture
	drag_preview.expand = true
	drag_preview.size = Vector2(32, 32)  # Adjust size as needed
	drag_preview.z_index = 50
	print(slot.item.name)
	
	# Create label for item name
	var item_label = Label.new()
	item_label.text = str(slot.amount)
	item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	item_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	item_label.position = Vector2(25, 20)  # Position below the texture
	item_label.z_index = 50
	# Set label font size using LabelSettings
	var label_settings = LabelSettings.new()
	label_settings.font_size = 10
	item_label.label_settings = label_settings
	
	# Position the preview at the center of the cursor
	var control = Control.new()
	control.add_child(drag_preview)
	control.add_child(item_label)
	#drag_preview.position = -0.5 * drag_preview.size
	
	# Set the drag preview
	set_drag_preview(control)
	
	# Return the slot data for the drop target to use
	return slot

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	# Check if data is valid inventory slot
	if !data is InventorySlot:
		return false
	
	# Don't allow dropping on self
	if data == slot:
		return false
	
	# Allow dropping if we have a valid slot
	return true

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is InventorySlot:
		# Handle swapping items between slots
		var temp_item = slot.item
		var temp_amount = slot.amount
		
		# If same item type, stack them
		if slot.item == data.item:
			slot.amount += data.amount
			data.item = null
			data.amount = 0
		else:
			# Otherwise swap items
			slot.item = data.item
			slot.amount = data.amount
			data.item = temp_item
			data.amount = temp_amount
		
		# Find the inventory resource to emit the update signal
		var inventory_ui = owner.get_parent()
		if inventory_ui and "inventory" in inventory_ui:
			# Emit the update signal to refresh all slots
			inventory_ui.inventory.update.emit()


func update(passed_slot: InventorySlot):
	# Store reference to this slot
	slot = passed_slot
	if !slot.item:
		item_visible.visible = false
		amount_text.visible = false
	else:
		item_visible.visible =  true
		item_visible.texture = slot.item.texture
		amount_text.visible = true
		amount_text.text = str(slot.amount)
