extends Node

export(int) var max_health = 4 setget set_max_health
var health = max_health setget set_health #สร้าง setget ให้ func ทำงานทุกครั้งที่ var มีการเปลี่ยนแปลง

#func _process(delta):
	#วิธีนี้ไม่ดีเพราะมันจะเช็คทุกวิธีนาที
	#if health <= 0:
	#	emit_signal("no_health") # ส่ง signal

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func set_max_health(value):
	max_health = value
	self.health = min(health,max_health) # health จะมีค่าไม่มีเกิน max_health
	emit_signal("max_health_changed", max_health)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func _ready():
	self.health = max_health
