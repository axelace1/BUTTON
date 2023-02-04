extends KinematicBody



export var health = 400


func _ready():
	pass 


func _process(delta):
	if health <= 0:
		queue_free()
