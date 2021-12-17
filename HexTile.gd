extends MeshInstance



#############################
### mesh gen#################
#############################
var vert_array = []

var verts = PoolVector3Array()
var uvs = PoolVector2Array()
var normals = PoolVector3Array()
var indices = PoolIntArray()
var colors = PoolColorArray()
var color = Color(0.5,0.5,0.5)

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
		colors.append(color)
	
	for i in range(3):
		normals.append(c)
		#print(c)
	

func generate_geometery():
	vert_array.resize(Mesh.ARRAY_MAX)
	
	vert_array[Mesh.ARRAY_VERTEX] = verts
	vert_array[Mesh.ARRAY_TEX_UV] = uvs
	vert_array[Mesh.ARRAY_NORMAL] = normals
	vert_array[Mesh.ARRAY_INDEX] = indices
	vert_array[Mesh.ARRAY_COLOR]= colors;
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, vert_array)
	
func _ready():
	var center = Vector3(0,0,0)
	print(center)
	for i in range(6):
		add_triangle(
				center,
				center + variables.corners[i-1],
				center + variables.corners[i]
		)
	generate_geometery()
	print(vert_array)
	

func set_label(text):
	$Viewport/CenterContainer/Label.text = text

