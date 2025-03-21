@tool
extends Area2D

class_name Tile

# Propriedades básicas da peça
@export var tile_color : Globals.PieceColor

var row: int
var col: int

var piece: ChessPiece = null

var cards: Array = []

var neighbor_left: Tile = null
var neighbor_right: Tile = null
var neighbor_up: Tile = null
var neighbor_down: Tile = null

var is_hovered = false

func setup_tile(row:int, col:int):
	self.row = row
	self.col = col
	queue_redraw()

func _draw():
	if (row + col) % 2 == 0:
		self.tile_color = Globals.PieceColor.BLACK
		
	var color = Color(0.9, 0.9, 0.9) if (row + col) % 2 == 0 else Color(0.2, 0.2, 0.2)
	
	var tile_size = Vector2(64, 64)
	var rect = Rect2(-tile_size / 2, tile_size)  # Agora centralizado
	
	draw_rect(rect, color)
	# Se estiver com o mouse em cima, desenha a borda vermelha
	if is_hovered:
		draw_rect(rect, Color(1,0,0), false, 3)  # false = não preenchido, 3 = largura da borda

func _ready():
	queue_redraw()
	# Conectando automaticamente os sinais pelo código
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Tile clicado na posição: ", row, " x ",col)
		#get_parent().emit_signal("tile_selected", self)

func _on_mouse_entered():
	#print("Mouse entrou do tile: ", row, " x ",col)
	is_hovered = true
	queue_redraw()
# Mouse saiu da peça (Limpar os movimentos mostrados)
func _on_mouse_exited():
	#print("Mouse saiu do tile: ", row, " x ",col)
	is_hovered = false
	queue_redraw()
