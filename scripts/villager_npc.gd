extends Interactable
class_name VillagerNPC

## 마을 NPC 공통 로직.
## 하위 클래스가 _ready()에서 villager_name / dialogue_lines를 채우고 super._ready()를 호출한다.
## 상호작용할 때마다 대사를 순서대로 하나씩 보여주고, 끝까지 가면 처음으로 돌아간다.

var villager_name: String = "이름 없음"
var dialogue_lines: Array = []

var _line_index: int = 0


func _ready() -> void:
	super._ready()
	add_to_group("npc")


func interact() -> String:
	if dialogue_lines.is_empty():
		return ""
	var dialogue_ui: DialogueUI = get_tree().get_first_node_in_group("dialogue_ui") as DialogueUI
	var line: String = dialogue_lines[_line_index]
	_line_index = (_line_index + 1) % dialogue_lines.size()
	if dialogue_ui:
		dialogue_ui.show_line(villager_name, line)
	return ""
