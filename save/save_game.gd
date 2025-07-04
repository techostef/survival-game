extends Resource

class_name SaveGame

const SAVE_GAME_PATH = 'user://savegame.tres'

# Store inventory data as serializable properties
@export var inventory_slots: Array = []
@export var inventory_item_names: Array = []
@export var inventory_item_amounts: Array = []
@export var inventory_item_textures: Array = []

# Save the current game state to file
static func save_game(player_inventory: Inventory) -> void:
	var save = SaveGame.new()
	
	# Store inventory data in serializable format
	for slot in player_inventory.slots:
		if slot.item:
			save.inventory_item_names.append(slot.item.name)
			save.inventory_item_amounts.append(slot.amount)
			save.inventory_item_textures.append(slot.item.texture.resource_path)
		else:
			# Empty slot
			save.inventory_item_names.append("")
			save.inventory_item_amounts.append(0)
			save.inventory_item_textures.append("")
	
	# Debug information
	print("Saving inventory with " + str(player_inventory.slots.size()) + " slots")
	print("Items saved: " + str(save.inventory_item_names))
	print("Amounts saved: " + str(save.inventory_item_amounts))
	
	# Save to file
	var error = ResourceSaver.save(save, SAVE_GAME_PATH)
	if error != OK:
		print("An error occurred while saving the game: ", error)
	else:
		print("Game saved successfully!")

# Load a saved game from file
static func load_game() -> SaveGame:
	if ResourceLoader.exists(SAVE_GAME_PATH):
		var save = ResourceLoader.load(SAVE_GAME_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
		if save is SaveGame:
			print("Game loaded successfully!")
			return save
		else:
			print("Error: Save file is not a SaveGame resource")
	else:
		print("No save file found")
	
	return null

# Apply saved inventory data to the given inventory
static func apply_to_inventory(target_inventory: Inventory) -> bool:
	var save = load_game()
	if not save:
		return false
	
	# Debug
	print("Loaded save file with items: " + str(save.inventory_item_names))
	print("Amounts: " + str(save.inventory_item_amounts))
	
	# Check if we have saved inventory data
	if save.inventory_item_names.size() > 0:
		# Clear the current inventory
		for slot in target_inventory.slots:
			slot.item = null
			slot.amount = 0
		
		# Restore inventory data
		for i in range(min(target_inventory.slots.size(), save.inventory_item_names.size())):
			if save.inventory_item_names[i] != "" and save.inventory_item_amounts[i] > 0:
				# Find or create item
				var item_name = save.inventory_item_names[i]
				var item_amount = save.inventory_item_amounts[i]
				var texture_path = save.inventory_item_textures[i]
				
				# Try to load the item resource
				var item = null
				
				# Check for common item resources first
				if item_name == "apple":
					item = load("res://inventory/items/apple_resource.tres")
				elif item_name == "orange":
					item = load("res://inventory/items/orange_resource.tres")
				else:
					# Try to load by texture path
					var texture = load(texture_path)
					if texture:
						# Create a new inventory item
						item = InventoryItem.new()
						item.name = item_name
						item.texture = texture
				
				if item:
					target_inventory.slots[i].item = item
					target_inventory.slots[i].amount = item_amount
					print("Restored item: " + item_name + " x" + str(item_amount) + " to slot " + str(i))
		
		# Signal that inventory was updated
		target_inventory.update.emit()
		return true
	
	return false
