extends CharacterBody2D

# movement variables
@export var speed = 10
@export var limit = 0.5
var start_position
var end_position
var moving = true

# nodes
@onready var animations = $AnimatedSprite2D
@onready var pause_timer = $walking_pause
@onready var player = get_parent().get_node("Oldman")
@onready var dialogue = $Dialogue
@onready var dialogue_timer = $dialogue_timer

func _ready():
	# this shit is used for moving the oldman back and forth
	start_position = position
	end_position = start_position + Vector2(-5*16,0)
	# used for pausing the oldman
	pause_timer.one_shot = true
	pause_timer.connect("timeout", on_pause_timer_timeout)
	# timer used for hiding dialogue
	dialogue_timer.one_shot = true
	pause_timer.connect("timeout", on_dialogue_timer)

signal oldman_collision

func display_dialogue():
	if Input.is_action_just_pressed("ui_accept"):
		var last_collision = get_last_slide_collision()
		if last_collision:
			var collider = last_collision.get_collider()
			if collider.name == "Player":
				dialogue.show()
				dialogue.play("1")
				dialogue_timer.start(1)

func change_direction():
	var temp_end = end_position
	end_position = start_position
	start_position = temp_end
	moving = false
	pause_timer.start(5)

func update_velocity():
	if moving:
		var move_direction = (end_position - position)
		if move_direction.length() < limit:
			change_direction()
		velocity = move_direction.normalized() * speed
	else:
		velocity = Vector2(0,0)

func update_animation():
	var animation_string = "Idle"
	if velocity.x < 0:
		animation_string = "Left"
	elif velocity.x > 0:
		animation_string = "Right"
	
	animations.play(animation_string)

func on_pause_timer_timeout():
	moving = true

func on_dialogue_timer():
	dialogue.hide()

func _physics_process(delta):
	update_velocity()
	move_and_slide()
	update_animation()
	display_dialogue()
