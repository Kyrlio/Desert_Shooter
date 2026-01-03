shader_type canvas_item;

// Cette variable apparaitra comme un sélecteur de couleur dans l'inspecteur
uniform vec4 target_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Permet de régler la tolérance (pour inclure les pixels presque blancs ou l'anti-aliasing)
uniform float tolerance : hint_range(0.0, 1.0) = 0.1;

void fragment() {
	// On récupère la couleur du pixel actuel du sprite
	vec4 current_color = texture(TEXTURE, UV);
	
	// On définit ce qu'est la couleur "blanc pur"
	vec3 white = vec3(1.0, 1.0, 1.0);
	
	// On calcule la différence entre la couleur du pixel et le blanc
	float difference = distance(current_color.rgb, white);
	
	// Si la différence est plus petite que la tolérance (donc c'est du blanc)
	if (difference < tolerance) {
		// On applique la nouvelle couleur
		COLOR.rgb = target_color.rgb;
		// On garde l'alpha (transparence) d'origine du sprite pour ne pas faire un carré
		COLOR.a = current_color.a * target_color.a; 
	} else {
		// Sinon, on garde la couleur d'origine
		COLOR = current_color;
	}
}