extends CanvasLayer
class_name ShopUI

## 상점 패널. 기본적으로 숨겨져 있다가 ShopNPC.interact()로 열고 닫는다.
## 숫자키로 씨앗 구매, X키로 보유 작물 전체 판매, ESC로 닫기 (입력 처리는 player.gd에서 담당).

@onready var catalog_label: Label = $Panel/CatalogLabel


func _ready() -> void:
	add_to_group("shop_ui")
	visible = false
	GameManager.gold_changed.connect(_refresh)
	GameManager.inventory_changed.connect(_refresh)
	GameManager.season_changed.connect(_refresh)
	_refresh()


func toggle() -> void:
	visible = not visible
	if visible:
		_refresh()


func _refresh() -> void:
	var lines: Array = []
	lines.append("=== 상점 ===")
	lines.append("현재 계절: %s (%d년차)" % [GameManager.get_season(), GameManager.get_year()])
	lines.append("보유 골드: %d" % GameManager.gold)
	lines.append("")
	var seed_names: Array = CropData.SEEDS.keys()
	for i in range(seed_names.size()):
		var crop_name: String = seed_names[i]
		var info: Dictionary = CropData.SEEDS[crop_name]
		var seasons_text: String = ", ".join(info.get("seasons", []))
		lines.append("[%d] %s 씨앗 구매 - %d 골드 (재배: %s)" % [i + 1, crop_name, info.cost, seasons_text])
	lines.append("")
	lines.append("[X] 보유 작물 전부 판매 - %s" % GameManager.get_crop_inventory_string())
	lines.append("[ESC] 닫기")
	catalog_label.text = "\n".join(lines)
