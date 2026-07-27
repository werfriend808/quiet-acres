extends Node2D
class_name Interactable

## 상호작용 가능한 오브젝트의 공통 인터페이스
## FarmPlot, ShopNPC 등이 이를 상속하여 interact()를 오버라이드한다.
## Player는 이 타입으로만 캐스팅해서 다루므로 서로 다른 종류의
## 오브젝트를 하나의 "가장 가까운 상호작용 대상" 탐색 루프로 처리할 수 있다.

func interact() -> String:
	return ""
