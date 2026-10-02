extends CharacterBody2D

@export var health: int
@export var damage: int
@export var speed: float

@onready var playerAnimation = $AnimationPlayer
@onready var character_sprite = $CharacterSprite


var state
enum State {WALK, IDLE}


func _process(delta: float) -> void:
	handle_input()
	handle_state()
	handle_animation()
	handle_flip()
	move_and_slide()

func handle_input()->void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed

func handle_state()->void:
	if velocity.length() != 0:
		state = State.WALK
	else:
		state = State.IDLE

func handle_animation()->void:
	if state == State.WALK:
		playerAnimation.play('walk')
	else:
		playerAnimation.play('idle')

func handle_flip()->void:
	if velocity.x > 0:
		character_sprite.flip_h = false
	elif velocity.x < 0:
		character_sprite.flip_h = true
