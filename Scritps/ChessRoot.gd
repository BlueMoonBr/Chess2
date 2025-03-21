extends Node2D

@export var selected: bool = false:
	set(value):
		selected = value
		update_selected_piece_texture()

@export var selected_piece_type: Globals.PieceType = Globals.PieceType.PAWN:
	set(value):
		selected_piece_type = value
		update_selected_piece_texture()

@export var selected_piece_color: Globals.PieceColor = Globals.PieceColor.BLACK:
	set(value):
		selected_piece_color = value
		update_selected_piece_texture()
		
@onready var texture_rect = $CanvasLayer/MainUI/VBoxContainer/TextureRect
@onready var white = $CanvasLayer/MainUI/cards/WHITE
@onready var black = $CanvasLayer/MainUI/cards/BLACK

func _ready():
	# Só o servidor define a autoridade
	if multiplayer.is_server():
		set_multiplayer_authority(multiplayer.get_unique_id())
	
	print("ChessRoot pronto. Autoridade definida: ", multiplayer.get_unique_id())
	
	update_selected_piece_texture()
	ready_main_ui()


func update_selected_piece_texture():
	if texture_rect == null:
		return
	
	if !selected:
		texture_rect.hide()
		return
	
	texture_rect.show()
	var texture = Globals.PIECE_TEXTURES.get(selected_piece_type, null)
	if texture:
		texture_rect.texture = texture
		texture_rect.modulate = Globals.get_color_by_piece_color(selected_piece_color)
	else:
		texture_rect.texture = null
		
@rpc("any_peer")
func rpc_create_tile(row, col):
	get_node("ChessBoard").rpc_create_tile(row, col)

@rpc("any_peer")
func request_create_tile(row, col):
	if multiplayer.is_server():
		# Servidor cria localmente antes
		rpc_create_tile(row, col)
		# Depois avisa clientes explicitamente
		rpc_create_tile.rpc(row, col)



func ready_main_ui():
	var popup_White = white.get_popup()
	popup_White.id_pressed.connect(_on_piece_white_menu_item_selected)
	
	var popup_black: PopupMenu = black.get_popup()
	popup_black.id_pressed.connect(_on_piece_black_menu_item_selected)

	popup_black.set_item_icon_modulate(0, Globals.get_color_by_piece_color(Globals.PieceColor.BLACK))
	popup_black.set_item_icon_modulate(1, Globals.get_color_by_piece_color(Globals.PieceColor.BLACK))
	popup_black.set_item_icon_modulate(2, Globals.get_color_by_piece_color(Globals.PieceColor.BLACK))
	popup_black.set_item_icon_modulate(3, Globals.get_color_by_piece_color(Globals.PieceColor.BLACK))
	popup_black.set_item_icon_modulate(4, Globals.get_color_by_piece_color(Globals.PieceColor.BLACK))
	popup_black.set_item_icon_modulate(5, Globals.get_color_by_piece_color(Globals.PieceColor.BLACK))
	
# acoes
func _on_piece_black_menu_item_selected(id: int):
	_on_piece_menu_item_selected(id, Globals.PieceColor.BLACK)

func _on_piece_white_menu_item_selected(id: int):
	_on_piece_menu_item_selected(id, Globals.PieceColor.WHITE)

func _on_piece_menu_item_selected(id: int, color: Globals.PieceColor):
	selected = true
	selected_piece_type = Globals.get_piece_by_id(id)
	selected_piece_color = color
	
	update_selected_piece_texture()
