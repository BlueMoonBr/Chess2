extends Node2D

const BOARD_SIZE = 8
const TILE_SIZE = 64

var tiles = {}
var buttons = {}

@onready var btn_server = $"../../CanvasLayer/BtnServer"
@onready var btn_client = $"../../CanvasLayer/BtnClient"
@onready var txt_ip_server = $"../../CanvasLayer/txtIpServer"

func _ready():
	generate_board()
	update_edge_buttons()
	
	# Oculta os botões no início
	btn_server.hide()
	btn_client.hide()
	txt_ip_server.hide()

@rpc("any_peer", "call_remote", "reliable")
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
	var board_pixel_size = BOARD_SIZE * TILE_SIZE
	
	var start_x = 0
	var start_y = 0
	
	#Vector2(col * TILE_SIZE, row * TILE_SIZE)
	for row in range(BOARD_SIZE):
		for col in range(BOARD_SIZE):
			create_tile(row, col, start_x + col * TILE_SIZE, start_y + row * TILE_SIZE)
			
	# Define vizinhos
	update_tile_neighbors()

func create_tile(row, col, x, y):
	print(row,' ', col,' ', x,' ', y)
	var tile = Tile.new(row, col)
	tile.position = Vector2(x, y)
	add_child(tile)
	tiles["%d_%d" % [row, col]] = tile

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

	# Verifica cada casa e adiciona botões nas posições vazias vizinhas
	for tile in tiles.values():
		var directions = {
			"left": Vector2(-1, 0),
			"right": Vector2(1, 0),
			"up": Vector2(0, -1),
			"down": Vector2(0, 1)
		}

		for dir in directions:
			var offset = directions[dir]
			var neighbor_key = "%d_%d" % [tile.row + int(offset.y), tile.col + int(offset.x)]
			if not tiles.has(neighbor_key) and not buttons.has(neighbor_key):
				create_button(tile.row + int(offset.y), tile.col + int(offset.x), tile.position + offset * TILE_SIZE)

func create_button(row, col, position):
	var button = Button.new()
	button.text = "+"
	button.size = Vector2(20, 20)
	button.position = position + Vector2((TILE_SIZE - 20)/2, (TILE_SIZE - 20)/2)
	add_child(button)
	buttons["%d_%d" % [row, col]] = button
	button.pressed.connect(func(): add_tile_and_update(row, col))

func add_tile_and_update(row, col):
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
	iniciar_servidor()

func _on_BtnClient_pressed():
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
