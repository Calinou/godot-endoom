# <https://doomwiki.org/wiki/ENDOOM>
extends RichTextLabel


func _ready() -> void:
	var file := FileAccess.open("res://endoom/doom1.lmp", FileAccess.READ)

	for byte_idx in range(2, file.get_length(), 2):
		file.seek(byte_idx)
		var char_and_color := file.get_buffer(2)

		var character := ""
		var swap_foreground_background := false
		if char_and_color[0] == 0x20:
			# Use full blocks for spaces so that foreground/background color is visible on empty space.
			character = String.chr(0xdb)
			swap_foreground_background = true
		else:
			character = String.chr(char_and_color[0])

		# ENDOOM format is 80×25; add a line break every 80 characters.
		if byte_idx % 160 == 0:
			character = "\n"

		var foreground_color := Color()
		match char_and_color[1] & 0b1111:
			0:
				foreground_color = Color.BLACK
			1:
				foreground_color = Color.DARK_BLUE
			2:
				foreground_color = Color.DARK_GREEN
			3:
				foreground_color = Color.DARK_CYAN
			4:
				foreground_color = Color.DARK_RED
			5:
				foreground_color = Color.DARK_MAGENTA
			6:
				foreground_color = Color.BROWN
			7:
				foreground_color = Color.GRAY
			8:
				foreground_color = Color.DARK_GRAY
			9:
				foreground_color = Color.LIGHT_BLUE
			10:
				foreground_color = Color.LIGHT_GREEN
			11:
				foreground_color = Color.CYAN
			12:
				foreground_color = Color.SALMON
			13:
				foreground_color = Color.PINK
			14:
				foreground_color = Color.YELLOW
			15:
				foreground_color = Color.WHITE

		var background_color := Color()
		match char_and_color[1] >> 4:
			0:
				background_color = Color.BLACK
			1:
				background_color = Color.DARK_BLUE
			2:
				background_color = Color.DARK_GREEN
			3:
				background_color = Color.DARK_CYAN
			4:
				background_color = Color.DARK_RED
			5:
				background_color = Color.DARK_MAGENTA
			6:
				background_color = Color.BROWN
			7:
				background_color = Color.GRAY

		if swap_foreground_background:
			push_color(background_color)
			push_bgcolor(foreground_color)
		else:
			push_color(foreground_color)
			push_bgcolor(background_color)

		add_text(character)
		pop()
		pop()

		# The blinking bit is ignored. It's generally not used in ENDOOM lumps anyway.
