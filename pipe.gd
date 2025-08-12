extends Node2D

signal passed_player

var has_passed = false
@export var speed = 500

func _process(delta):
	position.x -= speed * delta

	# Check if pipe passed player (only once)
	if !has_passed and position.x < get_node("/root/Main/Player").position.x:
		has_passed = true
		emit_signal("passed_player")
		speed = speed + 5

	# Remove pipe if it goes off screen left
	if position.x < -200:
		queue_free()
