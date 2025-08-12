extends Node2D
@export var PipeScene: PackedScene
var spawn_interval = 1.5
var timer = 0.0
var min_y = -166
var max_y = 166
var game_running = false
@onready var gm = get_parent().get_node("GameManager")

func _process(delta):
	timer += delta
	if timer >= spawn_interval:
		timer = 0
		if game_running == false:
			return
		spawn_pipe()

func _on_game_start():
	game_running = true
func _on_game_over():
	game_running = false

func spawn_pipe():
	var pipe = PipeScene.instantiate()
	var viewport_size = get_viewport_rect().size
	var y_offset = randf_range(min_y, max_y)
	pipe.position = Vector2(viewport_size.x + 100, y_offset)
	add_child(pipe)
	pipe.connect("passed_player", Callable(self, "_on_pipe_passed"))

func _on_pipe_passed():
	gm._on_pipe_passed()
