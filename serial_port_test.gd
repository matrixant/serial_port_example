extends Control

var serial := SerialPort.new()
var port := ""
var baudrate := 9600

var is_hex := false


func send_input_content():
	if serial.is_open():
		if is_hex:
#			Get hex code list
			var hex_str_arr:PackedStringArray = %InputArea.text.split(" ", false)
			var hex_buf: PackedByteArray
			for hex in hex_str_arr:
				if hex.is_valid_hex_number():
#					NOTE: May be cause an error, because the hex string may large than 2 bytes.
					hex_buf.append(hex.hex_to_int())
			serial.write_raw(hex_buf)
		else:
			serial.write_str(%InputArea.text)


func update_serial():
	port = %SerialList.get_item_text(%SerialList.selected)
	serial.port = port
	baudrate = %BaudRate.get_item_text(%BaudRate.selected).to_int()
	serial.baudrate = baudrate

func _on_error(where, what):
	print_debug("Got error when %s: %s" % [where, what])


# Called when the node enters the scene tree for the first time.
func _ready():
	serial.got_error.connect(_on_error)
	var ports_info := SerialPort.list_ports()
	for info in ports_info:
		%SerialList.add_item(info)
	if ports_info.size():
		%SerialList.select(0)
		
	%BaudRate.add_item("4800")
	%BaudRate.add_item("9600")
	%BaudRate.add_item("115200")
	%BaudRate.select(1)
	
	
	update_serial()
	serial.data_received.connect(_on_data_received)
	serial.start_monitoring(20000)
	pass # Replace with function body.


func _exit_tree():
	serial.stop_monitoring()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if serial.available() > 0:
#		var rec := serial.read_raw(serial.available())
#		_on_data_received(rec)
#		pass
	pass


func _on_data_received(data: PackedByteArray):
#	await RenderingServer.frame_post_draw
	%Content.text += data.get_string_from_ascii()
	%Content.scroll_vertical = %Content.get_line_count()
	if %Content.get_line_count() > 50:
		%Content.text = ""
	
	print("Received[%d]: %s" % [data.size(), data.get_string_from_ascii()])
	if serial.is_open():
		serial.write_raw(data)


func _on_send_pressed():
	send_input_content()


func _on_hex_toggled(button_pressed):
	is_hex = button_pressed


func _on_input_area_text_submitted(new_text):
	send_input_content()


func _on_serial_list_item_selected(index):
	port = %SerialList.get_item_text(index)


func _on_open_close_toggled(button_pressed):
	if button_pressed:
		serial.baudrate = baudrate
		serial.open(port)
		if serial.is_open():
			button_pressed = false
			%OpenClose.text = "Close"
	else:
		serial.close()
		if not serial.is_open():
			button_pressed = true
			%OpenClose.text = "Open"



func _on_baud_rate_item_selected(index):
	baudrate = %BaudRate.get_item_text(index).to_int()
	pass # Replace with function body.
