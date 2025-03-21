extends Node2D

@export var board_size  = 8 

const TILE_SIZE = 64

var tiles = {}
var buttons = {}

@onready var btn_client = $"../CanvasLayer/MainUI/menu/BtnClient"
@onready var btn_server = $"../CanvasLayer/MainUI/menu/BtnServer"
@onready var txt_ip_port = $"../CanvasLayer/MainUI/menu/txtIpPort"
@onready var txt_ip_server = $"../CanvasLayer/MainUI/menu/txtIpServer"

var tile_scene = preload("res://Scenes/Tile.tscn")

func _ready():
	generate_board()
	update_edge_buttons()

func rpc_create_tile(row, col):
	var pos = Vector2(col * TILE_SIZE, row * TILE_SIZE)
	create_tile(row, col, pos.x, pos.y)
	update_tile_neighbors()
	update_edge_buttons()
	

@rpc("authority", "call_remote", "reliable")
func request_create_tile(row, col):
	# Apenas o servidor executa isso:
	if multiplayer.is_server():
		rpc_create_tile(row, col)
		
func generate_board():

	var start_x = 0
	var start_y = 0
	
	#Vector2(col * TILE_SIZE, row * TILE_SIZE)
	for row in range(board_size):
		for col in range(board_size):
			create_tile(row, col, start_x + col * TILE_SIZE, start_y + row * TILE_SIZE)
			
	# Define vizinhos
	update_tile_neighbors()

func create_tile(row, col, x, y):
	print(row,' ', col,' ', x,' ', y)
	
	var new_tile = tile_scene.instantiate()
	new_tile.position = Vector2(col * 64, row * 64)
	new_tile.setup_tile(row, col)
	add_child(new_tile)
	tiles["%d_%d" % [row, col]] = new_tile

func update_tile_neighbors():
	for key in tiles:
		var tile = tiles[key]
		var row = tile.row
		var col = tile.col
		tile.neighbor_left = tiles.get("%d_%d" % [row, col - 1])
		tile.neighbor_right = tiles.get("%d_%d" % [row, col + 1])
		tile.neighbor_up = tiles.get("%d_%d" % [row - 1, col])
		tile.neighbor_down = tiles.get("%d_%d" % [row + 1, col])

func update_edge_buttons():
	# Limpa botões existentes antes
	for b in buttons.values():
		b.queue_free()
	buttons.clear()

	var directions = {
		"left": Vector2(-1, 0),
		"right": Vector2(1, 0),
		"up": Vector2(0, -1),
		"down": Vector2(0, 1)
	}

	for tile in tiles.values():
		for dir in directions:
			var offset = directions[dir]
			var neighbor_row = tile.row + int(offset.y)
			var neighbor_col = tile.col + int(offset.x)
			var neighbor_key = "%d_%d" % [neighbor_row, neighbor_col]

			if not tiles.has(neighbor_key) and not buttons.has(neighbor_key):
				# CORREÇÃO aqui:
				var button_position = tile.position + offset * TILE_SIZE
				button_position -= Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
				create_button(neighbor_row, neighbor_col, button_position)
				
func create_button(row, col, position):
	var button = Button.new()
	button.text = "+"
	button.size = Vector2(20, 20)
	button.position = position + Vector2((TILE_SIZE - 20)/2, (TILE_SIZE - 20)/2)
	add_child(button)
	buttons["%d_%d" % [row, col]] = button
	
	button.pressed.connect(func():
		if multiplayer.multiplayer_peer:
			if multiplayer.is_server():
				# Servidor cria localmente e avisa clientes
				get_node("/root/ChessRoot").rpc_create_tile(row, col)
				get_node("/root/ChessRoot").rpc_create_tile.rpc(row, col)
			else:
				# Cliente pede ao servidor para criar
				get_node("/root/ChessRoot").request_create_tile.rpc_id(1, row, col)
		else:
			# Sem multiplayer, cria localmente mesmo
			add_tile_and_update(row, col)
	)

func add_tile_and_update(row, col):
	if multiplayer.multiplayer_peer:
		if multiplayer.is_server():
			# Servidor cria localmente e informa clientes
			rpc_create_tile(row, col)
		else:
			# Cliente pede ao servidor para criar
			request_create_tile.rpc_id(1, row, col)
	else:
		# Sem multiplayer, cria localmente mesmo
		create_tile(row, col, col * TILE_SIZE, row * TILE_SIZE)
		update_tile_neighbors()
		update_edge_buttons()


func _on_BtnMultiplayer_pressed():
	print("Botão Multiplayer pressionado!")
	btn_client.show();
	btn_client.disabled = false;
	btn_server.show();
	btn_server.disabled = false;
	txt_ip_server.show();


# Sinais para os novos botões (conecte-os na interface visual igual antes):
func _on_BtnServer_pressed():
	print("Servidor iniciado.")
	btn_client.hide();
	txt_ip_server.hide();
	iniciar_servidor()

func _on_BtnClient_pressed():
	btn_server.hide();
	print("Cliente conectado.")
	conectar_cliente()

# Implementações iniciais das funções multiplayer:
func iniciar_servidor():
	var peer = ENetMultiplayerPeer.new()
	var erro = peer.create_server(4242)
	if erro != OK:
		print("Erro ao criar servidor: ", erro)
		return
		
	multiplayer.multiplayer_peer = peer
	print("Servidor iniciado com sucesso na porta 4242.")

func conectar_cliente():
	print(txt_ip_server.text)
	
	var peer = ENetMultiplayerPeer.new()
	var endereco_servidor = txt_ip_server.text  # Substitua depois pelo IP do servidor na LAN
	if(endereco_servidor == ""):
		print("ip não informado conectando localhost")
		endereco_servidor= "127.0.0.1"
		
	var erro = peer.create_client(endereco_servidor, 4242)
	if erro != OK:
		print("Erro ao conectar ao servidor: ", erro)
		return
	multiplayer.multiplayer_peer = peer
	print("Cliente conectado ao servidor no endereço: ", endereco_servidor)
