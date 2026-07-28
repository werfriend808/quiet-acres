extends Interactable
class_name PetChomp

## 농장 마스코트 "chomp". 게임 시스템에 영향을 주지 않는 순수 플레이버 캐릭터.
## Interactable의 기본 bob 애니메이션이 "Visual" 자식 노드를 자동으로 흔들어줘서
## 별도 애니메이션 코드 없이도 살아있는 느낌을 준다.

const LINES: Array = [
	"chomp가 반갑다는 듯 몸을 흔든다.",
	"chomp가 발밑을 졸졸 따라다닌다.",
	"chomp가 하품을 한다.",
]

var _line_index: int = 0


func _ready() -> void:
	super._ready()
	add_to_group("npc")


func interact() -> String:
	var line: String = LINES[_line_index]
	_line_index = (_line_index + 1) % LINES.size()
	return line
