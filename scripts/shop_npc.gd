extends Interactable
class_name ShopNPC

## 상점 NPC. 플레이어가 상호작용하면 ShopUI를 토글한다.

func _ready() -> void:
	add_to_group("npc")


func interact() -> String:
	var shop_ui: ShopUI = get_tree().get_first_node_in_group("shop_ui") as ShopUI
	if shop_ui:
		shop_ui.toggle()
	return "상점을 열었다."
