extends Reference

class_name HexChords

var x :int
var z :int
var y :int setget ,_get_y

func _init(_x:int =0, _z:int = 0):
	x=_x
	z=_z
	
func _get_y():
	return -x - z

func _to_string():
	return "(" + str(x) +","+str(self.y) +","+str(z) + ")"
	
func to_new_line_string():
	return str(x) + "\n" + str(self.y) +"\n" + str(z)
#equivilents of static methiods
static func to_offset_Coordinates(_x:int,_z:int):
	var new = variables.hexChordsClass.new(_x - _z / 2,_z)
	return new
	
static func to_hex_coords(pos:Vector3):
	var X = pos.x / (variables.INNER_RADIUS * 2.0)
	var Y= -X
	var offset = pos.z  / (variables.OUTER_RADIUS * 3.0)
	X -=offset
	Y -=offset
	var intX = stepify(X,1)
	var intY = stepify(Y,1)
	var intZ = stepify(-X -Y,1)
	
	if(intX + intY + intZ != 0):
		printerr("hexCoords invailid")
	
	
	return variables.hexChordsClass.new(intX,intZ)
