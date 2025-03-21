@tool
extends Area2D

class_name ChessPiece

# Propriedades básicas da peça
@export var piece_color: Globals.PieceColor = Globals.PieceColor.BLACK:
	set(value):
		piece_color = value
		set_texture()

var piece_type : Globals.PieceType

# Variável para armazenar a textura da peça
var piece_texture : Texture2D
@onready var sprite = $Sprite2D

# Referência ao tabuleiro
var chess_board : Node = null

# Referência a posição:
var chess_tile : Tile = null

var cards : Array = []

func _ready():
	chess_board = get_tree().get_root().get_node("ChessRoot/ChessBoard")
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	set_texture()

func set_texture():
		 # Carrega automaticamente a textura correta pela peça
	piece_texture = Globals.PIECE_TEXTURES[piece_type]
	sprite.texture = piece_texture  # Define a textura
	
	# Define a cor com base no enum
	match piece_color:
		Globals.PieceColor.WHITE:
			sprite.modulate = Color(1, 1, 1)  # Branco
		Globals.PieceColor.BLACK:
			sprite.modulate = Color(0, 0, 0)  # Preto

# Função genérica do hover - será sobrescrita nas subclasses
func hover():
	print("Mouse sobre a peça!")

# Mouse entrou na peça
func _on_mouse_entered():
	sprite.modulate = Color(1, 0, 0)  # Vermelho
	hover()

# Mouse saiu da peça (Limpar os movimentos mostrados)
func _on_mouse_exited():
	print("Mouse saiu da peça!")
	set_texture()
