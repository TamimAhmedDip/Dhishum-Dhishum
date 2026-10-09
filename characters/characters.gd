class_name Character
extends CharacterBody2D

@export var max_health: int
@export var damage: int
@export var damage_power: int
@export var duration_grounded: float
@export var speed: float
@export var jump_intensity: float
@export var knockback_intensity: float 
@export var knockdown_intensity: float
@export var can_respawn: bool
@export var flight_speed: float

@onready var playerAnimation := $AnimationPlayer
@onready var character_sprite := $CharacterSprite
@onready var damage_emitter := $DamageEmitter
@onready var collateral_damage_emitter: Area2D = $CollateralDamageEmitter
@onready var damage_receiver: DamageReceiver = $DamageReceiver
@onready var collision_shape:= $CollisionShape2D


var state = State.IDLE
enum State {WALK, IDLE, ATTACK, TAKEOFF, JUMP, LAND, JUMPKICK, HURT, FALL, GROUNDED, DEATH, FLY}
var attack_type :=  ['punch', 'punch_alt', 'kick', 'round_kick']
var attack_combo_index := 0
var is_last_hit_successful := false

var anim_map :={
	State.WALK : 'walk',
	State.IDLE : 'idle',
	State.ATTACK : 'punch',
	State.TAKEOFF : 'takeoff',
	State.JUMP : 'jump',
	State.LAND : 'landing',
	State.JUMPKICK: 'jump_kick',
	State.HURT: 'hurt',
	State.FALL: 'fall',
	State.GROUNDED: 'grounded',
	State.DEATH: 'grounded',
	State.FLY: 'fly',
}

var current_health: float
var height: float = 0
var height_speed: float = 0
var GRAVITY: float = 600
var time_since_grounded := Time.get_ticks_msec()

func _ready() -> void:
	damage_emitter.area_entered.connect(on_emit_damage.bind())
	damage_receiver.damage_received.connect(on_received_damage.bind())
	collateral_damage_emitter.area_entered.connect(on_emit_collateral_damage.bind())
	collateral_damage_emitter.body_entered.connect(on_wall_hit.bind())
	current_health = max_health
	

func _process(delta: float) -> void:
	handle_input()
	handle_movement()
	handle_airtime(delta)
	handle_animation()
	handle_grounded()
	handle_flip()
	move_and_slide()
	collateral_damage_emitter.monitoring = state == State.FLY
	collision_shape.disabled = is_collision_disabled()
	handle_death(delta)

func handle_input()->void:
	pass

func handle_movement()->void:
	if can_move():
		if velocity.length() == 0:
			state = State.IDLE
		else:
			state = State.WALK

func handle_animation()->void:
	if state == State.ATTACK:
		playerAnimation.play(attack_type[attack_combo_index])
	elif playerAnimation.has_animation(anim_map[state]) and playerAnimation.current_animation != anim_map[state]:
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

func on_received_damage(damage_amount:int, direction: Vector2, hit_type: DamageReceiver.HitType)->void:
	if can_get_hurt():
		current_health = clamp(current_health - damage_amount, 0, max_health)
		if current_health <= 0 or hit_type == DamageReceiver.HitType.KNOCDOWN:
			state = State.FALL
			height_speed = knockdown_intensity
			velocity = direction * knockback_intensity
		elif hit_type == DamageReceiver.HitType.POWER:
			state = State.FLY
			velocity = direction * flight_speed
		else:
			state = State.HURT
			velocity = direction * knockback_intensity


func on_emit_damage(receiver: DamageReceiver):
	is_last_hit_successful = true
	var current_damage := damage
	if not [State.ATTACK, State.JUMPKICK].has(state):
		return
	var hit_type = DamageReceiver.HitType.NORMAL
	var direction := Vector2.LEFT
	if receiver.global_position.x > global_position.x:
		direction = Vector2.RIGHT
	if state == State.JUMPKICK:
		hit_type = DamageReceiver.HitType.KNOCDOWN
	if attack_combo_index == attack_type.size()-1:
		hit_type = DamageReceiver.HitType.POWER
		current_damage = damage_power
	receiver.damage_received.emit(current_damage, direction, hit_type)	

func on_emit_collateral_damage(receiver: DamageReceiver)->void:
	var direction := Vector2.LEFT
	if receiver.global_position.x > global_position.x:
		direction = Vector2.RIGHT
	if receiver != damage_receiver:
		receiver.damage_received.emit(0, direction, DamageReceiver.HitType.KNOCDOWN)

		

func handle_airtime(delta: float)->void:
	if [State.JUMP, State.JUMPKICK, State.FALL].has(state):
		character_sprite.position = Vector2.UP * height
		height += height_speed * delta
		if height <= 0:
			character_sprite.position.y = 0
			if state == State.FALL:
				state = State.GROUNDED
				time_since_grounded = Time.get_ticks_msec()
			else:
				state = State.LAND
			damage_emitter.monitoring = false
			velocity = Vector2.ZERO
		else: 
			height_speed -= GRAVITY*delta

func handle_grounded()->void:
	if state == State.GROUNDED:
		if current_health == 0:
			state = State.DEATH
		elif Time.get_ticks_msec() - time_since_grounded > duration_grounded:
			state = State.LAND

func handle_death(delta)->void:
	if state == State.DEATH:
		modulate.a -= delta
	if modulate.a == 0:
		queue_free()
		
func is_collision_disabled()->bool:
	return [State.GROUNDED, State.DEATH, State.FLY].has(state)

func can_get_hurt()->bool:
	return [State.WALK, State.IDLE, State.TAKEOFF, State.JUMP, State.LAND].has(state)

func on_wall_hit(wall: AnimatableBody2D)->void:
	state = State.FALL
	height_speed = knockback_intensity
	velocity = -velocity/2.0
	print('Yo')
