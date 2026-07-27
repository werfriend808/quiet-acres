extends Interactable
class_name FarmPlot

## 농장 타일 하나의 상태 머신
## GRASS(잔디) -> TILLED(갈아엎음) -> PLANTED(씨뿌림) -> WATERED(물줌, 성장중) -> READY(수확가능) -> TILLED ...
## M1: 작물 종류가 여러 개이므로 심는 시점에 GameManager.selected_crop을 저장해두고
## 그 작물의 성장 시간/색상을 CropData에서 조회한다.
## M2: 모든 행동은 스태미나를 소모하며, 상태는 세이브/로드 대상이다.

enum State { GRASS, TILLED, PLANTED, WATERED, READY }

const TOO_TIRED_MESSAGE: String = "너무 지쳤다. 쉬어야겠다."

var state: int = State.GRASS
var grow_timer: float = 0.0
var planted_crop: String = ""

@onready var visual: ColorRect = $Visual


func _ready() -> void:
	add_to_group("farm_plot")
	_update_visual()


func _process(delta: float) -> void:
	if state == State.WATERED:
		grow_timer += delta
		var grow_time: float = CropData.SEEDS.get(planted_crop, {}).get("grow_time", 15.0)
		if grow_timer >= grow_time:
			state = State.READY
			_update_visual()


## 상태에 따라 알맞은 동작을 수행하고 결과 메시지를 반환
func interact() -> String:
	match state:
		State.GRASS:
			if not GameManager.use_stamina(GameManager.STAMINA_COST_TILL):
				return TOO_TIRED_MESSAGE
			state = State.TILLED
			_update_visual()
			return "밭을 갈았다."
		State.TILLED:
			var crop_name: String = GameManager.selected_crop
			if not GameManager.has_seed(crop_name):
				return "%s 씨앗이 없다. 상점에서 구매하자." % crop_name
			if not GameManager.use_stamina(GameManager.STAMINA_COST_PLANT):
				return TOO_TIRED_MESSAGE
			GameManager.plant_seed(crop_name)
			planted_crop = crop_name
			state = State.PLANTED
			_update_visual()
			return "%s 씨앗을 심었다." % crop_name
		State.PLANTED:
			if not GameManager.use_stamina(GameManager.STAMINA_COST_WATER):
				return TOO_TIRED_MESSAGE
			state = State.WATERED
			grow_timer = 0.0
			_update_visual()
			return "물을 주었다."
		State.WATERED:
			return "아직 자라는 중..."
		State.READY:
			if not GameManager.use_stamina(GameManager.STAMINA_COST_HARVEST):
				return TOO_TIRED_MESSAGE
			state = State.TILLED
			grow_timer = 0.0
			GameManager.add_item(planted_crop, 1)
			_update_visual()
			return "%s 수확!" % planted_crop
	return ""


func _update_visual() -> void:
	match state:
		State.GRASS:
			visual.color = Color(0.22, 0.55, 0.2)
		State.TILLED:
			visual.color = Color(0.45, 0.32, 0.16)
		State.PLANTED:
			visual.color = Color(0.5, 0.38, 0.18)
		State.WATERED:
			visual.color = Color(0.32, 0.34, 0.5)
		State.READY:
			var crop_color: Color = CropData.SEEDS.get(planted_crop, {}).get("color", Color(0.9, 0.78, 0.2))
			visual.color = crop_color


## 세이브용 상태 스냅샷
func get_save_state() -> Dictionary:
	return {
		"state": state,
		"planted_crop": planted_crop,
		"grow_timer": grow_timer,
	}


## 저장된 스냅샷으로부터 상태 복원
func load_save_state(data: Dictionary) -> void:
	state = int(data.get("state", State.GRASS))
	planted_crop = String(data.get("planted_crop", ""))
	grow_timer = float(data.get("grow_timer", 0.0))
	_update_visual()
