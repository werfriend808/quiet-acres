extends RefCounted
class_name CropData

## 작물/씨앗 정적 데이터 테이블
## 씨앗 구매가, 작물 판매가, 성장 시간(초), 수확 시 표시 색상, 심을 수 있는 계절을 정의한다.

const SEEDS: Dictionary = {
	"순무": {
		"cost": 10,
		"sell_price": 5,
		"grow_time": 15.0,
		"color": Color(0.9, 0.78, 0.2),
		"seasons": ["봄"],
	},
	"당근": {
		"cost": 8,
		"sell_price": 4,
		"grow_time": 10.0,
		"color": Color(0.95, 0.5, 0.15),
		"seasons": ["봄", "여름"],
	},
	"감자": {
		"cost": 15,
		"sell_price": 8,
		"grow_time": 25.0,
		"color": Color(0.75, 0.55, 0.3),
		"seasons": ["여름", "가을"],
	},
	"배추": {
		"cost": 12,
		"sell_price": 6,
		"grow_time": 20.0,
		"color": Color(0.65, 0.85, 0.55),
		"seasons": ["가을", "겨울"],
	},
}


## crop_name을 season_name 계절에 심을 수 있는지 여부
static func is_in_season(crop_name: String, season_name: String) -> bool:
	var info: Dictionary = SEEDS.get(crop_name, {})
	var seasons: Array = info.get("seasons", [])
	return seasons.has(season_name)
