extends Node

## 전역 게임 상태 관리자 (Autoload 싱글톤)
## 어디서든 GameManager.xxx 로 접근 가능

signal new_day(day_number: int)
signal inventory_changed
signal gold_changed

const DAY_LENGTH_SECONDS: float = 120.0  # 테스트용: 실제 2분 = 인게임 하루 (나중에 조정)

var day: int = 1
var day_progress: float = 0.0  # 0.0 ~ 1.0
var gold: int = 30
var selected_crop: String = "순무"  # 현재 심을 씨앗으로 선택된 작물
var inventory: Dictionary = {
	"순무 씨앗": 2,  # 시작 씨앗 (상점 없이도 바로 농사 시작 가능하도록)
}


func _process(delta: float) -> void:
	day_progress += delta / DAY_LENGTH_SECONDS
	if day_progress >= 1.0:
		day_progress = 0.0
		day += 1
		new_day.emit(day)


func add_item(item_name: String, amount: int = 1) -> void:
	inventory[item_name] = inventory.get(item_name, 0) + amount
	inventory_changed.emit()


func seed_key(crop_name: String) -> String:
	return "%s 씨앗" % crop_name


func has_seed(crop_name: String) -> bool:
	return inventory.get(seed_key(crop_name), 0) > 0


## 씨앗 1개를 소비한다. (심을 때 호출)
func plant_seed(crop_name: String) -> void:
	var key: String = seed_key(crop_name)
	var remaining: int = inventory.get(key, 0) - 1
	if remaining <= 0:
		inventory.erase(key)
	else:
		inventory[key] = remaining
	inventory_changed.emit()


## 상점에서 씨앗을 구매한다. 골드가 부족하면 false 반환.
func buy_seed(crop_name: String) -> bool:
	if not CropData.SEEDS.has(crop_name):
		return false
	var cost: int = CropData.SEEDS[crop_name].cost
	if gold < cost:
		return false
	gold -= cost
	add_item(seed_key(crop_name), 1)
	gold_changed.emit()
	return true


## 보유한 모든 작물(씨앗 제외)을 판매하고 얻은 골드를 반환한다.
func sell_all_crops() -> int:
	var total: int = 0
	for crop_name in CropData.SEEDS.keys():
		var count: int = inventory.get(crop_name, 0)
		if count > 0:
			total += CropData.SEEDS[crop_name].sell_price * count
			inventory.erase(crop_name)
	if total > 0:
		gold += total
		inventory_changed.emit()
		gold_changed.emit()
	return total


func get_time_string() -> String:
	# 하루가 새벽 6시에 시작한다고 가정
	var total_minutes: int = int(day_progress * 24.0 * 60.0)
	var hour: int = (6 + total_minutes / 60) % 24
	var minute: int = total_minutes % 60
	return "%02d:%02d" % [hour, minute]


func get_seed_inventory_string() -> String:
	var parts: Array = []
	for crop_name in CropData.SEEDS.keys():
		var count: int = inventory.get(seed_key(crop_name), 0)
		if count > 0:
			parts.append("%s x%d" % [seed_key(crop_name), count])
	if parts.is_empty():
		return "(없음)"
	return ", ".join(parts)


func get_crop_inventory_string() -> String:
	var parts: Array = []
	for crop_name in CropData.SEEDS.keys():
		var count: int = inventory.get(crop_name, 0)
		if count > 0:
			parts.append("%s x%d" % [crop_name, count])
	if parts.is_empty():
		return "(없음)"
	return ", ".join(parts)
