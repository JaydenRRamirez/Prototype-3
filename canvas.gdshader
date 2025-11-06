shader_type canvas_item;

uniform vec4 rust_color : source_color = vec4(0.58, 0.28, 0.0, 1.0); 
uniform sampler2D alpha_mask; // The dynamic paint/noise mask

// NEW UNIFORM: The texture defining the kettle's solid shape
uniform sampler2D silhouette_mask; 

void fragment() {
    // 1. Read the alpha from the static kettle silhouette (the shape mask)
    vec4 shape_mask = texture(silhouette_mask, UV);
    
    // CRITICAL FIX: If the silhouette alpha is zero (outside the kettle), stop drawing immediately.
    if (shape_mask.a < 0.01) {
        discard; // This stops the drawing process for this pixel
    }

    // 2. Read the alpha from the dynamic paint mask (only happens inside the kettle now)
    vec4 paint_mask = texture(alpha_mask, UV);

    // 3. Start with the fixed rust color
    vec4 final_color = rust_color;

    // 4. Apply the dynamic paint/noise mask alpha
    final_color.a *= paint_mask.a;
    
    // Output the color
    COLOR = final_color;
}