extends Spatial
export var height = 6
export var width = 6
export var camspeed = 0.5



var cells = []



func _ready():
	for x in range(height):
		for y in range(width):
			create_cells(x,y)
			
func _process(delta):
	
	if Input.is_action_pressed("up"):
		$Camera.transform.origin.z+=camspeed
	if Input.is_action_pressed("down"):
		$Camera.transform.origin.z-=camspeed
	if Input.is_action_pressed("left"):
		$Camera.transform.origin.x -=camspeed
	if Input.is_action_pressed("right"):
		$Camera.transform.origin.x +=camspeed
	
func create_cells(x,z):
	var pos = Vector3()
	pos.x = (x + (z * 0.5 - z / 2)) * (variables.INNER_RADIUS * 2)
	pos.y = 0 
	pos.z = z * (variables.OUTER_RADIUS * 1.5)
	print(pos)
	var h = variables.hexTile.instance()
	h.set_label(str(x) + "\n" + str(z))
	h.transform.origin = pos
	add_child(h)

