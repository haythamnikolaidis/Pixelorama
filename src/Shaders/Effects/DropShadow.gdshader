shader_type canvas_item;
render_mode unshaded;

uniform vec2 offset = vec2(5.0, 5.0); // Offset, in pixel coordinate [0, 1, 2, and so on]
uniform vec4 shadow_color : source_color = vec4(0.08, 0.08, 0.08, 0.63);
uniform sampler2D selection : filter_nearest;


void fragment() {
	vec2 normalized_offset = offset * TEXTURE_PIXEL_SIZE; // Normalize offset to [0..1]
	vec4 original = texture(TEXTURE, UV); // Original texture
	float shadow = texture(TEXTURE, UV - normalized_offset).a; // Shadow, alpha only
	shadow *= shadow_color.a; // Multiply this mask by shadow alpha
	shadow = mix(0.0, shadow, texture(selection, UV).a); // Clip shadow by selection mask
	shadow = mix(shadow, 0.0, original.a); // Erase shadow alpha on original area

	// Make a border to prevent stretching pixels on the edge
	vec2 border_uv = UV - normalized_offset;
	border_uv -= 0.5;
	border_uv *= 2.0;
	border_uv = abs(border_uv);

	float border = max(border_uv.x, border_uv.y);
	border = floor(border);
	border = 1.0 - clamp(border, 0.0, 1.0);

	shadow *= border; // Clip shadow by border so no more stretching

	COLOR.rgb = mix(original.rgb, shadow_color.rgb, shadow); // Set color on shadow area
	COLOR.a = mix(original.a, 1.0, shadow); // Combine alpha
}
