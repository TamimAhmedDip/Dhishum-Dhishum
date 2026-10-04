class_name BasicEnemy
extends Character

@export var player: Player

func handle_input()->void:
	if player != null:
		var direction := (player.position - position).normalized()
		velocity = direction * speed
