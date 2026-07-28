extends Node2D
class_name Interactable

## 상호작용 가능한 오브젝트의 공통 인터페이스
## FarmPlot, ShopNPC, VillagerNPC 등이 이를 상속하여 interact()를 오버라이드한다.
## Player는 이 타입으로만 캐스팅해서 다루므로 서로 다른 종류의
## 오브젝트를 하나의 "가장 가까운 상호작용 대상" 탐색 루프로 처리할 수 있다.
##
## M5: NPC류에 적용되는 은은한 대기 애니메이션(bob)도 여기서 기본 제공한다.
## "Visual"이라는 이름의 자식 노드가 있으면 자동으로 위아래로 살짝 흔들린다.
## FarmPlot처럼 자체 _process가 필요한 하위 클래스는 _process를 오버라이드하면
## 이 애니메이션이 자동으로 꺼진다. ShopNPC/VillagerNPC처럼 자체 _ready가 있는
## 하위 클래스는 super._ready()를 호출해야 bob 애니메이션이 활성화된다.

@export var bob_enabled: bool = true
@export var bob_amplitude: float = 3.0
@export var bob_speed: float = 2.0

var _bob_time: float = 0.0
var _base_visual_y: float = 0.0
# "Visual" 자식 노드는 프로젝트 안에서 ColorRect(Control 계열)일 수도, Sprite2D(Node2D 계열)일
# 수도 있어서 타입을 고정하지 않는다 (둘 다 .position 프로퍼티는 갖고 있어서 동적으로 동작함).
var _visual = null


func _ready() -> void:
	if not bob_enabled:
		return
	_visual = get_node_or_null("Visual")
	if _visual:
		_base_visual_y = _visual.position.y
		# 전부 0에서 동시에 시작하면 같은 프레임에 태어난 캐릭터들이 똑같이 박자를
		# 맞춰 흔들리는 것처럼 보인다. 위상을 무작위로 어긋나게 해서 개별성을 준다.
		_bob_time = randf_range(0.0, TAU)


func _process(delta: float) -> void:
	if not bob_enabled or _visual == null:
		return
	_bob_time += delta
	_visual.position.y = _base_visual_y + sin(_bob_time * bob_speed) * bob_amplitude


func interact() -> String:
	return ""
