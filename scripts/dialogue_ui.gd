extends CanvasLayer
class_name DialogueUI

## 대화창. 마을 NPC와 상호작용할 때마다 show_line()으로 이름/대사가 갱신되며,
## ESC로 닫는다 (입력 처리는 player.gd에서 담당).

@onready var name_label: Label = $Panel/NameLabel
@onready var text_label: Label = $Panel/TextLabel


func _ready() -> void:
	add_to_group("dialogue_ui")
	visible = false


func show_line(speaker_name: String, line: String) -> void:
	name_label.text = speaker_name
	text_label.text = line
	visible = true


func close() -> void:
	visible = false
