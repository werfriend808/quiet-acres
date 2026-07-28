extends Interactable
class_name FarmPlot

## 농장 타일 하나의 상태 머신
## GRASS(잔디) -> TILLED(갈아엎음) -> PLANTED(씨뿌림) -> WATERED(물줌, 성장중) -> READY(수확가능) -> TILLED ...
## M1: 작물 종류가 여러 개이므로 심는 시점에 GameManager.selected_crop을 저장해두고
## 그 작물의 성장 시간/색상을 CropData에서 조회한다.
## M2: 모든 행동은 스태미나를 소모하며, 상태는 세이브/로드 대상이다.
## M5(폴리싱): WATERED 상태일 때 성장 진행률을 GrowthBar로 보여주고, 행동이 성공할 때마다
## 살짝 커졌다 줄어드는 펄스 트윈으로 손맛을 준다. (FarmPlot은 자체 _process가 있으므로
## Interactable의 bob 애니메이션은 자동으로 적용되지 않는다.)
## M5(에셋): Kenney Tiny Farm 타일셋에서 잘라낸 CropSprite를 Visual(배경색) 위에 겹쳐서
## 보여준다. Visual의 색상은 그대로 유지 — 혹시 스프라이트가 안 보이더라도 상태 구분은 되도록.

enum State { GRASS, TILLED, PLANTED, WATERED, READY }

const TOO_TIRED_MESSAGE: String = "너무 지쳤다. 쉬어야겠다."
const GROWTH_BAR_WIDTH: float = 40.0
const TILE_PX: int = 16

const TILESET_TEXTURE: Texture2D = preload("res://assets/tileset/tilemap_packed.png")

var state: int = State.GRASS
var grow_timer: float = 0.0
var planted_crop: String = ""

@onready var visual: ColorRect = $Visual
@onready var growth_bar: ColorRect = $GrowthBar
@onready var crop_sprite: Sprite2D = $CropSprite

var _atlas_texture: AtlasTexture


func _ready() -> void:
	add_to_group("farm_plot")
	_atlas_texture = AtlasTexture.new()
	_atlas_texture.atlas = TILESET_TEXTURE
	crop_sprite.texture = _atlas_texture
	_update_visual()


func _process(delta: float) -> void:
	if state == State.WATERED:
		grow_timer += delta
		var grow_time: float = CropData.SEEDS.get(planted_crop, {}).get("grow_time", 15.0)
		growth_bar.visible = true
		growth_bar.size.x = GROWTH_BAR_WIDTH * clamp(grow_timer / grow_time, 0.0, 1.0)
		if grow_timer >= grow_time:
			state = State.READY
			_update_visual()
	else:
		growth_bar.visible = false


## 상태에 따라 알맞은 동작을 수행하고 결과 메시지를 반환
func interact() -> String:
	match state:
		State.GRASS:
			if not GameManager.use_stamina(GameManager.STAMINA_COST_TILL):
				return TOO_TIRED_MESSAGE
			state = State.TILLED
			_update_visual()
			_play_action_pulse()
			return "밭을 갈았다."
		State.TILLED:
			var crop_name: String = GameManager.selected_crop
			var season_name: String = GameManager.get_season()
			if not CropData.is_in_season(crop_name, season_name):
				return "%s는 %s에 심을 수 없다." % [crop_name, season_name]
			if not GameManager.has_seed(crop_name):
				return "%s 씨앗이 없다. 상점에서 구매하자." % crop_name
			if not GameManager.use_stamina(GameManager.STAMINA_COST_PLANT):
				return TOO_TIRED_MESSAGE
			GameManager.plant_seed(crop_name)
			planted_crop = crop_name
			state = State.PLANTED
			_update_visual()
			_play_action_pulse()
			return "%s 씨앗을 심었다." % crop_name
		State.PLANTED:
			if not GameManager.use_stamina(GameManager.STAMINA_COST_WATER):
				return TOO_TIRED_MESSAGE
			state = State.WATERED
			grow_timer = 0.0
			_update_visual()
			_play_action_pulse()
			return "물을 주었다."
		State.WATERED:
			return "아직 자라는 중..."
		State.READY:
			if not GameManager.use_stamina(GameManager.STAMINA_COST_HARVEST):
				return TOO_TIRED_MESSAGE
			state = State.TILLED
			grow_timer = 0.0
			GameManager.add_item(planted_crop, 1)
			_update_visual()
			_play_action_pulse()
			return "%s 수확!" % planted_crop
	return ""


func _update_visual() -> void:
	match state:
		State.GRASS:
			visual.color = Color(0.22, 0.55, 0.2)
			crop_sprite.visible = false
		State.TILLED:
			visual.color = Color(0.45, 0.32, 0.16)
			_set_crop_sprite(CropData.TILLED_SPRITE_COORD)
		State.PLANTED:
			visual.color = Color(0.5, 0.38, 0.18)
			_set_crop_sprite(CropData.PLANTED_SPRITE_COORD)
		State.WATERED:
			visual.color = Color(0.32, 0.34, 0.5)
			_set_crop_sprite(CropData.WATERED_SPRITE_COORD)
		State.READY:
			var crop_info: Dictionary = CropData.SEEDS.get(planted_crop, {})
			visual.color = crop_info.get("color", Color(0.9, 0.78, 0.2))
			var coord: Array = crop_info.get("sprite_coord", CropData.WATERED_SPRITE_COORD)
			_set_crop_sprite(coord)


## coord = [col, row] (타일셋 좌표, tilemap_packed.png 기준 16px 단위)에 해당하는
## 영역을 CropSprite에 표시한다.
func _set_crop_sprite(coord: Array) -> void:
	var col: int = coord[0]
	var row: int = coord[1]
	_atlas_texture.region = Rect2(col * TILE_PX, row * TILE_PX, TILE_PX, TILE_PX)
	crop_sprite.visible = true


## 행동이 성공했을 때 타일이 살짝 커졌다 원래 크기로 돌아오는 손맛 연출
func _play_action_pulse() -> void:
	visual.scale = Vector2(1.15, 1.15)
	var tween: Tween = create_tween()
	tween.tween_property(visual, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## 세이브용 상태 스냅샷
func get_save_state() -> Dictionary:
	return {
		"state": state,
		"planted_crop": planted_crop,
		"grow_timer": grow_timer,
	}


## 저장된 스냅샷으로부터 상태 복원
func load_save_state(data: Dictionary) -> void:
	state = int(data.get("state", State.GRASS))
	planted_crop = String(data.get("planted_crop", ""))
	grow_timer = float(data.get("grow_timer", 0.0))
	_update_visual()
