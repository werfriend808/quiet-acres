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


## 숫자키/X/ESC/K/L 등 "한 번 눌렀을 때만" 반응해야 하는 입력은 물리 프레임마다
## 반복 실행되는 _physics_process 대신 이벤트 기반 _unhandled_input에서 처리한다.
func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	var shop_ui: ShopUI = get_tree().get_first_node_in_group("shop_ui") as ShopUI
	var shop_open: bool = shop_ui != null and shop_ui.visible

	var seed_names: Array = CropData.SEEDS.keys()
	for i in range(seed_names.size()):
		if event.physical_keycode == KEY_1 + i:
			var crop_name: String = seed_names[i]
			if shop_open:
				if GameManager.buy_seed(crop_name):
					print("%s 씨앗을 구매했다." % crop_name)
				else:
					print("골드가 부족하다.")
			else:
				GameManager.selected_crop = crop_name
				print("선택된 씨앗: %s" % crop_name)
			return

	if shop_open and event.physical_keycode == KEY_X:
		var earned: int = GameManager.sell_all_crops()
		if earned > 0:
			print("작물을 팔아 %d 골드를 벌었다." % earned)
		else:
			print("팔 작물이 없다.")
		return

	if shop_open and event.physical_keycode == KEY_ESCAPE:
		shop_ui.toggle()
		return

	if event.physical_keycode == KEY_K:
		GameManager.save_game()
		print("게임을 저장했다.")
		return

	if event.physical_keycode == KEY_L:
		if GameManager.load_game():
			print("게임을 불러왔다.")
		else:
			print("저장된 게임이 없다.")
		return


func _try_interact() -> void:
	var nearest: Interactable = null
	var nearest_dist: float = INTERACT_RANGE
	var candidates: Array = []
	candidates.append_array(get_tree().get_nodes_in_group("farm_plot"))
	candidates.append_array(get_tree().get_nodes_in_group("npc"))
	for obj in candidates:
		var interactable: Interactable = obj as Interactable
		if interactable == null:
			continue
		var dist: float = global_position.distance_to(interactable.global_position)
		if dist <= nearest_dist:
			nearest_dist = dist
			nearest = interactable
	if nearest:
		var message: String = nearest.interact()
		print(message)
