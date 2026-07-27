extends RefCounted
class_name CropData

## 작물/씨앗 정적 데이터 테이블
## 씨앗 구매가, 작물 판매가, 성장 시간(초), 수확 시 표시 색상을 정의한다.

const SEEDS: Dictionary = {
	"순무": {
		"cost": 10,
		"sell_price": 5,
		"grow_time": 15.0,
		"color": Color(0.9, 0.78, 0.2),
	},
	"감자": {
		"cost": 15,
		"sell_price": 8,
		"grow_time": 25.0,
		"color": Color(0.75, 0.55, 0.3),
	},
	"당근": {
		"cost": 8,
		"sell_price": 4,
		"grow_time": 10.0,
		"color": Color(0.95, 0.5, 0.15),
	},
}
