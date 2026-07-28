extends VillagerNPC

## 미나 - 농장 근처에 사는 이웃. 농사 관련 팁을 준다.

func _ready() -> void:
	villager_name = "미나"
	dialogue_lines = [
		"어서 와요! 오늘 밭일은 할 만해요?",
		"당근은 금방 자라니까 초보자한테 좋아요.",
		"너무 무리하지 말아요. 스태미나 관리가 중요해요.",
		"가끔은 그냥 마을을 둘러보는 것도 좋죠.",
	]
	super._ready()
