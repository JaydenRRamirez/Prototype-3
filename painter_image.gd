extends Sprite2D

@export var paint_color : Color = Color.RED
@export var img_size := Vector2i(120, 170)
@export var brush_size := 3

var img : Image

func _ready() -> void:
	img = Image.create_empty(img_size.x, img_size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	texture = ImageTexture.create_from_image(img)

func _paint_tex(pos) -> void:
	img.fill_rect(Rect2i(pos, Vector2i(1, 1)).grow(brush_size), paint_color)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.is_echo() == false and event.button_index == MOUSE_BUTTON_LEFT:
			var lpos = to_local(event.position)
			var impos = lpos-offset+get_rect().size/2.0
			
			_paint_tex(impos)
			texture.update(img)
