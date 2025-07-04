extends CharacterBody2D

var speed = 100
var player_state = "idle"
var attack_cooldown = 0
var attack_duration = 0.4  # How long attack animations play
var is_attacking = false
var attack_type = ""  # "melee" or "ranged"
var has_shot_arrow = false  # Track whether we've shot an arrow during this attack

@export var inventory: Inventory

func collect(item):
	inventory.insert(item)

func _physics_process(_delta: float) -> void:
	# Update attack cooldown timer
	if attack_cooldown > 0:
		attack_cooldown -= _delta
		if attack_cooldown <= 0:
			is_attacking = false
	
	# Get movement input
	var direction = Input.get_vector("left", "right", "up", "down")
	
	# Handle attack inputs (assumed input actions "attack" for melee and "attack_range" for ranged)
	if Input.is_action_just_pressed("attack") and not is_attacking:
		player_state = "attacking"
		is_attacking = true
		attack_type = "melee"
		attack_cooldown = attack_duration
		# Optional: Disable movement during attack
		# direction = Vector2.ZERO
	
	elif Input.is_action_just_pressed("attack_range") and not is_attacking:
		player_state = "attacking"
		is_attacking = true
		attack_type = "ranged"
		attack_cooldown = attack_duration
		has_shot_arrow = false  # Reset the flag when starting a new attack
		# Optional: Disable movement during attack
		# direction = Vector2.ZERO
	
	# Update player state based on movement
	elif direction.x == 0 and direction.y == 0 and not is_attacking:
		player_state = "idle"
	elif not is_attacking:
		player_state = "walking"
		
	# Apply movement
	velocity = direction * speed
	move_and_slide()
	
	# Update animation
	play_animation(direction)

func play_animation(direction) -> void:
	# Store the last non-zero direction for animations when not moving
	if direction != Vector2.ZERO:
		# Store direction in instance variable to remember it when idle or attacking
		set_meta("last_direction", direction)
	
	# Get the direction to use for animation
	var anim_direction = direction
	if direction == Vector2.ZERO and has_meta("last_direction"):
		anim_direction = get_meta("last_direction")
	
	# Determine animation direction based on the direction vector
	var anim_suffix = ""
	
	# Check for diagonal movement first
	if abs(anim_direction.x) > 0.1 and abs(anim_direction.y) > 0.1:
		# Diagonal movement
		if anim_direction.x > 0: # Right diagonals
			if anim_direction.y > 0:
				anim_suffix = "diagonal_right_down"
			else:
				anim_suffix = "diagonal_right_up"
		else: # Left diagonals
			if anim_direction.y > 0:
				anim_suffix = "diagonal_left_down"
			else:
				anim_suffix = "diagonal_left_up"
	# Check for cardinal directions
	elif abs(anim_direction.x) > abs(anim_direction.y):
		# Horizontal movement is dominant
		anim_suffix = "right" if anim_direction.x > 0 else "left"
	elif abs(anim_direction.y) > 0.1:
		# Vertical movement is dominant
		anim_suffix = "down" if anim_direction.y > 0 else "up"
	else:
		# Default to down direction if no direction is set yet
		anim_suffix = "down"
	
	# Determine the animation prefix based on player state
	var animation = ""
	
	# Handle different player states
	if player_state == "attacking":
		if attack_type == "melee":
			# Sword attack animation
			animation = "attack_sword_" + anim_suffix
		elif attack_type == "ranged":
			# Bow attack animation
			animation = "attack_bow_" + anim_suffix
			# Only shoot once per attack
			if not has_shot_arrow:
				# Add a 50ms delay before shooting
				has_shot_arrow = true
				await get_tree().create_timer(0.3).timeout
				shoot()
	elif player_state == "idle":
		animation = "idle_" + anim_suffix
	elif player_state == "walking":
		animation = "walk_" + anim_suffix
	
	# Play the animation
	$AnimatedSprite2D.play(animation)

@onready var player: CharacterBody2D = $"."
func shoot():
	const BULLET = preload("res://scenes/arrow.tscn")
	var new_bullet = BULLET.instantiate()
	
	# Get the current direction based on animation
	var direction = Vector2.ZERO
	if has_meta("last_direction"):
		direction = get_meta("last_direction")
	else:
		# Default to facing down if no direction stored
		direction = Vector2(0, 1)
	
	# Create a normalized direction vector
	var normalized_dir = direction.normalized()
	
	# Set an offset distance from player center for arrow spawn
	var offset_distance = 20  # Adjust this value based on your character size
	
	# Calculate the offset position based on direction
	var offset_position = normalized_dir * offset_distance
	
	# Set arrow position to be in front of the player
	new_bullet.global_position = player.global_position + offset_position
	
	# Set arrow rotation based on direction
	if abs(direction.x) > abs(direction.y):
		# Mostly horizontal movement
		if direction.x > 0: # Right
			new_bullet.rotation = 0 # 0 radians = right
		else: # Left
			new_bullet.rotation = PI # PI radians = left
	else:
		# Mostly vertical movement
		if direction.y > 0: # Down
			new_bullet.rotation = PI/2 # PI/2 radians = down
		else: # Up
			new_bullet.rotation = -PI/2 # -PI/2 radians = up
	
	# Handle diagonal directions if needed
	if abs(direction.x) > 0.1 and abs(direction.y) > 0.1:
		# Diagonal directions
		if direction.x > 0 and direction.y < 0: # Up-right
			new_bullet.rotation = -PI/4
		elif direction.x > 0 and direction.y > 0: # Down-right
			new_bullet.rotation = PI/4
		elif direction.x < 0 and direction.y < 0: # Up-left
			new_bullet.rotation = -3*PI/4
		elif direction.x < 0 and direction.y > 0: # Down-left
			new_bullet.rotation = 3*PI/4
	
	# Add bullet to the parent scene instead of the player
	get_tree().current_scene.add_child(new_bullet);

func player_check():
	pass
