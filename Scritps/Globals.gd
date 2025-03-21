# Scripts/Globals.gd
extends Node

enum PieceType {
	PAWN,
	KNIGHT,
	BISHOP,
	ROOK,
	QUEEN,
	KING
}

enum PieceColor {
	WHITE,
	BLACK
}

const PIECE_TEXTURES = {
	PieceType.PAWN: preload("res://Assets/Pieces/pawn.png"),
	PieceType.KNIGHT: preload("res://Assets/Pieces/knight.png"),
	PieceType.BISHOP: preload("res://Assets/Pieces/bishop.png"),
	PieceType.ROOK: preload("res://Assets/Pieces/rook.png"),
	PieceType.QUEEN: preload("res://Assets/Pieces/queen.png"),
	PieceType.KING: preload("res://Assets/Pieces/king.png")
}

func get_piece_by_id(id: int) -> PieceType:
	match id:
		0:
			return PieceType.PAWN
		1:
			return PieceType.ROOK
		2:
			return PieceType.KNIGHT
		3:
			return PieceType.BISHOP
		4:
			return PieceType.QUEEN
		5:
			return PieceType.KING
			
	return PieceType.PAWN

func get_color_by_piece_color(input_color: PieceColor):
	var color = Color(1, 1, 1)
	match input_color:
		PieceColor.WHITE:
			color = Color(1, 1, 1)  # Branco
		PieceColor.BLACK:
			color = Color(0, 0, 0)  # Preto
	return color
