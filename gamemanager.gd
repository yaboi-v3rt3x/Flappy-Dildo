extends Node

@onready var player = get_parent().get_node("Player")
@onready var pipes_node = get_parent().get_node("Pipes")
@onready var game_over_ui = get_parent().get_node("GameOverUI")
@onready var ui = get_parent().get_node("UI")
@onready var score_label = ui.get_node("ScoreLabel")
@onready var high_score_label = ui.get_node("HighScoreLabel")
@onready var click_to_start_label = ui.get_node("ClickToStartLabel")
@onready var retry_button = game_over_ui.get_node("RetryButton")

var score = 0
var high_score = 0
var game_running = false
var game_started = false
var player_lost = false
var save_path = "user://highscore.save"

func _ready():
	start()

func load_high_score():
	var save = FileAccess.open("user://save_data.dat", FileAccess.READ)
	if save:
		high_score = save.get_var()
		save.close()
		print("Loaded High Score")

func save_high_score():
	var save = FileAccess.open("user://save_data.dat", FileAccess.WRITE)
	save.store_var(high_score)
	save.close()
	print("Saved High Score")

func update_high_score_label():
	high_score_label.text = "High Score: " + str(high_score)

func start():
	randomize()
	game_over_ui.visible = false
	click_to_start_label.visible = true
	game_running = false
	game_started = false
	score = 0
	score_label.text = "Score: 0"
	load_high_score()
	update_high_score_label()
	player.reset_velocity()
	for pipe in pipes_node.get_children():
		pipes_node.remove_child(pipe)

func _on_pipe_passed():
	if game_running == true:
		score += 1
		score_label.text = "Score: " + str(score)
		if high_score < score:
			high_score = score
			update_high_score_label()
			save_high_score()

func start_game():
	game_started = true
	game_running = true
	player.start_moving()
	pipes_node._on_game_start()
	click_to_start_label.visible = false

func _on_player_died():
	player_lost = true
	game_running = false
	game_started = false
	game_over_ui.visible = true
	for pipe in pipes_node.get_children():
		pipe.set_process(false)
	set_process(false)
	if player_lost:
		pipes_node._on_game_over()
		player_lost = false

func _on_retry_button_pressed():
	print("Retry Button Clicked")
	set_process(true)
	start()
