extends KinematicBody2D
signal grabTorch

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _on_Area2D_body_entered(body):
	if body.get_meta("name") == "Player":
		emit_signal("grabTorch")
