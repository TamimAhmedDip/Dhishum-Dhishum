class_name BasicEnemy
extends Character

@export var player: Player
var player_slot: EnemySpace = null

func handle_input()->void:
	if player != null and can_move():

		if player_slot == null:
			player_slot = player.reserve_slot(self)
		
		if player_slot != null:
			var distance_vector := (player_slot.global_position - global_position)
			var direction := distance_vector.normalized()
			if distance_vector.length() < 1:
				velocity = Vector2.ZERO
			else:
				velocity = direction * speed

func on_received_damage(damage_amount:int, direction: Vector2, hit_type: DamageReceiver.HitType):
	super.on_received_damage(damage_amount, direction, hit_type)
	print(str(damage_amount))
	if current_health == 0:
		player.free_slot(self)
		
			
			
