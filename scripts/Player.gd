extends CharacterBody2D

# random variables to use
@export var speed = 35
# for picking up flowers
var picked_up = false
var custom_data = null
var ground_type = null
var blocked = false
# init direction variable which will be used to set the animation direction
@onready var direction = "Idle"

# some variables that are holding references to nodes
@onready var animations = $AnimatedSprite2D
@onready var player = self
@onready var tilemap = null

# this is going to get the player's pos then convert it to something the tilemap can work with
func get_player_relative_pos():
	var player_pos = player.position
	var tile_pos = tilemap.local_to_map(player_pos)
	# we then want to add something to the local_pos depending on
	# where she is facing that way we can get the thing in front of her
	if direction == "Idle" or direction == "Down":
		tile_pos.y += 1
	elif direction == "Up":
		tile_pos.y -= 1
	elif direction == "Left":
		tile_pos.x -= 1
	elif direction == "Right":
		tile_pos.x += 1
	
	return tile_pos

# this will check if the tile in front of the player is occupied with something other than grass/dirt
func check_for_flower(cords):
	var data = tilemap.get_cell_tile_data(2, cords)
	# no flower it's free
	if data == null:
		blocked = false
	# it's blocked
	else:
		blocked = true

func check_for_dirt(cords):
	var data = tilemap.get_cell_tile_data(0,cords)
	if data:
		ground_type = data.get_custom_data("Ground_type")

func pick_up():
	# cordinates of what tile the player is facing
	var cords = get_player_relative_pos()
	# this is a data object of all the data associated with that tile's cords
	var data = tilemap.get_cell_tile_data(2, cords)
	if data:
		# get the data for the 
		custom_data = data.get_custom_data("Foliage_type")
		tilemap.set_cell(2, cords, -1)
		await get_tree().create_timer(1.0)
		picked_up = true

func place():
	var cords = get_player_relative_pos()
	# checks flower type to place and whether blocked is false
	check_for_flower(cords)
	check_for_dirt(cords)
	if blocked == false:
		if ground_type == "dirt":
			if custom_data == "flower":
				tilemap.set_cell(2,cords,2,Vector2(0,0))
				picked_up = false
			if custom_data == "bush2":
				tilemap.set_cell(2,cords,1,Vector2(5,11))
				picked_up = false
			if custom_data == "bush1":
				tilemap.set_cell(2,cords,1,Vector2(4,11))
				picked_up = false
			if custom_data == "red":
				tilemap.set_cell(2,cords,1,Vector2(3,11))
				picked_up = false
			if custom_data == "clover":
				tilemap.set_cell(2,cords,1,Vector2(2,11))
				picked_up = false
			if custom_data == "sunflower":
				tilemap.set_cell(2,cords,1,Vector2(1,11))
				picked_up = false

func remove_place():
	if Input.is_action_just_pressed("ui_accept"):
		if picked_up == false:
			pick_up()
		elif picked_up == true:
			place()

func get_input():
	var moveDirection = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity = moveDirection * speed

func animate_player():
	animations.play(direction)
	
	if velocity.length() == 0:
		animations.stop()
		# this makes it so that if the player is walking down
		# and stops it sets the animation to be in idle 
		if direction == "Down": 
			animations.play("Idle")
			
	else:
		if velocity.x < 0: direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif velocity.y < 0: direction = "Up"
		elif velocity.y > 0: direction = "Down"

func _physics_process(delta):
	get_input()
	move_and_slide()
	animate_player()
	remove_place()
