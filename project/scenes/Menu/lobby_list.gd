extends VBoxContainer

var udp_network: PacketPeerUDP
var is_searching := false
var servers := {}  # Dictionary to store server information
var last_packet_time := 0.0

func setup_search() -> void:
	udp_network = PacketPeerUDP.new()
	
	var error = udp_network.bind(Globals.UDP_BROADCAST_PORT)
	if error != OK:
		print("Error binding to port: ", Globals.UDP_BROADCAST_PORT)
	else:
		print("Listening on port: ", Globals.UDP_BROADCAST_PORT)

func _process(delta: float) -> void:
	if !is_searching:
		return
	
	last_packet_time += delta
	
	if udp_network.get_available_packet_count() > 0:
		var packet = udp_network.get_packet()
		var packet_string = packet.get_string_from_utf8()
		
		var sender_ip = udp_network.get_packet_ip()
		var sender_port = udp_network.get_packet_port()
		
		var array = packet_string.split(",")
		var new_server_name = array[0]
		var new_server_port = array[1]
		var new_server_players = array[2]
		var new_server_max_p = array[3]
		
		print("Received packet from %s:%s" % [sender_ip, sender_port])
		print("Server info: ", array)
		
		add_or_update_server(new_server_name, sender_ip, new_server_port, new_server_players, new_server_max_p)
		last_packet_time = 0.0
	
	if last_packet_time >= Globals.UDP_BROADCAST_FREQUENCY + 2.0:
		remove_inactive_servers()

func add_or_update_server(server_name: String, server_ip: String, server_port: String, players: String, max_players: String) -> void:
	var server_key = server_ip + ":" + server_port
	
	if server_key in servers:
		# Update existing server button
		var button = servers[server_key]
		button.text = "%s (%s) - %s/%s" % [server_name, server_ip, players, max_players]
	else:
		# Create new server button
		var button = Button.new()
		button.text = "%s (%s) - %s/%s" % [server_name, server_ip, players, max_players]
		button.connect("pressed", Callable(self, "_on_server_button_pressed").bind(server_name, server_ip, server_port))
		add_child(button)
		servers[server_key] = button

func remove_inactive_servers() -> void:
	var keys_to_remove = []
	for server_key in servers:
		var button = servers[server_key]
		button.queue_free()
		keys_to_remove.append(server_key)
	
	for key in keys_to_remove:
		servers.erase(key)
	
	last_packet_time = 0.0

func _on_button_pressed() -> void:
	if Globals.player_name != "":
		$"%SearchButton".disabled = true
		setup_search()
		is_searching = true

func _on_server_button_pressed(server_name: String, server_ip: String, server_port: String) -> void:
	print("Connecting to server: %s at %s:%s" % [server_name, server_ip, server_port])
	# Add your connection logic here
