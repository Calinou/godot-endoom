# <https://doomwiki.org/wiki/ENDOOM>
extends RichTextLabel

# Use BBCode instead of `push_*()` methods (slower, but allows for console output).
@export var use_bbcode := false

# Use exact HTML color codes instead of approximations like `red` and `green`.
# Not compatible with console output.
@export var use_bbcode_exact_colors := false


func _ready() -> void:
	var file := FileAccess.open("res://endoom/doom1.lmp", FileAccess.READ)
	# Used with BBCode to prevent parsing BBCode on every concatenation.
	var text_buffer := ""

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
		var foreground_color_bbcode := ""
		match char_and_color[1] & 0b1111:
			0:
				foreground_color = Color.BLACK
				foreground_color_bbcode = "black"
			1:
				foreground_color = Color.DARK_BLUE
				foreground_color_bbcode = "blue"
			2:
				foreground_color = Color.DARK_GREEN
				foreground_color_bbcode = "green"
			3:
				foreground_color = Color.DARK_CYAN
				foreground_color_bbcode = "teal"
			4:
				foreground_color = Color.DARK_RED
				foreground_color_bbcode = "red"
			5:
				foreground_color = Color.DARK_MAGENTA
				foreground_color_bbcode = "magenta"
			6:
				foreground_color = Color.BROWN
				foreground_color_bbcode = "brown"
			7:
				foreground_color = Color.GRAY
				foreground_color_bbcode = "gray"
			8:
				foreground_color = Color.DARK_GRAY
				foreground_color_bbcode = "gray"
			9:
				foreground_color = Color.LIGHT_BLUE
				foreground_color_bbcode = "blue"
			10:
				foreground_color = Color.LIGHT_GREEN
				foreground_color_bbcode = "lime"
			11:
				foreground_color = Color.CYAN
				foreground_color_bbcode = "cyan"
			12:
				foreground_color = Color.SALMON
				foreground_color_bbcode = "red"
			13:
				foreground_color = Color.PINK
				foreground_color_bbcode = "pink"
			14:
				foreground_color = Color.YELLOW
				foreground_color_bbcode = "yellow"
			15:
				foreground_color = Color.WHITE
				foreground_color_bbcode = "white"

		var background_color := Color()
		var background_color_bbcode := ""
		match char_and_color[1] >> 4:
			0:
				background_color = Color.BLACK
				background_color_bbcode = "black"
			1:
				background_color = Color.DARK_BLUE
				background_color_bbcode = "blue"
			2:
				background_color = Color.DARK_GREEN
				background_color_bbcode = "green"
			3:
				background_color = Color.DARK_CYAN
				background_color_bbcode = "teal"
			4:
				background_color = Color.DARK_RED
				background_color_bbcode = "red"
			5:
				background_color = Color.DARK_MAGENTA
				background_color_bbcode = "magenta"
			6:
				background_color = Color.BROWN
				background_color_bbcode = "brown"
			7:
				background_color = Color.GRAY
				background_color_bbcode = "gray"

		if use_bbcode:
			if swap_foreground_background:
				text_buffer += "[color=%s][bgcolor=%s]%s[/bgcolor][/color]" % [background_color.to_html() if use_bbcode_exact_colors else background_color_bbcode, foreground_color.to_html() if use_bbcode_exact_colors else foreground_color_bbcode, character]
			else:
				text_buffer += "[color=%s][bgcolor=%s]%s[/bgcolor][/color]" % [foreground_color.to_html() if use_bbcode_exact_colors else foreground_color_bbcode, background_color.to_html() if use_bbcode_exact_colors else background_color_bbcode, character]

		else:
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

	if use_bbcode:
		# Set the `text` property only once to parse BBCode only once.
		text = text_buffer
		# Use Unicode full block character for correct terminal display in console output.
		# This will not display correctly in the editor; only in the console output.
		# As an alternative, spaces can be used here, but they would require generating
		# a separate text of BBCode text for console output (compared to display within the RichTextLabel).
		print_rich(text.replace(String.chr(0xdb), "█"))
