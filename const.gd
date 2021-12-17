extends Node
const OUTER_RADIUS = 10
const INNER_RADIUS = OUTER_RADIUS * 0.866025404

var  corners = [
		 Vector3(0, 0, OUTER_RADIUS) ,
		 Vector3(INNER_RADIUS, 0, 0.5 * OUTER_RADIUS),
		 Vector3(INNER_RADIUS, 0, -0.5 * OUTER_RADIUS),
		 Vector3(0, 0, -OUTER_RADIUS),
		 Vector3(-INNER_RADIUS, 0, -0.5 * OUTER_RADIUS),
		 Vector3(-INNER_RADIUS, 0, 0.5* OUTER_RADIUS)
		]
var hexTile = preload("res://HexTile.tscn")

