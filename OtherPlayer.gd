extends KinematicBody2D
export var speed: int = 150

var target = Vector2(120, 341)
var previous_direction = Vector2(randf() - 0.5, randf() - 0.5)

func set_tint(r, g, b):
	$Sprite.material.set_shader_param("red_factor", r)
	$Sprite.material.set_shader_param("green_factor", g)
	$Sprite.material.set_shader_param("blue_factor", b)


func _physics_process(delta):
	if target == null:
		set_physics_process(false)
		return
	if position.distance_to(target) < 2.0:
		target = null
		return
	var direction = position.direction_to(target)
	# randomize a bit
	direction = (direction + previous_direction) / 2.0
	
	# avoid diagonal movement
	if abs(direction.x) > abs(direction.y):
		direction.y = 0
		if direction.x > 0:
			$AnimationPlayer.play("right")
		else:
			$AnimationPlayer.play("left")
	else:
		direction.x = 0
		if direction.y > 0:
			$AnimationPlayer.play("down")
		else:
			$AnimationPlayer.play("up")
	if direction.x == 0 and direction.y == 0:
		$AnimationPlayer.stop()
	else:
		# try a movement only if there is something to do
		direction = direction.normalized()
		$RayCast2D.cast_to = direction.normalized() * 32
		var movement = speed * direction * delta
		# warning-ignore:return_value_discarded
		if move_and_collide(movement) != null and randf() > 0.999:
			target = null
			$AnimationPlayer.stop()
	previous_direction = direction
		

func set_player_name(other_player_name: String):
	$Label.text = other_player_name
