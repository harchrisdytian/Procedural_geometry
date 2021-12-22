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

var neighbors = [null,null,null,null,null,null]

func set_elevation(_elevation):
	elevation = _elevation
	translation.y = (elevation * step_factor)
	generate_geometery()
	
func tarrace_lerp(a:Vector3, b:Vector3, step:int) -> Vector3:
	var h = step * horizontal_step_size
	var c = a
	c.x +=  ((b.x - a.x) * h)
	c.z +=  ((b.z - a.z) * h)
	var v = ((step + 1) /2) * vertical_step_size

	c.y += ((b.y - a.y) * v)
	return c


func color_tarrace_lerp(a:Color,b:Color, step):
	var h = step * horizontal_step_size
	return a.linear_interpolate(b,h)
	
func get_elevation():
	return elevation
##grid vars

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
	if get_edge_type(direction) == variables.HexEdgeType.SLOPE:
		triangulate_tarrace_connection(v1,v2, cell_color,v3,v4, neighbor.cell_color)
	else:
		add_quad(v1,v2,v3,v4)
		add_quad_color_two(cell_color,neighbor.cell_color)
	
		
	
	if direction <= variables.direction.E and neighbors[variables.next_direction(direction)] != null:
		next_neighbor =neighbors[variables.next_direction(direction)]
		var v5 =v2 + get_bridge(variables.next_direction(direction))
		v5.y = (next_neighbor.elevation - elevation) * step_factor
		if elevation <= neighbor.elevation:
				if elevation <= next_neighbor.elevation:
					triangulate_coner(v2,self,v4,neighbor,v5,next_neighbor)
				else:
					triangulate_coner(v5,next_neighbor,v2,self,v4,neighbor)
					
		elif neighbor.elevation <= next_neighbor.elevation:
			triangulate_coner(v4, neighbor, v5, next_neighbor, v2, self)
		else:
			triangulate_coner(v5, next_neighbor, v2, self, v4, neighbor)
		
#		add_triangle(v2,v4,v5)
#		add_triangle_colors(cell_color,neighbor.cell_color,next_neighbor.cell_color)
		

func triangulate_tarrace_connection(
	_begin_left, _begin_right, _begin_color,
	_end_left,_end_right, _end_color
	):
	var v3 = tarrace_lerp(_begin_left,_end_left, 1)
	var v4 = tarrace_lerp(_begin_right,_end_right,1)
	var c1 = color_tarrace_lerp(_begin_color,_end_color,1)
	
	#print("is_running" + str(v3)+ str(v4))
#	print(str(_begin_left)+" "+str(v3)+ " "+ str(_begin_right) + " " + str(v4))
	add_quad(_begin_left,_begin_right,v3,v4)
	add_quad_color_two(_begin_color,c1)
	
	for i in range(2,tarreces_steps+1, 1):
		var v1 = v3
		var v2 = v4
		var c2 = c1
		v3 = tarrace_lerp(_begin_left,_end_left, i)
		v4 = tarrace_lerp(_begin_right,_end_right, i)
		c1 = color_tarrace_lerp(_begin_color,_end_color,i)
		add_quad(v1,v2,v3,v4)
		add_quad_color_two(c2,c1)

func triangulate_coner(
	bottom, bottom_edge,
	left, left_edge,
	right, right_edge):
		
		var left_edge_type = bottom_edge.get_edge_type_from_cell(left_edge)
		var right_edge_type = bottom_edge.get_edge_type_from_cell(right_edge)
		
		if left_edge_type == variables.HexEdgeType.SLOPE:
			if right_edge_type == variables.HexEdgeType.SLOPE:
				triangulate_coner_tarrace(bottom, bottom_edge, left, left_edge, right, right_edge)
				return
			if right_edge_type == variables.HexEdgeType.FLAT:
				triangulate_coner_tarrace(left,left_edge, right ,right_edge, bottom, bottom_edge)
				return
			triangulate_coner_tarrace_cliff(bottom,bottom_edge,left,left_edge,right,right_edge)
			return
		if right_edge_type == variables.HexEdgeType.SLOPE:
			if left_edge_type == variables.HexEdgeType.FLAT:
				triangulate_coner_tarrace(right,right_edge,bottom,bottom_edge,left,left_edge)
				return
			triangulate_coner_cliff_tarrace(bottom,bottom_edge,left,left_edge,right,right_edge)
			return
		if left_edge.get_edge_type_from_cell(right_edge) ==variables.HexEdgeType.SLOPE:
			if left_edge.elevation < right_edge.elevation:
				triangulate_coner_cliff_tarrace(right,right_edge,bottom,bottom_edge,left,left_edge)
			else:
				triangulate_coner_tarrace_cliff(left,left_edge,right,right_edge,bottom,bottom_edge)
		add_triangle(bottom,left,right)
		add_triangle_colors(bottom_edge.cell_color,left_edge.cell_color,right_edge.cell_color)

func triangulate_coner_tarrace(
	begin, begin_edge,
	left, left_edge,
	right, right_edge):
		var v3 =tarrace_lerp(begin,left,1)
		var v4 = tarrace_lerp(begin, right,1)
		var c3 = color_tarrace_lerp(begin_edge.cell_color, left_edge.cell_color, 1)
		var c4 =color_tarrace_lerp(begin_edge.cell_color, right_edge.cell_color,1)
		
		add_triangle(begin,v3,v4)
		add_triangle_colors(begin_edge.cell_color,c3,c4)
		for i in range(2,tarreces_steps+1, 1):
			var v1 = v3
			var v2 = v4
			var c1 = c3
			var c2 = c4
			v3 = tarrace_lerp(begin,left, i)
			v4 = tarrace_lerp(begin,right, i)
			c3 = color_tarrace_lerp(begin_edge.cell_color,left_edge.cell_color,i)
			c4 = color_tarrace_lerp(begin_edge.cell_color,right_edge.cell_color,i)
			add_quad(v1,v2,v3,v4)
			add_quad_color(c1,c2,c3,c4)
		add_quad(v3,v4,left, right)
		add_quad_color(c3,c4,left_edge.cell_color,right_edge.cell_color)


func triangulate_coner_tarrace_cliff(
	begin:Vector3, begin_edge,
	left:Vector3, left_edge,
	right:Vector3, right_edge):
		
		var b = 1.0 / (float(right_edge.elevation)- float(begin_edge.elevation))
		if b < 0:
			b = -b
		var boundry = begin.linear_interpolate(right,b)
		var boundry_color = begin_edge.cell_color.linear_interpolate(right_edge.cell_color,b) 
		
		triangulate_boundry_triangle(begin,begin_edge,left,left_edge,boundry,boundry_color)
		if left_edge.get_edge_type_from_cell(right_edge) == variables.HexEdgeType.SLOPE:
			triangulate_boundry_triangle(left,left_edge,right,right_edge,boundry,boundry_color)
		else:
			add_triangle(left,right,boundry)
			add_triangle_colors(left_edge.cell_color,right_edge.cell_color,boundry_color)
func triangulate_coner_cliff_tarrace(
	begin:Vector3, begin_edge,
	left:Vector3, left_edge,
	right:Vector3, right_edge):
		
		var b = 1.0 / (float(left_edge.elevation)- float(begin_edge.elevation))
		if b < 0:
			b = -b
		var boundry = begin.linear_interpolate(left,b)
		var boundry_color = begin_edge.cell_color.linear_interpolate(left_edge.cell_color,b) 
		
		triangulate_boundry_triangle(right,right_edge,begin,begin_edge,boundry,boundry_color)
		
		if left_edge.get_edge_type_from_cell(right_edge) == variables.HexEdgeType.SLOPE:
			triangulate_boundry_triangle(left,left_edge,right,right_edge,boundry,boundry_color)
		else:
			add_triangle(left,right,boundry)
			add_triangle_colors(left_edge.cell_color,right_edge.cell_color,boundry_color)

func triangulate_boundry_triangle(
	begin:Vector3, begin_edge,
	left:Vector3, left_edge,
	boundry:Vector3, boundry_color):
		var v2 = tarrace_lerp(begin,left,1) 
		var c2 = color_tarrace_lerp(begin_edge.cell_color,left_edge.cell_color,1)
		add_triangle(begin,v2,boundry)
		add_triangle_colors(begin_edge.cell_color,c2, boundry_color)
		for i in range(2,tarreces_steps+1, 1):
			var v1 = v2
			var c1 = c2
			v2 = tarrace_lerp(begin,left,i)
			c2 = color_tarrace_lerp(begin_edge.cell_color,left_edge.cell_color,i)
			add_triangle(v1,v2,boundry)
			add_triangle_colors(c1,c2,boundry_color)
		add_triangle(v2,left,boundry)
		add_triangle_colors(c2,left_edge.cell_color, boundry_color)
		
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
	if collision_polygon != null:
		collision_polygon = null
	collision_polygon = ConcavePolygonShape.new()
	
	collision_polygon.set_faces(mesh.get_faces())
	if collision_shape != null:
		collision_shape.free()
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

func get_edge_type(direction):
	return variables.get_edge_type(elevation, neighbors[direction].elevation)

func get_edge_type_from_cell(cell):
	return variables.get_edge_type(elevation, cell.elevation)
	
func set_neighbor(direction, cell):
		neighbors[direction] = cell
		cell.neighbors[variables.opposite(direction)]=self 
