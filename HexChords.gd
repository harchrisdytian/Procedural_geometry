extends Reference

class_name HexChords
var x :int
var y :int

func _init(_x:int, _y:int):
	x=_x
	y=_y
	
func to_offset_Coordinates(_x:int,_y:int):
	var new = HexChords.new(_x - y / 2,_y)
	return new
func _to_string():
	return "(" + str(x) +","+ str(y) + ")"
	
func new_line_string():
	return str(x) + "\n" + str(y)
	
