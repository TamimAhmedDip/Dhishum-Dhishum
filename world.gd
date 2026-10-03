extends Node2D

@onready var player := $ActorNodes/Player 
@onready var camera = $Camera

func _process(_delta: float) -> void:
	if player.global_position.x > camera.global_position.x:
		camera.global_position.x = player.global_position.x
