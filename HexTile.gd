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
##grid vars
var neighbors = [null,null,null,null,null,null]

func triangulate(direction):
	var center = Vector3(0,0,0)
	add_triangle(
			center,
			center + variables.get_first_corner(direction),
			center + variables.get_second_corner(direction)
	)
	var neighbor = self
	if neighbors[direction]:
		neighbor = neighbors[direction]
	add_triangle_colors(cell_color, neighbor.cell_color,neighbor.cell_color)
	
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
		#print(c)
func add_triangle_color(color):
	colors.append(color)
	colors.append(color)
	colors.append(color)

func add_triangle_colors(c1,c2,c3):
	colors.append(c1)
	colors.append(c2)
	colors.append(c3)

func generate_geometery():
	verts = PoolVector3Array()
	uvs = PoolVector2Array()
	normals = PoolVector3Array()
	indices = PoolIntArray()
	colors = PoolColorArray()
	
	#print(center)
	for i in range(variables.direction.size()):
		print(i)
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
	collision_polygon.set_faces(verts)
	
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
