extends Node2D

# Get a reference to the nodes
@onready var rust_overlay = $RustOverlay
@onready var painter_image = $RustOverlay/PainterImage

func _ready():
	# Make sure the shader material is created
	if rust_overlay.material is ShaderMaterial:
		
		# Pass the dynamic texture from the PainterImage sprite to the shader's uniform
		rust_overlay.material.set_shader_parameter("alpha_mask", painter_image.texture)
		if rust_overlay.material is ShaderMaterial:
			var silhouette_texture = painter_image.kettle_mask_texture
			rust_overlay.material.set_shader_parameter("silhouette_mask", silhouette_texture)
		
		# When the PainterImage updates its texture (in _process), the shader automatically uses the updated version.
		
