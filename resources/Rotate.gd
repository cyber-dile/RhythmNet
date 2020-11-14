extends Sprite

export var speed = 360

func _process(dt):
	rotation = rotation + speed * dt * PI/180
