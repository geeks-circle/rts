extends Node

var udp_network: PacketPeerUDP
var _broadcast_timer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	udp_network = PacketPeerUDP.new()
	udp_network.set_broadcast_enabled(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_broadcast_timer -= delta
	if _broadcast_timer <= 0:
		_broadcast_timer = Globals.UDP_BROADCAST_FREQUENCY
		var stg = "%s,%d,%d,%d" % [Globals.player_name, Lobby.PORT, 0, 10]
		var pac = stg.to_utf8_buffer()

		for address in IP.get_local_addresses():
			var parts = address.split('.')
			if (parts.size() == 4):
				parts[3] = '255'
				var broadcast_address = "%s.%s.%s.%s" % Array(parts)
				udp_network.set_dest_address(broadcast_address, Globals.UDP_BROADCAST_PORT)
				var error = udp_network.put_packet(pac)
				if error == 1:
					pass
					#print("Error while sending to ", broadcast_address)
