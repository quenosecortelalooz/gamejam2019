extends KinematicBody2D

export var id = 0
export var speed = 250

var velocity = Vector2()

func _input(event):
	if event.is_action_pressed('scroll_up'):
		$Camera2D.zoom = $Camera2D.zoom - Vector2(0.1, 0.1)
	if event.is_action_pressed('scroll_down'):
		$Camera2D.zoom = $Camera2D.zoom + Vector2(0.1, 0.1)

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed('ui_right'):
		velocity.x += 1
		$Sprite.flip_h = false
	if Input.is_action_pressed('ui_left'):
		velocity.x -= 1
		$Sprite.flip_h = true
	if Input.is_action_pressed('ui_up'):
		velocity.y -= 1
	if Input.is_action_pressed('ui_down'):
		velocity.y += 1
	if Input.is_action_pressed('ui_down') or Input.is_action_pressed('ui_up') or Input.is_action_pressed('ui_left') or Input.is_action_pressed('ui_right'):
		$Sprite.play("run")
	else:
		$Sprite.play("idle")
	velocity = velocity.normalized() * speed

func _physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity)


func _on_Main_gameOver():
	pass
	# print('gameOver')
