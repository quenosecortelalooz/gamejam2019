extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var player = null
var speed = 120
var velocity = Vector2()

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	if !player:
		$Sprite.play("idle")
		return
	$Sprite.play("run")
	velocity = (player.position - position).normalized() * speed
	if velocity.x < 0:
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false
	move_and_slide(velocity)
	

func _on_Area2D_body_entered(body):
	print(body.get_meta("name"))
	if body.get_meta("name") == "Player":
		player = body

func _on_Area2D_body_exited(body):
	print(body.get_meta("name"))
	if body.get_meta("name") == "Player":
		player = null
