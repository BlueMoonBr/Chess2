extends ChessPiece


func _ready():
	piece_type = Globals.PieceType.KING
	super._ready()

func hover():
	super.hover();
	
func _on_mouse_exited():
	super._on_mouse_exited();
