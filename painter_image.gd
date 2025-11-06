extends Sprite2D

# --- Export Variables ---
@export var img_size := Vector2i(600, 600)
@export var brush_size := 15.0
@export var kettle_mask_texture: Texture2D
@export var noise_scale := 0.05

# The color we 'paint' with. For an alpha mask, we paint transparent pixels.
const MASK_COLOR_ERASE = Color(0, 0, 0, 0) # Fully transparent black (eraser)
const MASK_COLOR_DRAW = Color(1, 1, 1, 1)  # Fully opaque black (restore rust)

# --- Internal Variables ---
var img : Image
var current_color : Color = MASK_COLOR_ERASE
var texture_needs_update := false
var noise := FastNoiseLite.new()
var kettle_silhouette: Image

# --- Initialization ---
func _ready() -> void:
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	if kettle_mask_texture:
		kettle_silhouette = kettle_mask_texture.get_image()
	else:
		push_error("Error: 'kettle_mask_texture' not set! Cannot generate mask.")
		return
	
	img = Image.create_empty(img_size.x, img_size.y, false, Image.FORMAT_RGBA8)
	
	var sil_width = kettle_silhouette.get_width()
	var sil_height = kettle_silhouette.get_height()
		
	for x in range(min(img_size.x, sil_width)):
		for y in range(min(img_size.y, sil_height)):
			
			var sil_color = kettle_silhouette.get_pixel(x, y)
			if sil_color.a > 0.0:
				var noise_value = noise.get_noise_2d(float(x) * noise_scale, float(y) * noise_scale)
				
				var alpha = (noise_value + 1.0) / 2
				
				var noise_color = Color(1, 1, 1, alpha)
				img.set_pixel(x, y, noise_color)
			else:
				img.set_pixel(x, y, MASK_COLOR_ERASE)
	
	texture = ImageTexture.create_from_image(img)
	pass

# --- Painting Logic (Godot 3.x compatible) ---
func _paint_tex(pos: Vector2) -> void:
	var radius = int(brush_size)
	var sq_radius = radius * radius
	
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			if x * x + y * y <= sq_radius:
				var target_pos = Vector2(pos.x + x, pos.y + y)
				if target_pos.x >= 0 and target_pos.x < img_size.x and \
				   target_pos.y >= 0 and target_pos.y < img_size.y:
					img.set_pixel(int(target_pos.x), int(target_pos.y), current_color)
	
	texture_needs_update = true

# --- Input Handling ---
func _input(event: InputEvent) -> void:
	var lpos = to_local(event.position)
	var impos = lpos
	
	if not Rect2(Vector2.ZERO, img_size).has_point(impos):
		return

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			current_color = MASK_COLOR_ERASE
			_paint_tex(impos)
		
	elif event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			current_color = MASK_COLOR_ERASE
			
			var relative_length = event.relative.length()
			if relative_length > 0:
				var num = ceili(relative_length)
				var target_pos = impos - event.relative
				
				for i in num:
					var interpolated_pos = target_pos.move_toward(impos, float(i) / num)
					_paint_tex(interpolated_pos)
			else:
				_paint_tex(impos) # If mouse hasn't moved much, just paint at the point


# --- Update Texture on Idle Frame ---
func _process(_delta):
	if texture_needs_update:
		texture.update(img)
		texture_needs_update = false
