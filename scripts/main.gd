extends Node2D

const GRID_SIZE: int = 5
const TILE_SIZE: int = 48

const FarmPlotScene: PackedScene = preload("res://scenes/FarmPlot.tscn")

@onready var farm_grid: Node2D = $FarmGrid
@onready var info_label: Label = $HUD/InfoLabel


func _ready() -> void:
	_build_farm_grid()
	GameManager.new_day.connect(_on_new_day)


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


func _process(_delta: float) -> void:
	info_label.text = "Day %d   %s\n수확물: %s" % [
		GameManager.day,
		GameManager.get_time_string(),
		GameManager.get_inventory_string()
	]
