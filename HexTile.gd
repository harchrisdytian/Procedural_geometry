extends MeshInstance



#############################
### mesh gen#################
#############################
var vert_array = []
##collision
var collision_polygon : ConcavePolygonShape
var collision_shape : CollisionShape
var collision_body : StaticBody
##array value
var verts = PoolVector3Array()
var uvs = PoolVector2Array()
var normals = PoolVector3Array()
var indices = PoolIntArray()
var colors = PoolColorArray()
##colors
var chords: HexChords 
var cell_color = Color(0.5,0.5,0.5)
const solid_factor = 0.75 
const blend_factor = 1 - solid_factor
#elevation
const tarreces_per_slope = 2 
const tarreces_steps= tarreces_per_slope * 2 + 1

const horizontal_step_size  = 1.0 / tarreces_steps

const vertical_step_size = 1.0 / (tarreces_per_slope + 1.0)

const step_factor = 5.0
var elevation = 0 setget set_elevation, get_elevation


func set_elevation(_elevation):
	elevation = _elevation
	translation.y = (elevation * step_factor)
	generate_geometery()
	
func tarrace_lerp(a:Vector3, b:Vector3, step:int) -> Vector3:
	var h = step * horizontal_step_size
	var c = a
	c.x +=  ((b.x - a.x) * h)
	c.z +=  ((b.z - a.z) * h)
	var v = ((step + 1.0) /2.0) * vertical_step_size

	c.y += ((b.y - a.y) * v)
	return c


func color_tarrace_lerp(a:Color,b:Color, step):
	var h = step * horizontal_step_size
	return a.linear_interpolate(b,h)
	
func get_elevation():
	return elevation
##grid vars
var neighbors = [null,null,null,null,null,null]

func triangulate(direction):
	
	var center = Vector3(0,0,0)
	var v1 = center + get_first_solid_corner(direction)
	var v2 = center + get_second_solid_corner(direction)
		
	add_triangle(center, v1,v2 )
	add_triangle_color(cell_color)
	
	if direction == variables.direction.NE:
		triangulate_connection(direction,v1, v2)
	if direction == variables.direction.E:
		triangulate_connection(direction,v1, v2)
	if direction == variables.direction.SE:
		triangulate_connection(direction,v1, v2)

func triangulate_connection(direction,v1,v2):
	var neighbor = self
	var prev_neighbor = self
	var next_neighbor = self
	if neighbors[direction]:
		neighbor = neighbors[direction]
	else: 
		return
		
		
	
	var bridge = get_bridge(direction)
	var bridge_color = (cell_color + neighbor.cell_color)*0.5
	var v3 =v1 + bridge
	var v4= v2 + bridge
	v3.y = (neighbor.elevation - elevation) * step_factor

	v4.y = v3.y
	
	triangulate_tarrace_connection(v1,v2, cell_color,v3,v4, neighbor.cell_color)
#	add_quad(v1,v2,v3,v4)
#	add_quad_color_two(cell_color,neighbor.cell_color)
	
	if direction <= variables.direction.E and neighbors[variables.next_direction(direction)] != null:
		next_neighbor =neighbors[variables.next_direction(direction)]
		var v5 =v2 + get_bridge(variables.next_direction(direction))
		v5.y = (next_neighbor.elevation - elevation) * step_factor
		add_triangle(v2,v4,v5)
		add_triangle_colors(cell_color,neighbor.cell_color,next_neighbor.cell_color)
		

func triangulate_tarrace_connection(
	_begin_left, _begin_right, _begin_color,
	_end_left,_end_right, _end_color
	):
	var v3 = tarrace_lerp(_begin_left,_end_left, 1)
	var v4 = tarrace_lerp(_begin_right,_end_right,1)
	var c = color_tarrace_lerp(_begin_color,_end_color,1)
	#print("is_running" + str(v3)+ str(v4))
#	print(str(_begin_left)+" "+str(v3)+ " "+ str(_begin_right) + " " + str(v4))
	add_quad(_begin_left,_begin_right,v3,v4)
	add_quad_color_two(_begin_color,Color.green)

func add_triangle(v1,v2,v3):
	var ind = verts.size()
	var x = v1 - v2
	var y = v1 - v3
	var c = -x.cross(y).normalized()
	#var center = Vector3(v1,v2,v3)
	#center.normalized()
	verts.append(v1)
	verts.append(v2)
	verts.append(v3)
	uvs.append(Vector2(0,0))
	uvs.append(Vector2(0,0))
	uvs.append(Vector2(1,1))
	indices.append(ind)
	indices.append(ind + 1)
	indices.append(ind + 2)
	
	for i in range(3):
		normals.append(c)

func get_first_corner(direction):
	return variables.corners[direction]

func get_second_corner(direction):
	return variables.corners[direction + 1] 

func get_first_solid_corner(direction):
	return variables.corners[direction] * solid_factor

func get_second_solid_corner(direction):
	return variables.corners[direction+1] * solid_factor

func get_bridge(direction):
	return (variables.corners[direction]+variables.corners[direction + 1])  * blend_factor

func add_quad(v1,v2,v3,v4):
	var ind = verts.size()
	var x = v1 - v2
	var y = v1 - v3
	var c = -x.cross(y).normalized()
	#var center = Vector3(v1,v2,v3)
	#center.normalized()
	verts.append(v1)
	verts.append(v2)
	verts.append(v3)
	verts.append(v4)
	
	uvs.append(Vector2(0,0))
	uvs.append(Vector2(0,0))
	uvs.append(Vector2(1,1))
	uvs.append(Vector2(0,1))
	
	indices.append(ind)
	indices.append(ind + 2)
	indices.append(ind + 1)
	indices.append(ind + 1)
	indices.append(ind + 2)
	indices.append(ind + 3)
	for i in range(4):
		normals.append(c)

func add_quad_color(c1,c2,c3,c4):
	colors.append(c1)
	colors.append(c2)
	colors.append(c3)
	colors.append(c4)
func add_quad_color_two(c1,c2):
	colors.append(c1)
	colors.append(c1)
	colors.append(c2)
	colors.append(c2)

func add_triangle_color(color):
	colors.append(color)
	colors.append(color)
	colors.append(color)

func add_triangle_colors(c1,c2,c3):
	colors.append(c1)
	colors.append(c2)
	colors.append(c3)

func update_neighbors():
	for i in neighbors:
		if i != null:
			i.generate_geometery()

func generate_geometery():
	verts = PoolVector3Array()
	uvs = PoolVector2Array()
	normals = PoolVector3Array()
	indices = PoolIntArray()
	colors = PoolColorArray()
	
	#print(center)
	for i in range(variables.direction.size()):
		triangulate(i)

	#print(vert_array)
	vert_array.resize(Mesh.ARRAY_MAX)
	
	vert_array[Mesh.ARRAY_VERTEX] = verts
	vert_array[Mesh.ARRAY_TEX_UV] = uvs
	vert_array[Mesh.ARRAY_NORMAL] = normals
	vert_array[Mesh.ARRAY_INDEX] = indices
	vert_array[Mesh.ARRAY_COLOR]= colors;
	
	
	var new_mesh = Mesh.new()
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, vert_array)
	mesh = new_mesh
	
	generate_collision()

func _ready():
	generate_geometery()

func generate_collision():
	collision_polygon = ConcavePolygonShape.new()
	
	collision_polygon.set_faces(mesh.get_faces())
	
	collision_shape = CollisionShape.new()
	collision_shape.set_shape(collision_polygon)
	
	collision_body = StaticBody.new()
	collision_body.add_child(collision_shape)
	collision_body.collision_layer = 1
	collision_body.collision_mask  = 1
	
	add_child(collision_body)

func set_label(text):
	#if chords:
	$Viewport/CenterContainer/Label.text = chords.to_new_line_string()

#####################
## neighbor gen######
#####################

func get_neighbor(direction):
	return neighbors[direction]

func set_neighbor(direction, cell):
		neighbors[direction] = cell
		cell.neighbors[variables.opposite(direction)]=self 
