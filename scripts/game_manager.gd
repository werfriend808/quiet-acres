extends Node

## 전역 게임 상태 관리자 (Autoload 싱글톤)
## 어디서든 GameManager.xxx 로 접근 가능

signal new_day(day_number: int)
signal inventory_changed

const DAY_LENGTH_SECONDS: float = 120.0  # 테스트용: 실제 2분 = 인게임 하루 (나중에 조정)

var day: int = 1
var day_progress: float = 0.0  # 0.0 ~ 1.0
var inventory: Dictionary = {}


func _process(delta: float) -> void:
	day_progress += delta / DAY_LENGTH_SECONDS
	if day_progress >= 1.0:
		day_progress = 0.0
		day += 1
		new_day.emit(day)


func add_item(item_name: String, amount: int = 1) -> void:
	inventory[item_name] = inventory.get(item_name, 0) + amount
	inventory_changed.emit()


func get_time_string() -> String:
	# 하루가 새벽 6시에 시작한다고 가정
	var total_minutes: int = int(day_progress * 24.0 * 60.0)
	var hour: int = (6 + total_minutes / 60) % 24
	var minute: int = total_minutes % 60
	return "%02d:%02d" % [hour, minute]


func get_inventory_string() -> String:
	if inventory.is_empty():
		return "(비어 있음)"
	var parts: Array = []
	for key in inventory.keys():
		parts.append("%s x%d" % [key, inventory[key]])
	return ", ".join(parts)
