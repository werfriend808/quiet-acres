extends Wanderer
class_name PetChomp

## 농장 마스코트 "chomp". 게임 시스템에 영향을 주지 않는 순수 플레이버 캐릭터.
## Interactable의 기본 bob 애니메이션이 "Visual" 자식 노드를 자동으로 흔들어줘서
## 별도 애니메이션 코드 없이도 살아있는 느낌을 준다.
##
## 상태: WANDER(Wanderer의 IDLE/MOVING 배회를 그대로 사용) / FOLLOW(플레이어가
## follow_distance보다 멀어지면 쫓아가고 settle_distance까지 가까워지면 다시 WANDER).

enum State { WANDER, FOLLOW }

const LINES: Array = [
	"chomp가 반갑다는 듯 몸을 흔든다.",
	"chomp가 발밑을 졸졸 따라다닌다.",
	"chomp가 하품을 한다.",
]

@export var follow_speed: float = 130.0      # 플레이어를 쫓아갈 때 속도
@export var follow_distance: float = 170.0   # 이보다 플레이어와 멀어지면 쫓아간다
@export var settle_distance: float = 70.0    # 쫓아갈 때 플레이어로부터 이 거리까지만 접근

var _player: Node2D = null
var _state: int = State.WANDER
var _line_index: int = 0


func _ready() -> void:
	super._ready()
	add_to_group("npc")
	_player = get_tree().get_first_node_in_group("player")


func _process(delta: float) -> void:
	super._process(delta)  # Interactable의 bob 애니메이션은 그대로 유지

	if _player == null:
		_player = get_tree().get_first_node_in_group("player")
		return

	var dist_to_player: float = global_position.distance_to(_player.global_position)

	if _state == State.WANDER and dist_to_player > follow_distance:
		_state = State.FOLLOW
	elif _state == State.FOLLOW and dist_to_player <= settle_distance:
		_state = State.WANDER
		_reset_wander_from_here()

	if _state == State.FOLLOW:
		_move_toward(_player.global_position, follow_speed, settle_distance, delta)
	else:
		_process_wander(delta)
		_apply_flocking(delta)  # 플레이어를 쫓아갈 땐 무리 신경 안 쓰고, 어슬렁거릴 때만 서로 뭉침

	_apply_separation(delta)


func interact() -> String:
	var line: String = LINES[_line_index]
	_line_index = (_line_index + 1) % LINES.size()
	return line
