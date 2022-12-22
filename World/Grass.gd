extends Node2D

onready var GrassEffect = preload("res://Effects/GrassEffect.tscn") # load obj

func create_grass_effect():
	var grassEffect = GrassEffect.instance() # create obj
	var world = get_tree().current_scene # get scene ทั้งหมด current scene หมายถึงจุดเริ่มต้น node ทั้งหมดของ scene (World)
	world.add_child(grassEffect) # เพิ่ม obj เข้าไปใน scene
	grassEffect.global_position = global_position # ตัวแรกคือ position grassEffect ตัวสองคือ position grass

func _on_HurtBox_area_entered(area): # ต้องเป็น node area enter area
	create_grass_effect()
	queue_free()
