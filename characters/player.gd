class_name Player
extends Character

@onready var enemy_slots: Array = $EnemySlots.get_children()

func handle_input()->void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	if can_attack() and Input.is_action_just_pressed("Attack"):
		state = State.ATTACK
		if is_last_hit_successful:
			attack_combo_index = (attack_combo_index + 1) % attack_type.size()
			is_last_hit_successful = false
		else:
			attack_combo_index = 0

	if can_jump() and Input.is_action_just_pressed("Jump"):
		state = State.TAKEOFF
	if can_jumpkick() and Input.is_action_just_pressed("Attack"):
		state = State.JUMPKICK
		damage_emitter.monitoring = true

func reserve_slot(enemy: BasicEnemy)->EnemySpace:
	var available_slots := enemy_slots.filter(
		func(enemy_space: EnemySpace): return enemy_space.is_free()
	)
	if available_slots.size() <= 0:
		return null

	available_slots.sort_custom(
		func(a: EnemySpace, b: EnemySpace):
			var dist_a = (enemy.global_position - a.global_position).length()
			var dist_b = (enemy.global_position - b.global_position).length()
			return dist_a < dist_b
	)
	
	available_slots[0].occupant = enemy
	return available_slots[0]

func free_slot(enemy: BasicEnemy)->void:
	var target_slot := enemy_slots.filter(
		func(enemy_space: EnemySpace)->bool: return enemy_space.occupant == enemy
	)
	if target_slot.size() == 1:
		target_slot[0].free_up()
