extends Node2D

func _ready():
	# Só o servidor define a autoridade
	if multiplayer.is_server():
		set_multiplayer_authority(multiplayer.get_unique_id())
	
	print("ChessRoot pronto. Autoridade definida: ", multiplayer.get_unique_id())

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
