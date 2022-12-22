extends KinematicBody2D

onready var EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

enum{
	IDLE,
	WANDER,
	CHASE
}

var state = IDLE

var knockback = Vector2.ZERO
const KNOCKBACK_RANGE = 120

var velocity = Vector2.ZERO
export var FRICTION = 200
export var ACCELERATION = 300
export var MAX_SPEED = 50
var push_strength = 400

onready var sprite = get_node("AnimetedSprite")
onready var stats = get_node("Stats")
onready var playerDetectionZone = get_node("PlayerDetectionZone")
onready var hurtbox = get_node("Hurtbox")
onready var softCollision = get_node("SoftCollision")
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer

func _ready():
	state = pick_random_state([IDLE,WANDER])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO,FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO,FRICTION * delta)
			seek_player()
			
			if wanderController.get_time_left() == 0:
				update_wander()
		WANDER:
			seek_player()
			
			if wanderController.get_time_left() == 0:
				update_wander()
				
			accelerate_towards_point(wanderController.target_position,delta)
			
			if global_position.distance_to(wanderController.target_position) <= MAX_SPEED * delta: # ทำให้มันไม่ขยับแบบงึกงักๆ
				update_wander()
				
		CHASE:
			var player = playerDetectionZone.player
			if player != null :
				accelerate_towards_point(player.global_position,delta)
			else :
				state = IDLE
			
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * push_strength
	velocity = move_and_slide(velocity)

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED,ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0
		
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func update_wander():
	state = pick_random_state([IDLE,WANDER])
	wanderController.start_wander_timer(rand_range(1,3))

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage #ตรงนี้เราไม่ได้ call function setget ใน stats ก็จริงแต่ GDScripts มันทำการ auto call ให้
	#if(stats.health <= 0): #ตรงนี้ควรใช้ signal เนื่องจากเป็นการส่งสัญญาณระหว่าง node
	#	queue_free()
	
	knockback = area.knockback_vector * KNOCKBACK_RANGE #area คือ node ที่ enter area เข้ามา
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.3)


func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	# ทำงานเหมือนกับ var world = get_tree().current_scene พ่วง world.add_child(grassEffect)
	enemyDeathEffect.global_position = global_position


func _on_Hurtbox_invincibility_started():
	animationPlayer.play("Start")


func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("Stop")
