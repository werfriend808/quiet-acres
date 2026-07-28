extends RefCounted
class_name CropData

## 작물/씨앗 정적 데이터 테이블
## 씨앗 구매가, 작물 판매가, 성장 시간(초), 수확 시 표시 색상, 심을 수 있는 계절을 정의한다.
##
## M5(에셋): sprite_coord는 Kenney "Tiny Farm" 타일셋(assets/tileset/tilemap_packed.png,
## 16x16 타일, 12열x11행)에서 각 작물과 가장 비슷하게 생긴 칸을 골라 [col, row]로 적어둔 것.
## 정확히 1:1로 대응하는 작물이 없어서(순무/배추는 특히) 최대한 비슷한 걸 골랐다 —
## Godot 에디터에서 직접 보고 다른 칸이 더 낫다 싶으면 이 좌표만 바꾸면 된다.
const SEEDS: Dictionary = {
	"순무": {
		"cost": 10,
		"sell_price": 5,
		"grow_time": 15.0,
		"color": Color(0.9, 0.78, 0.2),
		"seasons": ["봄"],
		"sprite_coord": [7, 5],
	},
	"당근": {
		"cost": 8,
		"sell_price": 4,
		"grow_time": 10.0,
		"color": Color(0.95, 0.5, 0.15),
		"seasons": ["봄", "여름"],
		"sprite_coord": [7, 0],
	},
	"감자": {
		"cost": 15,
		"sell_price": 8,
		"grow_time": 25.0,
		"color": Color(0.75, 0.55, 0.3),
		"seasons": ["여름", "가을"],
		"sprite_coord": [6, 4],
	},
	"배추": {
		"cost": 12,
		"sell_price": 6,
		"grow_time": 20.0,
		"color": Color(0.65, 0.85, 0.55),
		"seasons": ["가을", "겨울"],
		"sprite_coord": [8, 4],
	},
}

# 심은 직후(씨앗) / 물 준 뒤(성장 중) 단계는 작물 종류와 무관하게 공용 스프라이트를 쓴다.
const PLANTED_SPRITE_COORD: Array = [4, 0]
const WATERED_SPRITE_COORD: Array = [4, 2]
const TILLED_SPRITE_COORD: Array = [0, 4]


## crop_name을 season_name 계절에 심을 수 있는지 여부
static func is_in_season(crop_name: String, season_name: String) -> bool:
	var info: Dictionary = SEEDS.get(crop_name, {})
	var seasons: Array = info.get("seasons", [])
	return seasons.has(season_name)
