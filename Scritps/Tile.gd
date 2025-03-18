extends Node2D
class_name Tile

var row: int
var col: int

var piece = null
var cards: Array = []

var neighbor_left: Tile = null
var neighbor_right: Tile = null
var neighbor_up: Tile = null
var neighbor_down: Tile = null

func _init(row: int, col: int):
	self.row = row
	self.col = col

func _draw():
	var color = Color(0.9, 0.9, 0.9) if (row + col) % 2 == 0 else Color(0.2, 0.2, 0.2)
	draw_rect(Rect2(Vector2.ZERO, Vector2(64, 64)), color)

func _ready():
	queue_redraw()
