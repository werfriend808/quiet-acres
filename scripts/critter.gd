extends Wanderer
class_name Critter

## 순수 장식용 동물(양/닭 등). 게임 시스템에 영향 없이 상호작용하면 짧은 소리만 낸다.
## Wanderer의 IDLE/MOVING 배회 + separation을 그대로 사용해서 제자리 근처를 어슬렁거린다.
## "Visual"이라는 이름의 Sprite2D 자식 노드 덕분에 Interactable의 기본 bob
## 애니메이션도 자동으로 적용된다.

@export var sound_line: String = "..."


func _ready() -> void:
	super._ready()
	add_to_group("npc")


func _process(delta: float) -> void:
	super._process(delta)  # bob 애니메이션 유지
	_process_wander(delta)
	_apply_flocking(delta)
	_apply_separation(delta)


func interact() -> String:
	return sound_line
