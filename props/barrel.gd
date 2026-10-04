extends StaticBody2D

@onready var damage_receiver := $DamageReceiver 
@onready var sprite := $Sprite2D
@export var knockback_intensity: float = 50

var velocity := Vector2.ZERO
var height : float = 0.0
var height_speed : float = 0
const GRAVITY := 600

enum State {IDLE, DESTROYED}
var state = State.IDLE

func _ready() -> void:
	damage_receiver.damage_received.connect(on_damage_received.bind())

func _process(delta: float) -> void:
	position += velocity * delta
	sprite.position = Vector2.UP * height
	handle_airtime(delta)


func on_damage_received(damage: int, direction: Vector2) -> void:
	if state == State.IDLE:
		sprite.frame = 1
		height_speed = knockback_intensity*2
		state = State.DESTROYED
		velocity = direction * knockback_intensity

func handle_airtime(delta: float)->void:
	if state == State.DESTROYED:
		height += height_speed * delta
		if height <= 0:
			queue_free()
		else:
			height_speed -= GRAVITY * delta
		
