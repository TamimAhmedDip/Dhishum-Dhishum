class_name Character
extends CharacterBody2D

@export var max_health: int
@export var damage: int
@export var speed: float
@export var jump_intensity: float
@export var knockback_intensity: float 

@onready var playerAnimation := $AnimationPlayer
@onready var character_sprite := $CharacterSprite
@onready var damage_emitter := $DamageEmitter
@onready var damage_receiver: DamageReceiver = $DamageReceiver


var state = State.IDLE
enum State {WALK, IDLE, ATTACK, TAKEOFF, JUMP, LAND, JUMPKICK, HURT}

var anim_map :={
	State.WALK : 'walk',
	State.IDLE : 'idle',
	State.ATTACK : 'punch',
	State.TAKEOFF : 'takeoff',
	State.JUMP : 'jump',
	State.LAND : 'landing',
	State.JUMPKICK: 'jump_kick',
	State.HURT: 'hurt',
}

var current_health: float
var height: float = 0
var height_speed: float = 0
var GRAVITY: float = 600

func _ready() -> void:
	damage_emitter.area_entered.connect(on_emit_damage.bind())
	damage_receiver.damage_received.connect(on_received_damage.bind())
	current_health = max_health
	

func _process(delta: float) -> void:
	handle_input()
	handle_movement()
	handle_airtime(delta)
	handle_animation()
	handle_flip()
	move_and_slide()

func handle_input()->void:
	pass

func handle_movement()->void:
	if can_move():
		if velocity.length() == 0:
			state = State.IDLE
		else:
			state = State.WALK

func handle_animation()->void:
	if playerAnimation.has_animation(anim_map[state]) and playerAnimation.current_animation != anim_map[state]:
		playerAnimation.play(anim_map[state])

func handle_flip()->void:
	if velocity.x > 0:
		character_sprite.flip_h = false
		damage_emitter.scale.x = 1
	elif velocity.x < 0:
		character_sprite.flip_h = true
		damage_emitter.scale.x = -1

func can_attack()->bool:
	return can_move()

func can_move()->bool:
	return state == State.WALK or state == State.IDLE

func can_jump()->bool:
	return state == State.WALK or state == State.IDLE

func can_jumpkick()->bool:
	return state == State.JUMP


#Action Complete - State Change Functions
func on_action_complete()->void:
	state = State.IDLE

func on_takeoff_complete()->void:
	state = State.JUMP
	height_speed = jump_intensity

func on_land_complete()->void:
	state = State.IDLE

func on_received_damage(damage:int, direction: Vector2)->void:
	if current_health <= 0:
		queue_free()
	else:
		state = State.HURT
		current_health -= damage
		velocity = direction * knockback_intensity

func on_emit_damage(damage_receiver: DamageReceiver):
	var direction := Vector2.LEFT
	if damage_receiver.global_position.x > global_position.x:
		direction = Vector2.RIGHT
	damage_receiver.damage_received.emit(damage, direction)
	print(damage_receiver)
	

func handle_airtime(delta: float)->void:
	if state == State.JUMP or state == State.JUMPKICK:
		character_sprite.position = Vector2.UP * height
		height += height_speed * delta
		if height <= 0:
			character_sprite.position.y = 0
			state = State.LAND
			print(character_sprite.position.y)
		else: 
			height_speed -= GRAVITY*delta
