extends CharacterBody2D

@export var health: int
@export var damage: int
@export var speed: float

@onready var playerAnimation = $AnimationPlayer
@onready var character_sprite = $CharacterSprite


var state
enum State {WALK, IDLE, PUNCH}


func _process(delta: float) -> void:
	handle_input()
	handle_movement()
	handle_animation()
	handle_flip()
	move_and_slide()

func handle_input()->void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	if can_attack() and Input.is_action_just_pressed("Punch"):
		state = State.PUNCH

func handle_movement()->void:
	if velocity.length() != 0:
		state = State.WALK
	else:
		state = State.IDLE

func handle_animation()->void:
	if state == State.WALK:
		playerAnimation.play('walk')
	elif state == State.IDLE:
		playerAnimation.play('idle')
	elif state == State.PUNCH:
		playerAnimation.play('punch')

func handle_flip()->void:
	if velocity.x > 0:
		character_sprite.flip_h = false
	elif velocity.x < 0:
		character_sprite.flip_h = true

func can_attack()->bool:
	return state == State.IDLE or state == State.WALK
