extends Area2D

var gravity_force = 1000.0
var flap_strength = -500.0
var velocity: Vector2 = Vector2.ZERO
var max_fall_speed = 900.0
@onready var gm = get_node("/root/Main/GameManager")
@onready var game_over_ui = get_node("/root/Main/GameOverUI")
@onready var retry_button = get_node("/root/Main/GameOverUI/RetryButton")
@onready var click_to_start_label = get_node("/root/Main/UI/ClickToStartLabel")
@onready var background_music = get_node("/root/Main/Background/Music")
@onready var background_music_toggle = get_node("/root/Main/UI/MusicLabel/MusicToggle")

# List of flap sounds
var flap_sounds: Array[AudioStream] = []

func _ready():
	set_process(true)
	connect("area_entered", _on_area_entered)

	# Load all flap sounds into the list
	flap_sounds = [
		load("res://sounds/flap1.mp3"), # Cheecks Clap
		load("res://sounds/flap2.mp3"), # Mac N Cheese
		load("res://sounds/flap3.mp3")  # Moan
	]
	background_music.play()

func reset_velocity():
	gravity_active = false
	rotation_degrees = 0
	position = Vector2(200, 960)

var gravity_active = false

func start_moving():
	gravity_active = true
	set_process(true)

func _process(delta):
	if gravity_active:
		velocity.y += gravity_force * delta
		if velocity.y > max_fall_speed:
			velocity.y = max_fall_speed
		position += velocity * delta
		rotation = clamp(velocity.y / 800.0, -0.8, 1.0)
		if position.y > 1920 or position.y < 0:
			gm._on_player_died()
			gravity_active = false

func _input(event):
	# TOUCH
	if event is InputEventScreenTouch and event.pressed:
		print("Screen Touch Detected "+str(event.position))
		if background_music_toggle.get_global_rect().has_point(event.position):
				if background_music_toggle.button_pressed == true:
					background_music_toggle.button_pressed = false
					background_music.stop()
				else:
					background_music_toggle.button_pressed = true
					background_music.play()
		else:
			if gravity_active == true:
				flap()
			if gravity_active == false and click_to_start_label.visible == true:
				gm.start_game()
				flap()
			if gravity_active == false and game_over_ui.visible == true:
				if retry_button.get_global_rect().has_point(event.position):
					gm._on_retry_button_pressed()
	# MOUSE (simulate touch)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Mouse Click Detected "+str(event.position))
		if background_music_toggle.get_global_rect().has_point(event.position):
				if background_music_toggle.button_pressed == true:
					background_music_toggle.button_pressed = false
					background_music.stop()
				else:
					background_music_toggle.button_pressed = true
					background_music.play()
		else:
			if gravity_active == true:
				flap()
			if gravity_active == false and click_to_start_label.visible == true:
				gm.start_game()
				flap()
			if gravity_active == false and game_over_ui.visible == true:
				if retry_button.get_global_rect().has_point(event.position):
					gm._on_retry_button_pressed()
	# CONTROLLER (A button)
	elif event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_A:
			print("Controller A Button Detected")
			if gravity_active == false and click_to_start_label.visible == true:
				gm.start_game()
				flap()
			if gravity_active == true:
				flap()
			# Only retry if game over (controller can't "click" coordinates)
			if gravity_active == false and game_over_ui.visible == true:
				gm._on_retry_button_pressed()
		if event.button_index == JOY_BUTTON_X:
			if background_music_toggle.button_pressed == true:
				background_music_toggle.button_pressed = false
				background_music.stop()
			else:
				background_music_toggle.button_pressed = true
				background_music.play()

func flap():
	velocity.y = flap_strength

	# Play a random flap sound
	if flap_sounds.size() > 0:
		var random_sound = flap_sounds[randi() % flap_sounds.size()]
		$FlapSound.stream = random_sound
		$FlapSound.play()

func _on_area_entered(_area):
	gm._on_player_died()
	gravity_active = false
