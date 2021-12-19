extends Spatial
export var height = 6
export var width = 6
export var camspeed = 0.5
var cast_result


var cells = []

var colors = [Color(0,1,0),Color(0,0,1),Color(1,0,0)]
var color = colors[0]
func _init():
	var i = 0
	for y in range(height):
		for x in range(width):
			
			create_cells(x,y,i)
			i+=1

func _input(event):
	if event.is_action_pressed("left_mouse"):
		mouse_click()

func mouse_click():
	var ray_length = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_node("Camera")
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space_state = get_world().get_direct_space_state()
	# use global coordinates, not local to node
	cast_result = space_state.intersect_ray( from, to )
	if cast_result:
		var coord_position = cast_result.position
		
		var coords=  HexChords.to_hex_coords(coord_position)
		var index = coords.x + coords.z * width + coords.z / 2
		print(cells[index].name)
		cells[index].cell_color = color
		cells[index].generate_geometery()
		print(coords)

func _process(delta):
	
	if Input.is_action_pressed("up"):
		$Camera.transform.origin.z+=camspeed
	if Input.is_action_pressed("down"):
		$Camera.transform.origin.z-=camspeed
	if Input.is_action_pressed("left"):
		$Camera.transform.origin.x -=camspeed
	if Input.is_action_pressed("right"):
		$Camera.transform.origin.x +=camspeed
	
func create_cells(x,z,index):
	var pos = Vector3()
	pos.x = (x + (z * 0.5 - z / 2)) * (variables.INNER_RADIUS * 2)
	pos.y = 0 
	pos.z = z * (variables.OUTER_RADIUS * 1.5)
	
	var hexcell = variables.hexTile.instance()
	hexcell.chords = HexChords.new(x,z)
	hexcell.chords = hexcell.chords.to_offset_Coordinates(x,z)
	hexcell.set_label(" ")
	hexcell.transform.origin = pos
	if x > 0:
		hexcell.set_neighbor(variables.direction.W, cells[ index -1 ])
	if z > 0: 
		if (z & 1)== 0:
			hexcell.set_neighbor(variables.direction.SE, cells[index - width])
			if x > 0:
				hexcell.set_neighbor(variables.direction.SW, cells[index - width-1])
		else:
			hexcell.set_neighbor(variables.direction.SW, cells[index - width-1])
			if x < width-1:
				hexcell.set_neighbor(variables.direction.SE, cells[index - width+1])
	add_child(hexcell)
	cells.append(hexcell)



func change_color(button_pressed, color_index):
	color = colors[color_index]
