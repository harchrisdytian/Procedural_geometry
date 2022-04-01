extends Node
const OUTER_RADIUS = 10
const INNER_RADIUS = OUTER_RADIUS * 0.866025404
#fuccky work around
var hexChordsClass = load("res://HexChords.gd")
var hexTile = preload("res://HexTile.tscn")
var  corners = [
		 Vector3(0, 0, OUTER_RADIUS) ,
		 Vector3(INNER_RADIUS, 0, 0.5 * OUTER_RADIUS),
		 Vector3(INNER_RADIUS, 0, -0.5 * OUTER_RADIUS),
		 Vector3(0, 0, -OUTER_RADIUS),
		 Vector3(-INNER_RADIUS, 0, -0.5 * OUTER_RADIUS),
		 Vector3(-INNER_RADIUS, 0, 0.5* OUTER_RADIUS),
		 Vector3(0, 0, OUTER_RADIUS)
		]
enum direction {NE,E,SE,SW,W,NW}
enum HexEdgeType { FLAT,SLOPE,CLIFF}

static func opposite(direction):
	return ( direction + 3) if direction < 3 else (direction - 3)  
func next_direction(_direction):
	return direction.NE if _direction == direction.NW else _direction + 1

func previous_direction(_direction):
	return direction.NW if _direction == direction.NE else _direction - 1
	
func get_edge_type(elevation1,elevation2):
	if elevation1 == elevation2:
		return HexEdgeType.FLAT
	var delta = elevation1 - elevation2
	if delta == 1 or delta == -1:
		return HexEdgeType.SLOPE
	return HexEdgeType.CLIFF

