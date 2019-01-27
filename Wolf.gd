extends KinematicBody2D

var player = null
var speed = 120
var velocity = Vector2()

func _ready():
	set_physics_process(true)

func _physics_process(delta):
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
	if body.get_meta("name") == "Player":
		player = body

func _on_Area2D_body_exited(body):
	if body.get_meta("name") == "Player":
		player = null
