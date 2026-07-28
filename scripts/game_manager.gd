extends Node

## 전역 게임 상태 관리자 (Autoload 싱글톤)
## 어디서든 GameManager.xxx 로 접근 가능

signal new_day(day_number: int)
signal inventory_changed
signal gold_changed
signal stamina_changed
signal season_changed(season_name: String)

const DAY_LENGTH_SECONDS: float = 120.0  # 테스트용: 실제 2분 = 인게임 하루 (나중에 조정)
const SAVE_PATH: String = "user://savegame.json"

const MAX_STAMINA: int = 100
const STAMINA_COST_TILL: int = 5
const STAMINA_COST_PLANT: int = 3
const STAMINA_COST_WATER: int = 3
const STAMINA_COST_HARVEST: int = 2

const SEASON_NAMES: Array = ["봄", "여름", "가을", "겨울"]
const SEASON_LENGTH_DAYS: int = 7  # 계절당 인게임 7일 (테스트용, 나중에 조정)

var day: int = 1
var day_progress: float = 0.0  # 0.0 ~ 1.0
var gold: int = 30
var stamina: int = MAX_STAMINA
var selected_crop: String = "순무"  # 현재 심을 씨앗으로 선택된 작물
var inventory: Dictionary = {
	"순무 씨앗": 2,  # 시작 씨앗 (상점 없이도 바로 농사 시작 가능하도록)
}


func _process(delta: float) -> void:
	day_progress += delta / DAY_LENGTH_SECONDS
	if day_progress >= 1.0:
		day_progress = 0.0
		var previous_season: String = get_season()
		day += 1
		stamina = MAX_STAMINA
		stamina_changed.emit()
		new_day.emit(day)
		var current_season: String = get_season()
		if current_season != previous_season:
			season_changed.emit(current_season)
		save_game()  # 하루가 바뀔 때 자동 저장


func get_season() -> String:
	var season_index: int = ((day - 1) / SEASON_LENGTH_DAYS) % SEASON_NAMES.size()
	return SEASON_NAMES[season_index]


func get_year() -> int:
	return 1 + (day - 1) / (SEASON_LENGTH_DAYS * SEASON_NAMES.size())


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


## 스태미나를 소모한다. 부족하면 false를 반환하고 아무 것도 소모하지 않는다.
func use_stamina(cost: int) -> bool:
	if stamina < cost:
		return false
	stamina -= cost
	stamina_changed.emit()
	return true


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


## 현재 게임 상태 + 농장 타일 상태를 JSON으로 user://savegame.json에 저장한다.
func save_game() -> void:
	var plots_data: Array = []
	for plot in get_tree().get_nodes_in_group("farm_plot"):
		plots_data.append(plot.get_save_state())

	var data: Dictionary = {
		"day": day,
		"gold": gold,
		"selected_crop": selected_crop,
		"inventory": inventory,
		"stamina": stamina,
		"farm_plots": plots_data,
	}

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("세이브 파일을 열 수 없다: %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(data))
	file.close()


## 저장된 게임을 불러온다. 성공하면 true, 저장 파일이 없거나 손상됐으면 false.
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var text: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false

	# JSON은 모든 숫자를 float로 파싱하므로 정수형 필드는 명시적으로 캐스팅한다.
	day = int(parsed.get("day", 1))
	gold = int(parsed.get("gold", 30))
	selected_crop = String(parsed.get("selected_crop", "순무"))
	stamina = int(parsed.get("stamina", MAX_STAMINA))
	day_progress = 0.0

	inventory.clear()
	var raw_inventory: Dictionary = parsed.get("inventory", {})
	for key in raw_inventory.keys():
		inventory[key] = int(raw_inventory[key])

	var plots_data: Array = parsed.get("farm_plots", [])
	var plots: Array = get_tree().get_nodes_in_group("farm_plot")
	for i in range(min(plots.size(), plots_data.size())):
		plots[i].load_save_state(plots_data[i])

	inventory_changed.emit()
	gold_changed.emit()
	stamina_changed.emit()
	return true
