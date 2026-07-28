extends Node2D

const GRID_SIZE: int = 5
const TILE_SIZE: int = 48

const FarmPlotScene: PackedScene = preload("res://scenes/FarmPlot.tscn")

const SEASON_BG_COLORS: Dictionary = {
	"봄": Color(0.55, 0.78, 0.45),
	"여름": Color(0.35, 0.65, 0.75),
	"가을": Color(0.75, 0.55, 0.25),
	"겨울": Color(0.8, 0.85, 0.9),
}

@onready var farm_grid: Node2D = $FarmGrid
@onready var info_label: Label = $HUD/InfoLabel
@onready var bg_color: ColorRect = $Background/BgColor


func _ready() -> void:
	_build_farm_grid()
	GameManager.new_day.connect(_on_new_day)
	GameManager.season_changed.connect(_on_season_changed)
	if GameManager.load_game():
		print("저장된 게임을 불러왔다.")
	_update_background()


func _build_farm_grid() -> void:
	var origin: Vector2 = Vector2(
		-float(GRID_SIZE * TILE_SIZE) / 2.0,
		-float(GRID_SIZE * TILE_SIZE) / 2.0
	)
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			var plot: Node2D = FarmPlotScene.instantiate()
			plot.position = origin + Vector2(col * TILE_SIZE, row * TILE_SIZE)
			farm_grid.add_child(plot)


func _on_new_day(day_number: int) -> void:
	print("Day %d 시작" % day_number)


func _on_season_changed(season_name: String) -> void:
	print("%s이(가) 되었다." % season_name)
	_update_background()


func _update_background() -> void:
	var target_color: Color = SEASON_BG_COLORS.get(GameManager.get_season(), Color(0.1, 0.1, 0.1))
	var tween: Tween = create_tween()
	tween.tween_property(bg_color, "color", target_color, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _process(_delta: float) -> void:
	info_label.text = "Day %d   %s (%d년차)   %s   골드 %d   스태미나 %d/%d\n선택된 씨앗: %s\n씨앗: %s\n작물: %s\n[숫자] 씨앗 선택/구매  [E] 상호작용  [K] 저장  [L] 불러오기\n[상점: X 판매, ESC 닫기]  [대화창: ESC 닫기]" % [
		GameManager.day,
		GameManager.get_season(),
		GameManager.get_year(),
		GameManager.get_time_string(),
		GameManager.gold,
		GameManager.stamina,
		GameManager.MAX_STAMINA,
		GameManager.selected_crop,
		GameManager.get_seed_inventory_string(),
		GameManager.get_crop_inventory_string(),
	]
