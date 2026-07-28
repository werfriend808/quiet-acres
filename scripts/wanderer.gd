extends Interactable
class_name Wanderer

## 제자리 근처를 IDLE(가만히 서 있기)/MOVING(느리게 어슬렁) 상태로 왔다갔다하며
## 돌아다니는 공통 로직. PetChomp(플레이어 추적 기능 추가), Critter(순수 배회)가 상속해서 쓴다.
## 같은 Wanderer 계열끼리는 서로 겹치지 않도록 매 프레임 살짝 밀어내는 separation도 제공한다.
## 실제로 매 프레임 이 로직을 돌리려면 하위 클래스의 _process()에서 _process_wander(delta)와
## _apply_separation(delta)를 직접 호출해야 한다 (자동으로 실행되지 않음).
##
## 자연스러움 보정:
## - 목표까지 즉시 최고 속도로 튀어나갔다 뚝 멈추는 대신, 실제 속도(_velocity)가 목표 속도를
##   부드럽게 따라가게(lerp) 해서 가속/감속이 있는 것처럼 보이게 한다.
## - 새 배회 목표는 매번 완전 무작위가 아니라 직전 이동 방향 근처(관성)로 고른다.
## - 좌우로 움직일 때 "Visual" 스프라이트를 좌우 반전해서 이동 방향을 바라보는 것처럼 보이게 한다.

enum WanderPhase { IDLE, MOVING }

@export var wander_move_speed: float = 35.0  # 평소 어슬렁거릴 때 속도 (느긋하게)
@export var wander_radius: float = 55.0      # 대기 중 어슬렁거리는 반경
@export var idle_min_duration: float = 2.0   # 한 자리에 가만히 서 있는 시간(최소)
@export var idle_max_duration: float = 5.0   # 한 자리에 가만히 서 있는 시간(최대)
@export var arrive_epsilon: float = 4.0
@export var acceleration: float = 6.0        # 클수록 목표 속도에 빨리 도달(민첩), 작을수록 느긋하게 가속/감속

## 무리짓기(flocking): 같은 flock_group 문자열을 가진 Wanderer끼리만 서로를 인식해서
## alignment(주변 평균 이동 방향으로 맞춤)+cohesion(주변 평균 위치 쪽으로 약하게 끌림)을 적용한다.
## 빈 문자열("")이면 무리짓기 비활성화(기본값) — 양이 닭을 따라가는 등 이상한 조합을 막기 위해
## "같은 종류"만 서로 반응하게 씬에서 각자 다른 문자열을 지정해야 한다.
@export var flock_group: String = ""
@export var flock_radius: float = 90.0
@export var flock_alignment_weight: float = 18.0
@export var flock_cohesion_weight: float = 10.0

const SEPARATION_RADIUS: float = 40.0
const SEPARATION_STRENGTH: float = 50.0
const FACING_FLIP_THRESHOLD: float = 5.0  # 이 이상 좌우 속도가 있어야 방향을 바꿔서 표시

var _wander_phase: int = WanderPhase.IDLE
var _phase_timer: float = 0.0
var _home_anchor: Vector2 = Vector2.ZERO
var _wander_target: Vector2 = Vector2.ZERO
var _last_direction: Vector2 = Vector2.RIGHT
var _velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	super._ready()  # Interactable의 bob 애니메이션 초기화(Visual 탐색 등)를 이어서 실행
	_home_anchor = global_position
	_phase_timer = randf_range(idle_min_duration, idle_max_duration)


## IDLE(가만히 서 있기)과 MOVING(느리게 어슬렁 이동)을 번갈아 반복한다.
func _process_wander(delta: float) -> void:
	if _wander_phase == WanderPhase.IDLE:
		_decelerate_to_stop(delta)
		_phase_timer -= delta
		if _phase_timer <= 0.0:
			_pick_new_wander_target()
			_wander_phase = WanderPhase.MOVING
		return

	if global_position.distance_to(_wander_target) < arrive_epsilon:
		_wander_phase = WanderPhase.IDLE
		_phase_timer = randf_range(idle_min_duration, idle_max_duration)
		return

	_move_toward(_wander_target, wander_move_speed, 0.0, delta)


## 지금 위치를 새 거점으로 삼고 IDLE 상태부터 다시 시작한다.
## (PetChomp가 플레이어를 쫓아가다가 다시 배회 모드로 돌아올 때 사용)
func _reset_wander_from_here() -> void:
	_home_anchor = global_position
	_wander_phase = WanderPhase.IDLE
	_phase_timer = randf_range(idle_min_duration, idle_max_duration)


## 완전 무작위 지점 대신, 직전에 움직이던 방향 근처(약 ±70도)를 우선해서 고른다.
## 그러면서도 home_anchor에서 wander_radius 밖으로는 못 나가게 안쪽으로 당겨준다.
## 실제 동물이 어슬렁거릴 때 방향을 급격히 바꾸지 않고 이어서 걷는 느낌을 낸다.
func _pick_new_wander_target() -> void:
	var base_angle: float = _last_direction.angle()
	var angle: float = base_angle + randf_range(-1.2, 1.2)
	var step: float = randf_range(wander_radius * 0.4, wander_radius)
	var candidate: Vector2 = global_position + Vector2(cos(angle), sin(angle)) * step

	var from_anchor: Vector2 = candidate - _home_anchor
	if from_anchor.length() > wander_radius:
		candidate = _home_anchor + from_anchor.normalized() * wander_radius

	_wander_target = candidate
	var new_direction: Vector2 = candidate - global_position
	if new_direction.length() > 0.001:
		_last_direction = new_direction.normalized()


## 목표를 향해 이동한다. 실제 속도(_velocity)는 목표 속도를 즉시 따라가지 않고
## acceleration 비율로 부드럽게 수렴해서 가속/감속이 있는 것처럼 보인다.
func _move_toward(target: Vector2, speed: float, stop_dist: float, delta: float) -> void:
	var to_target: Vector2 = target - global_position
	var dist: float = to_target.length()
	var desired: Vector2 = Vector2.ZERO
	if dist > stop_dist:
		desired = to_target.normalized() * speed
	_velocity = _velocity.lerp(desired, clampf(acceleration * delta, 0.0, 1.0))
	global_position += _velocity * delta
	_update_facing()


## 목표 속도를 0으로 두고 관성만으로 서서히 멈춘다 (IDLE 진입 시 사용).
func _decelerate_to_stop(delta: float) -> void:
	_velocity = _velocity.lerp(Vector2.ZERO, clampf(acceleration * delta, 0.0, 1.0))
	global_position += _velocity * delta


## 좌우로 유의미하게 움직이고 있으면 "Visual" 스프라이트를 그쪽으로 반전한다.
func _update_facing() -> void:
	if _visual == null:
		return
	if _velocity.x > FACING_FLIP_THRESHOLD:
		_visual.flip_h = false
	elif _velocity.x < -FACING_FLIP_THRESHOLD:
		_visual.flip_h = true


## 다른 Wanderer(양/닭/chomp 등)와 너무 가까워지면 살짝 밀어내서 겹치지 않게 한다.
func _apply_separation(delta: float) -> void:
	var push: Vector2 = Vector2.ZERO
	for other in get_tree().get_nodes_in_group("npc"):
		if other == self or not (other is Wanderer):
			continue
		var offset: Vector2 = global_position - other.global_position
		var dist: float = offset.length()
		if dist > 0.001 and dist < SEPARATION_RADIUS:
			push += offset.normalized() * ((SEPARATION_RADIUS - dist) / SEPARATION_RADIUS)
	if push.length() > 0.001:
		global_position += push.normalized() * min(SEPARATION_STRENGTH * delta, push.length())


## 같은 flock_group인 주변 개체들과 무리를 이루도록 두 가지 힘을 더한다:
## alignment(주변 평균 이동 방향으로 맞춤) + cohesion(주변 평균 위치 쪽으로 약하게 끌림).
## separation과 달리 "같은 종류"(flock_group 문자열 일치)끼리만 서로 반응한다.
## flock_group이 빈 문자열이면 즉시 리턴(무리짓기 비활성화).
func _apply_flocking(delta: float) -> void:
	if flock_group == "":
		return

	var neighbor_count: int = 0
	var avg_velocity: Vector2 = Vector2.ZERO
	var avg_position: Vector2 = Vector2.ZERO
	for other in get_tree().get_nodes_in_group("npc"):
		if other == self or not (other is Wanderer):
			continue
		if other.flock_group != flock_group:
			continue
		var dist: float = global_position.distance_to(other.global_position)
		if dist > 0.001 and dist < flock_radius:
			avg_velocity += other._velocity
			avg_position += other.global_position
			neighbor_count += 1

	if neighbor_count == 0:
		return

	avg_velocity /= neighbor_count
	avg_position /= neighbor_count

	var steer: Vector2 = Vector2.ZERO
	if avg_velocity.length() > 0.001:
		steer += avg_velocity.normalized() * flock_alignment_weight
	var to_center: Vector2 = avg_position - global_position
	if to_center.length() > 0.001:
		steer += to_center.normalized() * flock_cohesion_weight

	global_position += steer * delta
