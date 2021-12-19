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
static func opposite(direction):
	return ( direction + 3) if direction < 3 else (direction - 3)  
func next_direction(_direction):
	return direction.NW if _direction == direction.NE else _direction + 1
func previous_direction(_direction):
	return direction.NE if _direction == direction.NW else _direction  - 1
func get_first_corner(direction):
	return corners[direction]
	
func get_second_corner(direction):
	return corners[direction + 1] 
	

