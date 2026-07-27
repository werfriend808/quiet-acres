extends Node2D
class_name FarmPlot

## 농장 타일 하나의 상태 머신
## GRASS(잔디) -> TILLED(갈아엎음) -> PLANTED(씨뿌림) -> WATERED(물줌, 성장중) -> READY(수확가능) -> TILLED ...

enum State { GRASS, TILLED, PLANTED, WATERED, READY }

const GROW_TIME: float = 15.0  # 물을 준 후 수확까지 걸리는 시간(초) - 테스트용, 나중에 조정
const CROP_NAME: String = "순무"

var state: int = State.GRASS
var grow_timer: float = 0.0

@onready var visual: ColorRect = $Visual


func _ready() -> void:
	add_to_group("farm_plot")
	_update_visual()


func _process(delta: float) -> void:
	if state == State.WATERED:
		grow_timer += delta
		if grow_timer >= GROW_TIME:
			state = State.READY
			_update_visual()


## 상태에 따라 알맞은 동작을 수행하고 결과 메시지를 반환
func interact() -> String:
	match state:
		State.GRASS:
			state = State.TILLED
			_update_visual()
			return "밭을 갈았다."
		State.TILLED:
			state = State.PLANTED
			_update_visual()
			return "씨앗을 심었다."
		State.PLANTED:
			state = State.WATERED
			grow_timer = 0.0
			_update_visual()
			return "물을 주었다."
		State.WATERED:
			return "아직 자라는 중..."
		State.READY:
			state = State.TILLED
			grow_timer = 0.0
			_update_visual()
			GameManager.add_item(CROP_NAME, 1)
			return "%s 수확!" % CROP_NAME
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
			visual.color = Color(0.9, 0.78, 0.2)
