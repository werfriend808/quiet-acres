extends CharacterBody2D

const SPEED: float = 140.0
const INTERACT_RANGE: float = 40.0


func _physics_process(_delta: float) -> void:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	# WASD도 함께 지원 (커스텀 입력맵 없이 동작하도록 물리 키를 직접 확인)
	if Input.is_physical_key_pressed(KEY_D):
		input_vector.x += 1
	if Input.is_physical_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_physical_key_pressed(KEY_S):
		input_vector.y += 1
	if Input.is_physical_key_pressed(KEY_W):
		input_vector.y -= 1

	velocity = input_vector.limit_length(1.0) * SPEED
	move_and_slide()

	if Input.is_action_just_pressed("ui_accept"):
		_try_interact()


func _try_interact() -> void:
	var nearest: FarmPlot = null
	var nearest_dist: float = INTERACT_RANGE
	for plot in get_tree().get_nodes_in_group("farm_plot"):
		var dist: float = global_position.distance_to(plot.global_position)
		if dist <= nearest_dist:
			nearest_dist = dist
			nearest = plot
	if nearest:
		var message: String = nearest.interact()
		print(message)
