extends CharacterBody2D

@export var health: int
@export var damage: int
@export var speed: float

@onready var playerAnimation := $AnimationPlayer
@onready var character_sprite := $CharacterSprite
@onready var damage_emitter := $DamageEmitter


var state = State.IDLE
enum State {WALK, IDLE, ATTACK}

func _ready() -> void:
	damage_emitter.area_entered.connect(on_emit_damage.bind())

func _process(delta: float) -> void:
	handle_input()
	handle_movement()
	handle_animation()
	handle_flip()
	move_and_slide()

func handle_input()->void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	if Input.is_action_just_pressed("Attack"):
		state = State.ATTACK

func handle_movement()->void:
	if can_move():
		if velocity.length() == 0:
			state = State.IDLE
		else:
			state = State.WALK
	else:
		velocity = Vector2.ZERO

func handle_animation()->void:
	if state == State.WALK:
		playerAnimation.play('walk')
	elif state == State.IDLE:
		playerAnimation.play('idle')
	elif state == State.ATTACK:
		playerAnimation.play('punch')

func handle_flip()->void:
	if velocity.x > 0:
		character_sprite.flip_h = false
		damage_emitter.scale.y = 1
	elif velocity.x < 0:
		character_sprite.flip_h = true
		damage_emitter.scale.y = -1

func can_attack()->bool:
	return can_move()

func can_move()->bool:
	return state == State.WALK or state == State.IDLE

func on_action_complete()->void:
	state = State.IDLE

func on_emit_damage(damage_receiver: DamageReceiver):
	var direction := Vector2.LEFT
	if damage_receiver.global_position.x > global_position.x:
		direction = Vector2.RIGHT
	damage_receiver.damage_received.emit(damage, direction)
	print(damage_receiver)
