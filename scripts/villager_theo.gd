extends VillagerNPC

## 테오 - 마을 대장장이. 무뚝뚝하지만 은근히 챙겨주는 성격.

func _ready() -> void:
	villager_name = "테오"
	dialogue_lines = [
		"...왔나. 별일 없으면 그냥 지나가도 돼.",
		"작물을 잘 키우려면 물 주는 타이밍이 중요하지.",
		"씨앗 값이 비싸다고? 다 이유가 있어서 그런 거야.",
		"가끔은 나도 이 마을이 마음에 들어.",
	]
	super._ready()
