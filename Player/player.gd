extends KinematicBody2D

const PLAYER_HURT_SOUND = preload("res://Player/PlayerHurtSound.tscn")

const ACCELERATION = 500
const MAX_SPEED = 80
const ROLL_SPEED = 125
const FRICTION = 500

var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN

var stats = PlayerStats

enum{
	MOVE,
	ROLL,
	ATTACK
}
var state = MOVE

onready var animationPlayer = get_node("AnimationPlayer")
onready var animationTree = get_node("AnimationTree")
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = get_node("HitboxPivot/SwordHitbox")
onready var hurtbox = get_node("Hurtbox")
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _ready():
	randomize() #เอา random seed ตัวใหม่ทำให้ทุกครั้งที่รันเกมการสุ่มจะไม่เหมือนเดิม
	stats.connect("no_health",self,"queue_free")
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector

func _physics_process(delta):
	match state :
		MOVE:
			move_state(delta)
		ROLL :
			roll_state()
		ATTACK :
			attack_state()

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized() # ทำให้ด้านทแยงมุมความเร็วเท่าด้านปกติ
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		#velocity += input_vetor * ACCELERATION * delta
		#velocity = velocity.clamped(MAX_SPEED * delta)
	else :
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO,FRICTION * delta) # ขยับไปทิษทางนั้นต่อค่อยหยุด
	
	move()
	# * delta ทำให้การเคลื่อนไหวเชื่อมโยงกับเวลาบนโลกจริง (60 frame per sec blabla)
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		
	if Input.is_action_just_pressed("roll"):
		state = ROLL
		
func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()
	
func attack_state():
	animationState.travel("Attack")
	
func move():
	velocity = move_and_slide(velocity)
	
func roll_animation_finished():
	velocity = velocity * 0.8
	state = MOVE
	
func attack_animation_finished():
	state = MOVE


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()
	var playerHurtSound = PLAYER_HURT_SOUND.instance()
	get_tree().current_scene.add_child(playerHurtSound)


func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
