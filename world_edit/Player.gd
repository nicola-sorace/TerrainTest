extends Spatial

var speed = 2

func _ready():
	set_translation(Vector3(360,70,360))

func _process(delta):
	var dir = Vector3(
		int(Input.is_key_pressed(KEY_D))-int(Input.is_key_pressed(KEY_A)),
		int(Input.is_key_pressed(KEY_R))-int(Input.is_key_pressed(KEY_F)),
		int(Input.is_key_pressed(KEY_S))-int(Input.is_key_pressed(KEY_W))
		)
	
	dir = dir.normalized()
	translate( speed*dir.rotated(Vector3(0,1,0), game.cam.dir) )
